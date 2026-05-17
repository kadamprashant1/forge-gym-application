import 'package:hive_flutter/hive_flutter.dart';
import 'package:forge/domain/entities/workout_day.dart';
import 'package:forge/domain/entities/exercise.dart';
import 'package:forge/domain/entities/workout_session.dart';
import 'package:forge/domain/entities/exercise_log.dart';
import 'package:forge/domain/entities/user_settings.dart';

class HiveService {
  static const String workoutDaysBox = 'workout_days';
  static const String exercisesBox = 'exercises';
  static const String workoutSessionsBox = 'workout_sessions';
  static const String exerciseLogsBox = 'exercise_logs';
  static const String settingsBox = 'settings';

  Future<void> init() async {
    await Hive.initFlutter();
    
    Hive.registerAdapter(WorkoutDayAdapter());
    Hive.registerAdapter(ExerciseAdapter());
    Hive.registerAdapter(WorkoutSessionAdapter());
    Hive.registerAdapter(ExerciseLogAdapter());
    Hive.registerAdapter(UserSettingsAdapter());

    await Hive.openBox<WorkoutDay>(workoutDaysBox);
    await Hive.openBox<Exercise>(exercisesBox);
    await Hive.openBox<WorkoutSession>(workoutSessionsBox);
    await Hive.openBox<ExerciseLog>(exerciseLogsBox);
    await Hive.openBox<UserSettings>(settingsBox);
  }

  Box<T> getBox<T>(String name) => Hive.box<T>(name);
}
