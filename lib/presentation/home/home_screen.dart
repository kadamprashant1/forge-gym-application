import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:forge/app/theme.dart';
import 'package:forge/presentation/providers/workout_provider.dart';
import 'package:forge/domain/entities/workout_day.dart';
import 'package:forge/domain/entities/exercise.dart';
import 'package:forge/data/datasources/local/default_workout_plan.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutDaysAsync = ref.watch(workoutDaysProvider);
    final streakCount = ref.watch(streakProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(workoutDaysProvider.future),
        color: AppTheme.accent,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 120,
              floating: true,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'Forge Fitness',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                centerTitle: false,
                titlePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.local_fire_department, color: AppTheme.accent),
                  onPressed: () {},
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Center(
                    child: Text(
                      streakCount.toString(),
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.accent),
                    ),
                  ),
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCurrentDayCard(context, ref),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Weekly Routine', style: Theme.of(context).textTheme.titleLarge),
                        TextButton.icon(
                          onPressed: () => _resetPlan(context, ref),
                          icon: const Icon(Icons.restore, size: 16),
                          label: const Text('Reset Plan', style: TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    workoutDaysAsync.when(
                      data: (days) => days.isEmpty 
                        ? _buildEmptyState(context, ref)
                        : GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                              childAspectRatio: 1.3,
                            ),
                            itemCount: days.length,
                            itemBuilder: (context, index) {
                              final day = days[index];
                              return _buildPlanCard(context, day, ref);
                            },
                          ),
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (err, stack) => Center(child: Text('Error: $err')),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Future<void> _resetPlan(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Workout Plan?'),
        content: const Text('This will restore the default PPL plan and include all video tutorials.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('CANCEL')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('RESET')),
        ],
      ),
    );

    if (confirmed == true) {
      final repo = ref.read(workoutRepositoryProvider);
      final plan = DefaultWorkoutPlan.getPlan();
      await repo.importWorkoutPlan(
        plan['days'] as List<WorkoutDay>,
        plan['exercises'] as List<Exercise>,
      );
      ref.invalidate(workoutDaysProvider);
    }
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        children: [
          const Icon(Icons.fitness_center, size: 64, color: AppTheme.textMuted),
          const SizedBox(height: 16),
          const Text('No workout plans found.', style: TextStyle(color: AppTheme.textSecondary)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _resetPlan(context, ref),
            icon: const Icon(Icons.download_rounded),
            label: const Text('LOAD DEFAULT PLAN'),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accent),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentDayCard(BuildContext context, WidgetRef ref) {
    final workoutDaysAsync = ref.watch(workoutDaysProvider);
    final historyAsync = ref.watch(workoutHistoryProvider);
    
    return workoutDaysAsync.maybeWhen(
      data: (days) {
        if (days.isEmpty) return const SizedBox.shrink();
        
        final now = DateTime.now();
        final weekdayIndex = now.weekday - 1; 
        final currentDay = days.firstWhere(
          (d) => d.scheduledDay == weekdayIndex,
          orElse: () => days.first,
        );

        final isSunday = now.weekday == DateTime.sunday;
        
        return historyAsync.maybeWhen(
          data: (sessions) {
            final today = DateTime(now.year, now.month, now.day);
            final isCompleted = sessions.any((s) => 
              s.date.year == today.year && s.date.month == today.month && s.date.day == today.day);

            return Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isCompleted 
                    ? [AppTheme.success.withOpacity(0.2), AppTheme.surface]
                    : [AppTheme.accent.withOpacity(0.2), AppTheme.surface],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isCompleted ? AppTheme.success.withOpacity(0.5) : AppTheme.accent.withOpacity(0.5), 
                  width: 1.5
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isCompleted ? 'COMPLETED' : 'TODAY\'S SESSION', 
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: isCompleted ? AppTheme.success : AppTheme.accent, 
                              letterSpacing: 1.2
                            )
                          ),
                          const SizedBox(height: 4),
                          Text(currentDay.name, style: Theme.of(context).textTheme.headlineMedium),
                        ],
                      ),
                      Icon(
                        isCompleted ? Icons.check_circle : (isSunday ? Icons.hotel : Icons.play_circle_fill),
                        size: 48, 
                        color: isCompleted ? AppTheme.success : AppTheme.accent
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isSunday ? 'Enjoy your mandatory rest day!' : currentDay.targetMuscles.join(' • '),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 24),
                  if (!isCompleted)
                    ElevatedButton(
                      onPressed: () => context.push('/workout/${currentDay.id}'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 54),
                        backgroundColor: AppTheme.accent,
                      ),
                      child: const Text('START TRAINING', style: TextStyle(letterSpacing: 1.1)),
                    )
                  else
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: AppTheme.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text(
                          'SESSION FINISHED', 
                          style: TextStyle(color: AppTheme.success, fontWeight: FontWeight.bold, letterSpacing: 1.1)
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
          orElse: () => const CircularProgressIndicator(),
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }

  Widget _buildPlanCard(BuildContext context, WorkoutDay day, WidgetRef ref) {
    final historyAsync = ref.watch(workoutHistoryProvider);
    
    return historyAsync.maybeWhen(
      data: (sessions) {
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final isToday = day.scheduledDay == (now.weekday - 1);
        final isCompleted = sessions.any((s) => 
          s.workoutDayId == day.id && 
          s.date.year == today.year && s.date.month == today.month && s.date.day == today.day);

        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: InkWell(
            onTap: () => context.push('/workout/${day.id}'),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        day.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isCompleted ? AppTheme.success : (isToday ? AppTheme.accent : Colors.white),
                        ),
                      ),
                      if (isCompleted)
                        const Icon(Icons.check_circle, size: 16, color: AppTheme.success),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    day.targetMuscles.take(2).join(', '),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Icon(Icons.arrow_forward_ios, size: 14, color: isToday ? AppTheme.accent : Colors.white24),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      orElse: () => const Card(),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppTheme.surface,
      selectedItemColor: AppTheme.accent,
      unselectedItemColor: AppTheme.textMuted,
      currentIndex: 0,
      onTap: (index) {
        if (index == 1) context.push('/progress');
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.analytics_rounded), label: 'Progress'),
      ],
    );
  }
}
