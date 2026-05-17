import 'package:hive/hive.dart';

part 'exercise.g.dart';

@HiveType(typeId: 1)
class Exercise extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String workoutDayId;
  
  @HiveField(2)
  final int orderIndex;
  
  @HiveField(3)
  final String exerciseName;
  
  @HiveField(4)
  final int sets;
  
  @HiveField(5)
  final int minReps;
  
  @HiveField(6)
  final int maxReps;
  
  @HiveField(7)
  final String? notes;
  
  @HiveField(8)
  final String? imagePath;

  @HiveField(9)
  final String? videoUrl;

  Exercise({
    required this.id,
    required this.workoutDayId,
    required this.orderIndex,
    required this.exerciseName,
    required this.sets,
    required this.minReps,
    required this.maxReps,
    this.notes,
    this.imagePath,
    this.videoUrl,
  });
}
