import 'package:forge/domain/entities/workout_day.dart';
import 'package:forge/domain/entities/exercise.dart';
import 'package:forge/domain/entities/workout_session.dart';
import 'package:forge/domain/entities/exercise_log.dart';

abstract class WorkoutRepository {
  Future<List<WorkoutDay>> getWorkoutDays();
  Future<List<Exercise>> getExercisesByWorkoutDay(String workoutDayId);
  Future<void> saveWorkoutSession(WorkoutSession session);
  Future<void> saveExerciseLogs(List<ExerciseLog> logs);
  Future<List<WorkoutSession>> getWorkoutHistory();
  Future<List<ExerciseLog>> getExerciseLogs(String sessionId);
  Future<void> importWorkoutPlan(List<WorkoutDay> days, List<Exercise> exercises);
}
