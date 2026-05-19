import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forge/app/theme.dart';
import 'package:forge/presentation/providers/workout_provider.dart';
import 'package:forge/domain/entities/exercise.dart';
import 'package:forge/domain/entities/exercise_log.dart';
import 'package:forge/domain/entities/workout_session.dart';
import 'package:uuid/uuid.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class WorkoutDetailScreen extends ConsumerStatefulWidget {
  final String workoutId;
  const WorkoutDetailScreen({super.key, required this.workoutId});

  @override
  ConsumerState<WorkoutDetailScreen> createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends ConsumerState<WorkoutDetailScreen> {
  final Set<String> _completedExercises = {};
  final DateTime _startTime = DateTime.now();
  String? _activeVideoExerciseId;

  String? _getYoutubeId(String? url) {
    if (url == null) return null;
    return YoutubePlayer.convertUrlToId(url);
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
    final isPlaying = _activeVideoExerciseId == exercise.id;

    return Card(
      margin: const EdgeInsets.only(bottom: 24),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (youtubeId != null)
            SizedBox(
              height: 220,
              width: double.infinity,
              child: isPlaying
                  ? YoutubePlayer(
                      controller: YoutubePlayerController(
                        initialVideoId: youtubeId,
                        flags: const YoutubePlayerFlags(
                          autoPlay: true,
                          mute: false,
                        ),
                      ),
                      showVideoProgressIndicator: true,
                      progressIndicatorColor: AppTheme.accent,
                    )
                  : _buildThumbnail(youtubeId, exercise.id),
            )
          else if (exercise.imagePath != null && exercise.imagePath!.isNotEmpty)
            Image.network(
              exercise.imagePath!,
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        exercise.exerciseName,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: isCompleted ? AppTheme.accent : Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    Text(
                      '${exercise.sets} × ${exercise.minReps}-${exercise.maxReps}',
                      style: const TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                if (exercise.notes != null && exercise.notes!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    exercise.notes!,
                    style: const TextStyle(color: Colors.orangeAccent, fontSize: 13),
                  ),
                ],
                const SizedBox(height: 20),
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
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      foregroundColor: isCompleted ? Colors.white70 : AppTheme.accent,
                      side: BorderSide(color: isCompleted ? Colors.white24 : AppTheme.accent),
                    ),
                    child: Text(isCompleted ? 'COMPLETED' : 'MARK AS DONE',
                        style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThumbnail(String youtubeId, String exerciseId) {
    final imageUrl = 'https://img.youtube.com/vi/$youtubeId/hqdefault.jpg';
    
    // Attempt to evict from memory cache immediately
    try {
       NetworkImage(imageUrl).evict();
    } catch (_) {}

    return GestureDetector(
      onTap: () {
        setState(() {
          _activeVideoExerciseId = exerciseId;
        });
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.network(
            imageUrl,
            height: 220,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              height: 220,
              color: Colors.white10,
              child: const Icon(Icons.broken_image, color: Colors.white24),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.accent.withOpacity(0.9),
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 10)],
            ),
            child: const Icon(Icons.play_arrow_rounded, size: 44, color: Colors.black),
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
