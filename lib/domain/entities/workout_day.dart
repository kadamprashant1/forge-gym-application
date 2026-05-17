import 'package:hive/hive.dart';

part 'workout_day.g.dart';

@HiveType(typeId: 0)
class WorkoutDay extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final int dayOrder;
  
  @HiveField(3)
  final List<String> targetMuscles;
  
  @HiveField(4)
  final String workoutType; // push, pull, legs
  
  @HiveField(5)
  final int? scheduledDay; // 0=Monday...6=Sunday

  WorkoutDay({
    required this.id,
    required this.name,
    required this.dayOrder,
    required this.targetMuscles,
    required this.workoutType,
    this.scheduledDay,
  });
}
