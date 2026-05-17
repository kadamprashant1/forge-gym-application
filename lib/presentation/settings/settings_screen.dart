import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forge/app/theme.dart';
import 'package:forge/data/datasources/parser/workout_parser.dart';
import 'package:forge/domain/repositories/workout_repository.dart';
import 'package:forge/di/injection.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader(context, 'APPEARANCE'),
          _buildSettingTile(
            icon: Icons.dark_mode,
            title: 'Dark Mode',
            trailing: Switch(value: true, onChanged: (val) {}, activeColor: AppTheme.accent),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader(context, 'WORKOUT PREFERENCES'),
          _buildSettingTile(
            icon: Icons.scale,
            title: 'Weight Unit',
            trailing: const Text('kg', style: TextStyle(color: AppTheme.accent)),
          ),
          _buildSettingTile(
            icon: Icons.timer,
            title: 'Rest Timer',
            trailing: const Text('90s', style: TextStyle(color: AppTheme.accent)),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader(context, 'DATA MANAGEMENT'),
          _buildSettingTile(
            icon: Icons.file_upload,
            title: 'Import Workout Plan',
            onTap: () => _showImportDialog(context),
          ),
          _buildSettingTile(
            icon: Icons.file_download,
            title: 'Export Data',
            onTap: () {},
          ),
          _buildSettingTile(
            icon: Icons.delete_forever,
            title: 'Clear History',
            titleColor: AppTheme.error,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppTheme.textMuted,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
    Color? titleColor,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: titleColor ?? AppTheme.textSecondary),
        title: Text(title, style: TextStyle(color: titleColor)),
        trailing: trailing ?? const Icon(Icons.chevron_right, color: AppTheme.textMuted),
        onTap: onTap,
      ),
    );
  }

  void _showImportDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import Workout Plan'),
        content: TextField(
          controller: controller,
          maxLines: 10,
          decoration: const InputDecoration(
            hintText: 'Paste your workout plan here...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          ElevatedButton(
            onPressed: () async {
              final parser = WorkoutParser();
              final result = parser.parse(controller.text);
              final repo = getIt<WorkoutRepository>();
              await repo.importWorkoutPlan(result['days'], result['exercises']);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Workout plan imported successfully!')),
                );
              }
            },
            child: const Text('IMPORT'),
          ),
        ],
      ),
    );
  }
}
