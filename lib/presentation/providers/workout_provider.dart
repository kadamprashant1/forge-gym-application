import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forge/di/injection.dart';
import 'package:forge/domain/entities/workout_day.dart';
import 'package:forge/domain/entities/exercise.dart';
import 'package:forge/domain/entities/workout_session.dart';
import 'package:forge/domain/entities/exercise_log.dart';
import 'package:forge/domain/repositories/workout_repository.dart';
import 'package:uuid/uuid.dart';

final workoutRepositoryProvider = Provider<WorkoutRepository>((ref) {
  return getIt<WorkoutRepository>();
});

final workoutDaysProvider = FutureProvider<List<WorkoutDay>>((ref) async {
  final repo = ref.watch(workoutRepositoryProvider);
  return repo.getWorkoutDays();
});

final exercisesProvider = FutureProvider.family<List<Exercise>, String>((ref, dayId) async {
  final repo = ref.watch(workoutRepositoryProvider);
  return repo.getExercisesByWorkoutDay(dayId);
});

final workoutHistoryProvider = FutureProvider<List<WorkoutSession>>((ref) async {
  final repo = ref.watch(workoutRepositoryProvider);
  final history = await repo.getWorkoutHistory();
  final days = await repo.getWorkoutDays();
  
  if (days.isEmpty) return history;

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  bool addedAny = false;

  for (int i = 0; i <= 7; i++) {
    final checkDate = today.subtract(Duration(days: i));
    final weekdayIndex = checkDate.weekday - 1; 
    final planDay = days.firstWhere((d) => d.scheduledDay == weekdayIndex, orElse: () => days.last);
    
    if (planDay.workoutType == 'rest') {
      final alreadyLogged = history.any((s) => 
        s.date.year == checkDate.year && s.date.month == checkDate.month && s.date.day == checkDate.day);
        
      if (!alreadyLogged) {
         await repo.saveWorkoutSession(WorkoutSession(
           id: const Uuid().v4(),
           date: checkDate,
           workoutDayId: planDay.id,
           durationMinutes: 0,
           completed: true,
           notes: 'Rest Day (Auto-logged)',
         ));
         addedAny = true;
      }
    }
  }
  return addedAny ? await repo.getWorkoutHistory() : history;
});

// New provider to calculate "Volume" based on completion count
final allExerciseLogsProvider = FutureProvider<List<ExerciseLog>>((ref) async {
  final repo = ref.watch(workoutRepositoryProvider);
  final sessions = await repo.getWorkoutHistory();
  List<ExerciseLog> allLogs = [];
  for (var session in sessions) {
    final logs = await repo.getExerciseLogs(session.id);
    allLogs.addAll(logs);
  }
  return allLogs;
});

final streakProvider = Provider<int>((ref) {
  final historyAsync = ref.watch(workoutHistoryProvider);
  final daysAsync = ref.watch(workoutDaysProvider);
  
  return historyAsync.maybeWhen(
    data: (sessions) {
      if (sessions.isEmpty) return 0;
      return daysAsync.maybeWhen(
        data: (days) {
          final restDays = days.where((d) => d.workoutType == 'rest').map((d) => d.scheduledDay).toSet();
          final sessionDates = sessions.map((s) => DateTime(s.date.year, s.date.month, s.date.day)).toSet();
          final now = DateTime.now();
          DateTime checkDate = DateTime(now.year, now.month, now.day);
          int streak = 0;
          bool isFirst = true;
          while (true) {
            final weekdayIndex = checkDate.weekday - 1;
            final isRestDay = restDays.contains(weekdayIndex);
            final hasSession = sessionDates.contains(checkDate);
            if (hasSession || isRestDay) {
              if (hasSession || !isFirst) streak++;
              checkDate = checkDate.subtract(const Duration(days: 1));
            } else {
              if (isFirst) {
                checkDate = checkDate.subtract(const Duration(days: 1));
              } else {
                break;
              }
            }
            isFirst = false;
            if (streak > 3650) break;
          }
          return streak;
        },
        orElse: () => 0,
      );
    },
    orElse: () => 0,
  );
});
