import 'package:hive/hive.dart';

part 'workout_session.g.dart';

@HiveType(typeId: 2)
class WorkoutSession extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final DateTime date;
  
  @HiveField(2)
  final String workoutDayId;
  
  @HiveField(3)
  final int durationMinutes;
  
  @HiveField(4)
  final bool completed;
  
  @HiveField(5)
  final String? notes;

  WorkoutSession({
    required this.id,
    required this.date,
    required this.workoutDayId,
    required this.durationMinutes,
    required this.completed,
    this.notes,
  });
}
