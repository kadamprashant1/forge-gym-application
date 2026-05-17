import 'package:hive/hive.dart';

part 'exercise_log.g.dart';

@HiveType(typeId: 3)
class ExerciseLog extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String sessionId;
  
  @HiveField(2)
  final String exerciseId;
  
  @HiveField(3)
  final int setNumber;
  
  @HiveField(4)
  final double weight;
  
  @HiveField(5)
  final int repsCompleted;
  
  @HiveField(6)
  final bool isPersonalRecord;

  ExerciseLog({
    required this.id,
    required this.sessionId,
    required this.exerciseId,
    required this.setNumber,
    required this.weight,
    required this.repsCompleted,
    this.isPersonalRecord = false,
  });
}
