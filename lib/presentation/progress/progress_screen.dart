import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:forge/app/theme.dart';
import 'package:forge/presentation/providers/workout_provider.dart';
import 'package:forge/domain/entities/workout_session.dart';
import 'package:forge/domain/entities/workout_day.dart';
import 'package:intl/intl.dart';

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
            : _buildContent(context, sessions, days),
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
          Text(
            'No Workouts Recorded',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 12),
          const Text('Start training to track your evolution!', style: TextStyle(color: AppTheme.textMuted)),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<WorkoutSession> sessions, List<WorkoutDay> days) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final sevenDaysAgo = today.subtract(const Duration(days: 6));
    
    // 1. DYNAMIC: Weekly Consistency (Includes auto-logged rest days)
    final weeklySessions = sessions.where((s) => s.date.isAfter(sevenDaysAgo)).toList();
    final uniqueDaysThisWeek = weeklySessions.map((s) => DateTime(s.date.year, s.date.month, s.date.day)).toSet().length;
    
    // Total days in the routine (usually 7)
    final int targetSessions = 7; 
    final double consistencyScore = (uniqueDaysThisWeek / targetSessions).clamp(0.0, 1.0);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Section: Weekly Consistency (NOW DYNAMIC)
        _buildSectionHeader(context, 'Weekly Consistency'),
        const SizedBox(height: 12),
        _buildWideStatCard(
          context, 
          'Current Week', 
          '${(consistencyScore * 100).toInt()}%', 
          consistencyScore,
          '$uniqueDaysThisWeek of $targetSessions days completed (including rest)'
        ),
        
        const SizedBox(height: 32),

        // Section: Volume Progression (Placeholder - Weight tracking is disabled)
        _buildSectionHeader(context, 'Volume Progress (Sample)'),
        const SizedBox(height: 16),
        _buildVolumeChart(context),

        const SizedBox(height: 32),

        // Section: Recent Personal Records (Placeholder - Weight tracking is disabled)
        _buildSectionHeader(context, 'Recent Personal Records (Sample)'),
        const SizedBox(height: 16),
        _buildPRTile(context, 'Flat Barbell Bench Press', '105 kg', '+5 kg'),
        _buildPRTile(context, 'Back Squat', '145 kg', '+10 kg'),
        _buildPRTile(context, 'Deadlift', '190 kg', 'New PR'),

        const SizedBox(height: 32),

        // Section: Recent Sessions (DYNAMIC)
        _buildSectionHeader(context, 'Recent Sessions'),
        const SizedBox(height: 16),
        ...sessions.take(5).map((session) {
          final day = days.firstWhere((d) => d.id == session.workoutDayId, orElse: () => days.first);
          return _buildHistoryTile(context, session, day);
        }),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
    );
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

  Widget _buildVolumeChart(BuildContext context) {
    return Container(
      height: 200,
      padding: const EdgeInsets.fromLTRB(16, 24, 24, 16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: const [
                FlSpot(0, 30),
                FlSpot(1, 35),
                FlSpot(2, 32),
                FlSpot(3, 40),
                FlSpot(4, 45),
                FlSpot(5, 42),
                FlSpot(6, 50),
              ],
              isCurved: true,
              color: AppTheme.accent,
              barWidth: 4,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: AppTheme.accent.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPRTile(BuildContext context, String exercise, String weight, String change) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.accent.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.emoji_events_rounded, color: AppTheme.accent, size: 20),
        ),
        title: Text(exercise, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: const Text('Estimated form & strength', style: TextStyle(fontSize: 12)),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(weight, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            Text(change, style: const TextStyle(color: AppTheme.success, fontSize: 11, fontWeight: FontWeight.bold)),
          ],
        ),
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
