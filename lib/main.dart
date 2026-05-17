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

  // Import default workout plan if the database is empty
  final repository = getIt<WorkoutRepository>();
  final existingDays = await repository.getWorkoutDays();
  
  if (existingDays.isEmpty) {
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
