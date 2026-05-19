import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forge/app/app.dart';
import 'package:forge/data/datasources/local/hive_service.dart';
import 'package:forge/data/datasources/local/default_workout_plan.dart';
import 'package:forge/di/injection.dart';
import 'package:forge/domain/repositories/workout_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Core Initialization
  final hiveService = HiveService();
  await hiveService.init();
  setupInjection(hiveService);

  // Load default plan if database is empty
  final repo = getIt<WorkoutRepository>();
  final days = await repo.getWorkoutDays();
  if (days.isEmpty) {
    final defaultData = DefaultWorkoutPlan.getPlan();
    await repo.importWorkoutPlan(
      defaultData['days'],
      defaultData['exercises'],
    );
  }
  
  runApp(
    const ProviderScope(
      child: WorkoutTrackerApp(),
    ),
  );
}
