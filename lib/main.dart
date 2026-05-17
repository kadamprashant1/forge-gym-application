import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forge/app/app.dart';
import 'package:forge/data/datasources/local/hive_service.dart';
import 'package:forge/di/injection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Core Initialization
  final hiveService = HiveService();
  await hiveService.init();
  setupInjection(hiveService);
  
  runApp(
    const ProviderScope(
      child: WorkoutTrackerApp(),
    ),
  );
}
