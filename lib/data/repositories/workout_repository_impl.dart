import 'package:forge/data/datasources/local/hive_service.dart';
import 'package:forge/data/datasources/local/default_workout_plan.dart';
import 'package:forge/domain/entities/exercise.dart';
import 'package:forge/domain/entities/exercise_log.dart';
import 'package:forge/domain/entities/workout_day.dart';
import 'package:forge/domain/entities/workout_session.dart';
import 'package:forge/domain/repositories/workout_repository.dart';

class WorkoutRepositoryImpl implements WorkoutRepository {
  final HiveService _hiveService;

  WorkoutRepositoryImpl(this._hiveService);

  @override
  Future<List<WorkoutDay>> getWorkoutDays() async {
    final box = _hiveService.getBox<WorkoutDay>(HiveService.workoutDaysBox);
    
    if (box.isEmpty) {
      final plan = DefaultWorkoutPlan.getPlan();
      await importWorkoutPlan(
        plan['days'] as List<WorkoutDay>,
        plan['exercises'] as List<Exercise>,
      );
    }

    return box.values.toList()..sort((a, b) => a.dayOrder.compareTo(b.dayOrder));
  }

  @override
  Future<List<Exercise>> getExercisesByWorkoutDay(String workoutDayId) async {
    final box = _hiveService.getBox<Exercise>(HiveService.exercisesBox);
    return box.values.where((e) => e.workoutDayId == workoutDayId).toList()
      ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
  }

  @override
  Future<void> saveWorkoutSession(WorkoutSession session) async {
    final box = _hiveService.getBox<WorkoutSession>(HiveService.workoutSessionsBox);
    await box.put(session.id, session);
  }

  @override
  Future<void> saveExerciseLogs(List<ExerciseLog> logs) async {
    final box = _hiveService.getBox<ExerciseLog>(HiveService.exerciseLogsBox);
    for (var log in logs) {
      await box.put(log.id, log);
    }
  }

  @override
  Future<List<WorkoutSession>> getWorkoutHistory() async {
    final box = _hiveService.getBox<WorkoutSession>(HiveService.workoutSessionsBox);
    return box.values.toList()..sort((a, b) => b.date.compareTo(a.date));
  }

  @override
  Future<List<ExerciseLog>> getExerciseLogs(String sessionId) async {
    final box = _hiveService.getBox<ExerciseLog>(HiveService.exerciseLogsBox);
    return box.values.where((l) => l.sessionId == sessionId).toList();
  }

  @override
  Future<void> importWorkoutPlan(List<WorkoutDay> days, List<Exercise> exercises) async {
    final dayBox = _hiveService.getBox<WorkoutDay>(HiveService.workoutDaysBox);
    final exerciseBox = _hiveService.getBox<Exercise>(HiveService.exercisesBox);

    await dayBox.clear();
    await exerciseBox.clear();

    for (var day in days) {
      await dayBox.put(day.id, day);
    }
    for (var exercise in exercises) {
      await exerciseBox.put(exercise.id, exercise);
    }
  }
}
