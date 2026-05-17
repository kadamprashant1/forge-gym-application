import 'package:uuid/uuid.dart';
import 'package:forge/domain/entities/workout_day.dart';
import 'package:forge/domain/entities/exercise.dart';

class DefaultWorkoutPlan {
  static const _uuid = Uuid();

  static Map<String, dynamic> getPlan() {
    final List<WorkoutDay> days = [];
    final List<Exercise> exercises = [];

    // MONDAY
    final mondayId = _uuid.v4();
    days.add(WorkoutDay(
      id: mondayId,
      name: 'Monday',
      dayOrder: 0,
      targetMuscles: ['Chest', 'Shoulders', 'Triceps'],
      workoutType: 'push',
      scheduledDay: 0,
    ));

    exercises.addAll([
      _createExercise(mondayId, 'Flat Barbell Bench Press', 0, 4, 6, 8, video: 'https://www.youtube.com/watch?v=rT7DgCr-3pg'),
      _createExercise(mondayId, 'Incline Dumbbell Press', 1, 3, 8, 10, video: 'https://www.youtube.com/watch?v=8iPEnn-ltC8'),
      _createExercise(mondayId, 'Cable Chest Fly', 2, 3, 12, 15, video: 'https://www.youtube.com/watch?v=Iwe6AmxVf7o'),
      _createExercise(mondayId, 'Seated Dumbbell Shoulder Press', 3, 3, 8, 10, video: 'https://www.youtube.com/watch?v=qEwKCR5JCog'),
      _createExercise(mondayId, 'Cable Lateral Raises', 4, 3, 15, 15, video: 'https://www.youtube.com/watch?v=Z5FA9aq3L6A'),
      _createExercise(mondayId, 'Triceps Pushdown (Rope)', 5, 3, 12, 12, video: 'https://www.youtube.com/watch?v=vB5OHsJ3EME'),
      _createExercise(mondayId, 'Overhead Tricep Extension', 6, 3, 10, 12, video: 'https://www.youtube.com/watch?v=ns-RGsbzqok'),
    ]);

    // TUESDAY
    final tuesdayId = _uuid.v4();
    days.add(WorkoutDay(
      id: tuesdayId,
      name: 'Tuesday',
      dayOrder: 1,
      targetMuscles: ['Back', 'Biceps'],
      workoutType: 'pull',
      scheduledDay: 1,
    ));

    exercises.addAll([
      _createExercise(tuesdayId, 'Conventional Deadlift', 0, 3, 4, 6, notes: 'Heavy', video: 'https://www.youtube.com/watch?v=op9kVnSso6Q'),
      _createExercise(tuesdayId, 'Weighted Pull-Ups', 1, 4, 6, 10, video: 'https://www.youtube.com/watch?v=i9SInYSTv_k'),
      _createExercise(tuesdayId, 'Barbell Rows', 2, 3, 8, 8, video: 'https://www.youtube.com/watch?v=9efgcAjQe7E'),
      _createExercise(tuesdayId, 'Lat Pulldown', 3, 3, 10, 12, video: 'https://www.youtube.com/watch?v=jgFel4wZl3I'),
      _createExercise(tuesdayId, 'Cable Rows (Neutral Grip)', 4, 3, 12, 12, video: 'https://www.youtube.com/watch?v=GZbfZ033f74'),
      _createExercise(tuesdayId, 'EZ Bar Curl', 5, 3, 10, 10, video: 'https://www.youtube.com/watch?v=-gSM-kqNlUw'),
      _createExercise(tuesdayId, 'Preacher Curls', 6, 3, 12, 12, video: 'https://www.youtube.com/watch?v=pCQo4VJxmhI'),
    ]);

    // WEDNESDAY
    final wednesdayId = _uuid.v4();
    days.add(WorkoutDay(
      id: wednesdayId,
      name: 'Wednesday',
      dayOrder: 2,
      targetMuscles: ['Quads', 'Hamstrings', 'Calves', 'Abs'],
      workoutType: 'legs',
      scheduledDay: 2,
    ));

    exercises.addAll([
      _createExercise(wednesdayId, 'Back Squat', 0, 4, 6, 8, notes: 'Heavy', video: 'https://www.youtube.com/watch?v=SW_C1A-rejs'),
      _createExercise(wednesdayId, 'Leg Press', 1, 3, 10, 12, video: 'https://www.youtube.com/watch?v=IZxyjW7MPJQ'),
      _createExercise(wednesdayId, 'Romanian Deadlift (RDL)', 2, 3, 10, 10, video: 'https://www.youtube.com/watch?v=bT5OOBgY4bc'),
      _createExercise(wednesdayId, 'Leg Extension', 3, 3, 15, 15, video: 'https://www.youtube.com/watch?v=s1JfTvyWdTs'),
      _createExercise(wednesdayId, 'Hamstring Curl', 4, 3, 12, 12, video: 'https://www.youtube.com/watch?v=xKOyGU0AfOE'),
      _createExercise(wednesdayId, 'Standing Calf Raises', 5, 4, 20, 25, video: 'https://www.youtube.com/watch?v=YMmgqO8Jo-k'),
      _createExercise(wednesdayId, 'Cable Rope Crunches', 6, 3, 15, 15, video: 'https://www.youtube.com/watch?v=6GMKPQVERzw'),
    ]);

    // THURSDAY
    final thursdayId = _uuid.v4();
    days.add(WorkoutDay(
      id: thursdayId,
      name: 'Thursday',
      dayOrder: 3,
      targetMuscles: ['Chest', 'Shoulders', 'Triceps'],
      workoutType: 'push',
      scheduledDay: 3,
    ));

    exercises.addAll([
      _createExercise(thursdayId, 'Incline Barbell Press', 0, 4, 8, 10, video: 'https://www.youtube.com/watch?v=jMQA3XtJSgo'),
      _createExercise(thursdayId, 'Flat Dumbbell Press', 1, 3, 10, 12, video: 'https://www.youtube.com/watch?v=ZaDlbm8E8Tg'),
      _createExercise(thursdayId, 'Pec Deck / Chest Fly Machine', 2, 3, 15, 15, video: 'https://www.youtube.com/watch?v=X3Nj2ZPwW04'),
      _createExercise(thursdayId, 'Arnold Press', 3, 3, 10, 10, video: 'https://www.youtube.com/watch?v=6Z15_WdXmVw'),
      _createExercise(thursdayId, 'Lateral Raise + Rear Delt Fly', 4, 3, 15, 15, notes: 'Superset', video: 'https://www.youtube.com/watch?v=3VcKaXpzqRo'),
      _createExercise(thursdayId, 'Triceps Dip / Bench Dip', 5, 3, 0, 0, notes: 'Failure', video: 'https://www.youtube.com/watch?v=yvAzWxRsnqU'),
      _createExercise(thursdayId, 'Single-Arm Overhead Extension', 6, 3, 12, 12, video: 'https://www.youtube.com/watch?v=R_-Zv0ltkNI'),
    ]);

    // FRIDAY
    final fridayId = _uuid.v4();
    days.add(WorkoutDay(
      id: fridayId,
      name: 'Friday',
      dayOrder: 4,
      targetMuscles: ['Back', 'Biceps', 'Abs'],
      workoutType: 'pull',
      scheduledDay: 4,
    ));

    exercises.addAll([
      _createExercise(fridayId, 'Chest-Supported DB Rows', 0, 4, 10, 12, video: 'https://www.youtube.com/watch?v=H75im9fAUMc'),
      _createExercise(fridayId, 'Single-Arm Cable Row', 1, 3, 12, 12, notes: 'Each side', video: 'https://www.youtube.com/watch?v=SkMJJKd8Bec'),
      _createExercise(fridayId, 'Straight-Arm Pulldown', 2, 3, 15, 15, video: 'https://www.youtube.com/watch?v=iyJ15x6yMEw'),
      _createExercise(fridayId, 'Face Pulls (Rope)', 3, 3, 20, 20, video: 'https://www.youtube.com/watch?v=5ZC4LagfDQ4'),
      _createExercise(fridayId, 'Hammer Curls', 4, 3, 12, 12, video: 'https://www.youtube.com/watch?v=TwD-YGVP4Bk'),
      _createExercise(fridayId, 'Spider Curls / Cable Curl', 5, 3, 10, 12, video: 'https://www.youtube.com/watch?v=h9DPY5pCaGA'),
      _createExercise(fridayId, 'Leg Raises', 6, 3, 15, 15, video: 'https://www.youtube.com/watch?v=JB2oyawG9KI'),
    ]);

    // SATURDAY
    final saturdayId = _uuid.v4();
    days.add(WorkoutDay(
      id: saturdayId,
      name: 'Saturday',
      dayOrder: 5,
      targetMuscles: ['Glutes', 'Quads', 'Hamstrings', 'Calves'],
      workoutType: 'legs',
      scheduledDay: 5,
    ));

    exercises.addAll([
      _createExercise(saturdayId, 'Front Squat', 0, 3, 6, 8, video: 'https://www.youtube.com/watch?v=uYumuL_G_V0'),
      _createExercise(saturdayId, 'Hip Thrust / Glute Bridge', 1, 4, 10, 12, notes: 'Heavy', video: 'https://www.youtube.com/watch?v=wnbD-5d8tJM'),
      _createExercise(saturdayId, 'Walking Lunges', 2, 3, 12, 12, notes: 'Each leg', video: 'https://www.youtube.com/watch?v=DlhojghkaQ0'),
      _createExercise(saturdayId, 'Leg Extension (High Rep)', 3, 3, 20, 20, video: 'https://www.youtube.com/watch?v=s1JfTvyWdTs'),
      _createExercise(saturdayId, 'Seated Hamstring Curl', 4, 3, 15, 15, video: 'https://www.youtube.com/watch?v=ELOCsoDSmrg'),
      _createExercise(saturdayId, 'Seated Calf Raises', 5, 3, 25, 25, video: 'https://www.youtube.com/watch?v=YBTAGDs8vys'),
    ]);

    // SUNDAY
    final sundayId = _uuid.v4();
    days.add(WorkoutDay(
      id: sundayId,
      name: 'Sunday',
      dayOrder: 6,
      targetMuscles: ['Full Recovery'],
      workoutType: 'rest',
      scheduledDay: 6,
    ));

    return {'days': days, 'exercises': exercises};
  }

  static Exercise _createExercise(
    String dayId,
    String name,
    int order,
    int sets,
    int min,
    int max, {
    String? notes,
    String? video,
  }) {
    return Exercise(
      id: _uuid.v4(),
      workoutDayId: dayId,
      orderIndex: order,
      exerciseName: name,
      sets: sets,
      minReps: min,
      maxReps: max,
      notes: notes,
      videoUrl: video,
    );
  }
}
