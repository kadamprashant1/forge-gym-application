import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forge/app/theme.dart';
import 'package:forge/presentation/providers/workout_provider.dart';
import 'package:forge/domain/entities/exercise.dart';
import 'package:forge/domain/entities/exercise_log.dart';
import 'package:forge/domain/entities/workout_session.dart';
import 'package:uuid/uuid.dart';
import 'package:url_launcher/url_launcher.dart';

class WorkoutDetailScreen extends ConsumerStatefulWidget {
  final String workoutId;
  const WorkoutDetailScreen({super.key, required this.workoutId});

  @override
  ConsumerState<WorkoutDetailScreen> createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends ConsumerState<WorkoutDetailScreen> {
  final Set<String> _completedExercises = {};
  final DateTime _startTime = DateTime.now();

  String? _getYoutubeId(String? url) {
    if (url == null) return null;
    final regExp = RegExp(
      r'^.*((youtu.be\/)|(v\/)|(\/u\/\w\/)|(embed\/)|(watch\?))\??v?=?([^#&?]*).*',
      caseSensitive: false,
      multiLine: false,
    );
    final match = regExp.firstMatch(url);
    return (match != null && match.group(7)!.length == 11) ? match.group(7) : null;
  }

  Future<void> _launchVideo(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final exercisesAsync = ref.watch(exercisesProvider(widget.workoutId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Training Session'),
        centerTitle: true,
      ),
      body: exercisesAsync.when(
        data: (exercises) {
          if (exercises.isEmpty) {
            return const Center(child: Text('No exercises found.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            itemCount: exercises.length,
            itemBuilder: (context, index) {
              final exercise = exercises[index];
              return _buildExerciseCard(context, exercise);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        color: AppTheme.surface,
        child: ElevatedButton(
          onPressed: () => _completeWorkout(context),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 56),
            backgroundColor: AppTheme.accent,
          ),
          child: const Text('FINISH WORKOUT', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildExerciseCard(BuildContext context, Exercise exercise) {
    final isCompleted = _completedExercises.contains(exercise.id);
    final youtubeId = _getYoutubeId(exercise.videoUrl);

    return Card(
      margin: const EdgeInsets.only(bottom: 24),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (youtubeId != null)
            GestureDetector(
              onTap: () => _launchVideo(exercise.videoUrl!),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.network(
                    'https://img.youtube.com/vi/$youtubeId/hqdefault.jpg',
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.accent.withOpacity(0.8),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.play_arrow, size: 40, color: Colors.black),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.exerciseName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: isCompleted ? AppTheme.accent : Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (exercise.notes != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    exercise.notes!,
                    style: const TextStyle(color: Colors.orangeAccent, fontSize: 13),
                  ),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        if (isCompleted) {
                          _completedExercises.remove(exercise.id);
                        } else {
                          _completedExercises.add(exercise.id);
                        }
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isCompleted ? Colors.white70 : AppTheme.accent,
                      side: BorderSide(color: isCompleted ? Colors.white24 : AppTheme.accent),
                    ),
                    child: Text(isCompleted ? 'COMPLETED' : 'MARK AS DONE'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _completeWorkout(BuildContext context) async {
    if (_completedExercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mark at least one exercise as done.')),
      );
      return;
    }

    final repo = ref.read(workoutRepositoryProvider);
    final sessionId = const Uuid().v4();
    final endTime = DateTime.now();
    final duration = endTime.difference(_startTime).inMinutes;

    final session = WorkoutSession(
      id: sessionId,
      date: _startTime,
      workoutDayId: widget.workoutId,
      durationMinutes: duration,
      completed: true,
    );

    final List<ExerciseLog> logsToSave = [];
    for (var exerciseId in _completedExercises) {
      logsToSave.add(ExerciseLog(
        id: const Uuid().v4(),
        sessionId: sessionId,
        exerciseId: exerciseId,
        setNumber: 1,
        weight: 0,
        repsCompleted: 0,
      ));
    }

    await repo.saveWorkoutSession(session);
    await repo.saveExerciseLogs(logsToSave);
    
    // Invalidate history to update streak on Home Screen
    ref.invalidate(workoutHistoryProvider);

    if (context.mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Workout session saved!'),
          backgroundColor: AppTheme.success,
        ),
      );
    }
  }
}
