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

final allExercisesProvider = FutureProvider<List<Exercise>>((ref) async {
  final repo = ref.watch(workoutRepositoryProvider);
  final days = await ref.watch(workoutDaysProvider.future);
  List<Exercise> all = [];
  for (var day in days) {
    final exercises = await repo.getExercisesByWorkoutDay(day.id);
    all.addAll(exercises);
  }
  return all;
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

final allExerciseLogsProvider = FutureProvider<List<ExerciseLog>>((ref) async {
  final repo = ref.watch(workoutRepositoryProvider);
  final sessions = await ref.watch(workoutHistoryProvider.future);
  List<ExerciseLog> allLogs = [];
  for (var session in sessions) {
    final logs = await repo.getExerciseLogs(session.id);
    allLogs.addAll(logs);
  }
  return allLogs;
});

// --- Dynamic Progress Providers ---

final weeklyConsistencyProvider = Provider.autoDispose<Map<String, dynamic>>((ref) {
  final history = ref.watch(workoutHistoryProvider).value ?? [];
  final days = ref.watch(workoutDaysProvider).value ?? [];

  if (days.isEmpty) return {'percentage': 0.0, 'text': 'No plan found', 'ratio': '0/0'};

  final now = DateTime.now();
  final monday = now.subtract(Duration(days: now.weekday - 1));
  final startOfWeek = DateTime(monday.year, monday.month, monday.day);

  final scheduledTrainingDays = days.where((d) => d.workoutType != 'rest').length;
  final completedTrainingSessions = history.where((s) {
    if (s.date.isBefore(startOfWeek)) return false;
    final day = days.firstWhere((d) => d.id == s.workoutDayId, orElse: () => days.first);
    return day.workoutType != 'rest';
  }).length;

  final percentage = scheduledTrainingDays > 0 
      ? (completedTrainingSessions / scheduledTrainingDays).clamp(0.0, 1.0) 
      : 0.0;

  return {
    'percentage': percentage,
    'text': '$completedTrainingSessions of $scheduledTrainingDays training days completed',
    'ratio': '${(percentage * 100).toInt()}%',
  };
});

final volumeProgressProvider = Provider.autoDispose<List<double>>((ref) {
  final history = ref.watch(workoutHistoryProvider).value ?? [];
  final allLogs = ref.watch(allExerciseLogsProvider).value ?? [];

  if (history.isEmpty) return List.filled(7, 0.0);

  // Group volume by date for the last 7 days
  final now = DateTime.now();
  Map<String, double> dailyVolume = {};

  for (var log in allLogs) {
    final session = history.firstWhere((s) => s.id == log.sessionId);
    final dateKey = "${session.date.year}-${session.date.month}-${session.date.day}";
    // Volume = weight * reps. If not logged, we count it as 1 to show activity.
    final volume = log.weight > 0 ? log.weight * log.repsCompleted : 1.0; 
    dailyVolume[dateKey] = (dailyVolume[dateKey] ?? 0) + volume;
  }

  List<double> result = [];
  for (int i = 6; i >= 0; i--) {
    final d = now.subtract(Duration(days: i));
    final key = "${d.year}-${d.month}-${d.day}";
    result.add(dailyVolume[key] ?? 0.0);
  }
  return result;
});

final personalRecordsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final allLogs = await ref.watch(allExerciseLogsProvider.future);
  final allExercises = await ref.watch(allExercisesProvider.future);

  final prLogs = allLogs.where((l) => l.isPersonalRecord).toList();
  prLogs.sort((a, b) => b.id.compareTo(a.id)); // Assuming UUIDs aren't chronological, but we'd ideally use session date

  return prLogs.take(5).map((log) {
    final exercise = allExercises.firstWhere((e) => e.id == log.exerciseId, 
        orElse: () => Exercise(id: '', workoutDayId: '', orderIndex: 0, exerciseName: 'Unknown', sets: 0, minReps: 0, maxReps: 0));
    return {
      'name': exercise.exerciseName,
      'value': '${log.weight} kg x ${log.repsCompleted}',
      'date': 'Recent',
    };
  }).toList();
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
