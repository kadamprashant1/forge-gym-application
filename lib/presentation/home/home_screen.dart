import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:forge/app/theme.dart';
import 'package:forge/presentation/providers/workout_provider.dart';
import 'package:forge/domain/entities/workout_day.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutDaysAsync = ref.watch(workoutDaysProvider);

    return Scaffold(
      body: CustomScrollView(
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
              const Padding(
                padding: EdgeInsets.only(right: 16),
                child: Center(child: Text('7', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.accent))),
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
                  Text('Weekly Routine', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  workoutDaysAsync.when(
                    data: (days) => days.isEmpty 
                      ? _buildEmptyState(context)
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
                            return _buildPlanCard(context, day);
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
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return const Center(
      child: Column(
        children: [
          Icon(Icons.fitness_center, size: 64, color: AppTheme.textMuted),
          SizedBox(height: 16),
          Text('No workout plans found. Refresh the app to load defaults.'),
        ],
      ),
    );
  }

  Widget _buildCurrentDayCard(BuildContext context, WidgetRef ref) {
    final workoutDaysAsync = ref.watch(workoutDaysProvider);
    
    return workoutDaysAsync.maybeWhen(
      data: (days) {
        if (days.isEmpty) return const SizedBox.shrink();
        
        final now = DateTime.now();
        final weekdayIndex = now.weekday - 1;
        final currentDay = days.firstWhere(
          (d) => d.scheduledDay == weekdayIndex,
          orElse: () => days.first,
        );

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.accent.withOpacity(0.2), AppTheme.surface],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.accent.withOpacity(0.5), width: 1.5),
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
                      Text('TODAY\'S SESSION', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppTheme.accent, letterSpacing: 1.2)),
                      const SizedBox(height: 4),
                      Text(currentDay.name, style: Theme.of(context).textTheme.headlineMedium),
                    ],
                  ),
                  const Icon(Icons.play_circle_fill, size: 48, color: AppTheme.accent),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                currentDay.targetMuscles.join(' • '),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.push('/workout/${currentDay.id}'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 54),
                  backgroundColor: AppTheme.accent,
                ),
                child: const Text('START TRAINING', style: TextStyle(letterSpacing: 1.1)),
              ),
            ],
          ),
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }

  Widget _buildPlanCard(BuildContext context, WorkoutDay day) {
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
              Text(
                day.name,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                day.targetMuscles.take(2).join(', '),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              const Align(
                alignment: Alignment.bottomRight,
                child: Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.accent),
              ),
            ],
          ),
        ),
      ),
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
