import 'package:hive/hive.dart';

part 'user_settings.g.dart';

@HiveType(typeId: 4)
class UserSettings extends HiveObject {
  @HiveField(0)
  final String themeMode; // light, dark, system
  
  @HiveField(1)
  final String weightUnit; // kg, lbs
  
  @HiveField(2)
  final int restTimerDuration; // seconds
  
  @HiveField(3)
  final bool notificationsEnabled;

  UserSettings({
    this.themeMode = 'dark',
    this.weightUnit = 'kg',
    this.restTimerDuration = 90,
    this.notificationsEnabled = true,
  });
}
