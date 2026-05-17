import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forge/app/app.dart';
import 'package:forge/data/datasources/local/hive_service.dart';
import 'package:forge/data/datasources/local/default_workout_plan.dart';
import 'package:forge/di/injection.dart';
import 'package:forge/domain/repositories/workout_repository.dart';
import 'package:forge/domain/entities/workout_day.dart';
import 'package:forge/domain/entities/exercise.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  final hiveService = HiveService();
  await hiveService.init();
  
  // Initialize Dependency Injection
  setupInjection(hiveService);

  final repository = getIt<WorkoutRepository>();
  final existingDays = await repository.getWorkoutDays();
  
  bool needsUpdate = false;
  if (existingDays.isNotEmpty) {
    final firstDayExercises = await repository.getExercisesByWorkoutDay(existingDays.first.id);
    // If data exists but doesn't have video URLs, we force a re-import
    if (firstDayExercises.isNotEmpty && (firstDayExercises.first.videoUrl == null)) {
      needsUpdate = true;
    }
  }
  
  if (existingDays.isEmpty || needsUpdate) {
    final plan = DefaultWorkoutPlan.getPlan();
    await repository.importWorkoutPlan(
      plan['days'] as List<WorkoutDay>,
      plan['exercises'] as List<Exercise>,
    );
  }
  
  runApp(
    const ProviderScope(
      child: WorkoutTrackerApp(),
    ),
  );
}
