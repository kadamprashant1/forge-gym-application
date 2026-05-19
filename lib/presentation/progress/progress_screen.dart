import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:forge/app/theme.dart';
import 'package:forge/presentation/providers/workout_provider.dart';
import 'package:forge/domain/entities/workout_session.dart';
import 'package:forge/domain/entities/workout_day.dart';
import 'package:forge/domain/entities/exercise.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(workoutHistoryProvider);
    final daysAsync = ref.watch(workoutDaysProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Training Progress'),
        centerTitle: true,
      ),
      body: historyAsync.when(
        data: (sessions) => daysAsync.when(
          data: (days) => sessions.isEmpty 
            ? _buildEmptyState(context) 
            : _buildContent(context, ref, sessions, days),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Error loading routine: $err')),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error loading history: $err')),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.insights_rounded, size: 80, color: AppTheme.textMuted.withOpacity(0.2)),
          const SizedBox(height: 20),
          const Text('No Workouts Recorded', style: TextStyle(color: AppTheme.textSecondary, fontSize: 18)),
          const SizedBox(height: 12),
          const Text('Start training to track your evolution!', style: TextStyle(color: AppTheme.textMuted)),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, List<WorkoutSession> sessions, List<WorkoutDay> days) {
    // Mock volume data for now as per the comment below
    final volumeData = [12000.0, 14500.0, 13200.0, 15800.0, 14900.0, 16200.0, 17500.0];

    // Calculate Current Week Consistency
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final weekStart = DateTime(monday.year, monday.month, monday.day);
    
    final trainingDays = days.where((d) => d.workoutType != 'rest').toList();
    final trainingDayIds = trainingDays.map((d) => d.id).toSet();
    
    final sessionsThisWeek = sessions.where((s) => 
      s.date.isAfter(weekStart.subtract(const Duration(seconds: 1))) && 
      trainingDayIds.contains(s.workoutDayId)
    ).toList();
    
    final completedDaysCount = sessionsThisWeek.map((s) => s.workoutDayId).toSet().length;
    final totalTrainingDays = trainingDays.length;
    final consistencyPercent = totalTrainingDays > 0 ? completedDaysCount / totalTrainingDays : 0.0;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // 1. Weekly Consistency (Dynamic)
        _buildSectionHeader(context, 'Weekly Consistency'),
        const SizedBox(height: 12),
        _buildWideStatCard(
          context, 
          'Current Week', 
          '${(consistencyPercent * 100).toInt()}%', 
          consistencyPercent,
          '$completedDaysCount of $totalTrainingDays training days completed'
        ),
        
        const SizedBox(height: 32),

        // 2. Volume Progression (Hardcoded Chart - will be dynamic once exercise logs are integrated)
        _buildSectionHeader(context, 'Volume Progress'),
        const SizedBox(height: 16),
        _buildVolumeChart(context, volumeData),

        const SizedBox(height: 32),

        // 3. Recent Personal Records (Placeholder)
        _buildSectionHeader(context, 'Recent Personal Records'),
        const SizedBox(height: 16),
        _buildHighlightTile(context, 'Flat Barbell Bench Press', 'Log weight to see PRs', Icons.emoji_events_rounded),
        _buildHighlightTile(context, 'Back Squat', 'Log weight to see PRs', Icons.emoji_events_rounded),

        const SizedBox(height: 32),
        _buildSectionHeader(context, 'Recent History'),
        const SizedBox(height: 16),
        ...sessions.take(15).map((session) {
          final day = days.firstWhere((d) => d.id == session.workoutDayId, orElse: () => days.first);
          return _buildHistoryExpansionTile(context, ref, session, day);
        }),
      ],
    );
  }

  Widget _buildHistoryExpansionTile(BuildContext context, WidgetRef ref, WorkoutSession session, WorkoutDay day) {
    final isRest = day.workoutType == 'rest';
    final exercisesAsync = ref.watch(exercisesProvider(day.id));

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ExpansionTile(
        shape: const RoundedRectangleBorder(side: BorderSide.none),
        leading: CircleAvatar(
          backgroundColor: isRest ? Colors.blue.withOpacity(0.1) : AppTheme.accent.withOpacity(0.1),
          child: Icon(isRest ? Icons.hotel : Icons.check, color: isRest ? Colors.blue : AppTheme.accent, size: 18),
        ),
        title: Text(day.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(DateFormat('EEE, MMM d').format(session.date)),
        trailing: Text(isRest ? 'Rest' : '${session.durationMinutes}m', style: const TextStyle(color: AppTheme.textMuted)),
        children: [
          if (!isRest)
            exercisesAsync.maybeWhen(
              data: (exercises) => Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  children: exercises.map((e) => _buildHistoryExerciseItem(e)).toList(),
                ),
              ),
              orElse: () => const SizedBox.shrink(),
            ),
        ],
      ),
    );
  }

  Widget _buildHistoryExerciseItem(Exercise exercise) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(exercise.exerciseName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                Text('${exercise.sets} sets • ${exercise.minReps}-${exercise.maxReps} reps', 
                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
              ],
            ),
          ),
          if (exercise.videoUrl != null)
            IconButton(
              icon: const Icon(Icons.play_circle_fill, color: AppTheme.accent, size: 28),
              onPressed: () => launchUrl(Uri.parse(exercise.videoUrl!)),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 0.5));
  }

  Widget _buildWideStatCard(BuildContext context, String title, String value, double progress, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary)),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppTheme.accent, fontWeight: FontWeight.bold)),
              const SizedBox(width: 20),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white.withOpacity(0.05),
                    valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accent),
                    minHeight: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.textMuted)),
        ],
      ),
    );
  }

  Widget _buildVolumeChart(BuildContext context, List<double> volumeData) {
    double maxVolume = volumeData.isEmpty ? 10.0 : volumeData.reduce((a, b) => a > b ? a : b);
    if (maxVolume == 0) maxVolume = 10.0;
    return Container(
      height: 200,
      padding: const EdgeInsets.fromLTRB(16, 24, 24, 16),
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(20)),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                  final now = DateTime.now();
                  final date = now.subtract(Duration(days: 6 - value.toInt()));
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(days[date.weekday - 1], style: const TextStyle(color: AppTheme.textMuted, fontSize: 10)),
                  );
                },
              ),
            ),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          minY: 0,
          maxY: maxVolume * 1.2,
          lineBarsData: [
            LineChartBarData(
              spots: volumeData.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
              isCurved: true,
              color: AppTheme.accent,
              barWidth: 4,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(show: true, color: AppTheme.accent.withOpacity(0.1)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHighlightTile(BuildContext context, String title, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: AppTheme.accent.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, color: AppTheme.accent, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
        trailing: Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      ),
    );
  }

  Widget _buildHistoryTile(BuildContext context, WorkoutSession session, WorkoutDay day) {
    final isRest = day.workoutType == 'rest';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isRest ? Colors.blue.withOpacity(0.1) : AppTheme.accent.withOpacity(0.1),
          child: Icon(isRest ? Icons.hotel : Icons.check, color: isRest ? Colors.blue : AppTheme.accent, size: 18),
        ),
        title: Text(day.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(DateFormat('EEE, MMM d').format(session.date)),
        trailing: Text(isRest ? 'Rest' : '${session.durationMinutes}m', style: const TextStyle(color: AppTheme.textMuted)),
      ),
    );
  }
}
