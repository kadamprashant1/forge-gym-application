import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forge/di/injection.dart';
import 'package:forge/domain/entities/workout_day.dart';
import 'package:forge/domain/entities/exercise.dart';
import 'package:forge/domain/repositories/workout_repository.dart';

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

final workoutHistoryProvider = FutureProvider((ref) async {
  final repo = ref.watch(workoutRepositoryProvider);
  return repo.getWorkoutHistory();
});
