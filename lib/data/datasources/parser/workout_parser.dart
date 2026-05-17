import 'package:uuid/uuid.dart';
import 'package:forge/domain/entities/workout_day.dart';
import 'package:forge/domain/entities/exercise.dart';

class WorkoutParser {
  final _uuid = const Uuid();

  Map<String, dynamic> parse(String content) {
    final List<WorkoutDay> workoutDays = [];
    final List<Exercise> exercises = [];
    
    final lines = content.split('\n');
    WorkoutDay? currentDay;
    int dayCount = 0;
    int exerciseCount = 0;

    final headerRegex = RegExp(r'^([A-Z]+) — ([A-Z]+ [A-Z]) \((.*)\)$');
    final exerciseRegex = RegExp(r'^\d+\. (.*)$');
    final setsRepsRegex = RegExp(r'^(\d+) sets x ([\d-]+) reps$');

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      final headerMatch = headerRegex.firstMatch(line);
      if (headerMatch != null) {
        final dayName = headerMatch.group(1)!;
        final workoutType = headerMatch.group(2)!;
        final muscles = headerMatch.group(3)!.split(',').map((e) => e.trim()).toList();

        currentDay = WorkoutDay(
          id: _uuid.v4(),
          name: '$dayName — $workoutType',
          dayOrder: dayCount++,
          targetMuscles: muscles,
          workoutType: workoutType.split(' ').first.toLowerCase(),
        );
        workoutDays.add(currentDay);
        exerciseCount = 0;
        continue;
      }

      if (currentDay == null) continue;

      final exerciseMatch = exerciseRegex.firstMatch(line);
      if (exerciseMatch != null) {
        final exerciseName = exerciseMatch.group(1)!;
        
        // Peek at next line for sets/reps
        int sets = 0;
        int minReps = 0;
        int maxReps = 0;
        String? imagePath;

        if (i + 1 < lines.length) {
          final nextLine = lines[i + 1].trim();
          final srMatch = setsRepsRegex.firstMatch(nextLine);
          if (srMatch != null) {
            sets = int.parse(srMatch.group(1)!);
            final repsRange = srMatch.group(2)!.split('-');
            if (repsRange.length == 2) {
              minReps = int.parse(repsRange[0]);
              maxReps = int.parse(repsRange[1]);
            } else {
              minReps = maxReps = int.parse(repsRange[0]);
            }
            i++; // Skip sets/reps line
          }
        }

        // Peek for image
        if (i + 1 < lines.length) {
          final imageLine = lines[i + 1].trim();
          if (imageLine.startsWith('Image:')) {
            imagePath = imageLine.replaceFirst('Image:', '').trim();
            i++; // Skip image line
          }
        }

        exercises.add(Exercise(
          id: _uuid.v4(),
          workoutDayId: currentDay.id,
          orderIndex: exerciseCount++,
          exerciseName: exerciseName,
          sets: sets,
          minReps: minReps,
          maxReps: maxReps,
          imagePath: imagePath,
        ));
      }
    }

    return {
      'days': workoutDays,
      'exercises': exercises,
    };
  }
}
