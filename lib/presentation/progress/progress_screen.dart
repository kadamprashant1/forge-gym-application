import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:forge/app/theme.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildStatCard(context, 'Weekly Consistency', '67%', 0.67),
          const SizedBox(height: 24),
          _buildSectionHeader(context, 'Volume Progression'),
          const SizedBox(height: 16),
          _buildVolumeChart(context),
          const SizedBox(height: 24),
          _buildSectionHeader(context, 'Recent Personal Records'),
          const SizedBox(height: 16),
          _buildPRTile(context, 'Bench Press', '100kg', '+5kg'),
          _buildPRTile(context, 'Squat', '120kg', '+10kg'),
          _buildPRTile(context, 'Deadlift', '150kg', '+0kg'),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, double progress) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppTheme.accent)),
                const SizedBox(width: 16),
                Expanded(
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: AppTheme.surfaceVariant,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accent),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text('4 of 6 workouts completed this week', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }

  Widget _buildVolumeChart(BuildContext context) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: const [
                FlSpot(0, 3),
                FlSpot(1, 1),
                FlSpot(2, 4),
                FlSpot(3, 2),
                FlSpot(4, 5),
                FlSpot(5, 3),
                FlSpot(6, 4),
              ],
              isCurved: true,
              color: AppTheme.accent,
              barWidth: 4,
              isStrokeCapRound: true,
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
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: AppTheme.accentMuted,
          child: Icon(Icons.emoji_events, color: AppTheme.accent, size: 20),
        ),
        title: Text(exercise),
        subtitle: Text('Last updated: Dec 25'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(weight, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text(change, style: const TextStyle(color: AppTheme.success, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
