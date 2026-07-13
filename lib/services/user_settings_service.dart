import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_settings.dart';

class UserSettingsService {
  static const String _settingsKey = 'user_settings';
  
  static Future<UserSettings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = prefs.getString(_settingsKey);
    
    if (settingsJson != null) {
      try {
        final json = jsonDecode(settingsJson) as Map<String, dynamic>;
        return UserSettings.fromJson(json);
      } catch (e) {
        // If parsing fails, return default settings
        return UserSettings(
          dailyGoal: 2800.0,
          reminderEnabled: false,
          reminderMode: 'Off',
          snoozeDuration: 1,
        );
      }
    }
    
    // Return default settings if none exist
    return UserSettings(
      dailyGoal: 2800.0,
      reminderEnabled: false,
      reminderMode: 'Off',
      snoozeDuration: 1,
    );
  }

  static Future<void> saveSettings(UserSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = jsonEncode(settings.toJson());
    await prefs.setString(_settingsKey, settingsJson);
  }

  static Future<void> updateDailyGoal(double goal) async {
    final settings = await loadSettings();
    final updatedSettings = settings.copyWith(dailyGoal: goal);
    await saveSettings(updatedSettings);
  }

  static Future<void> updateReminderSettings({
    bool? enabled,
    String? mode,
    int? snoozeDuration,
  }) async {
    final settings = await loadSettings();
    final updatedSettings = settings.copyWith(
      reminderEnabled: enabled,
      reminderMode: mode,
      snoozeDuration: snoozeDuration,
    );
    await saveSettings(updatedSettings);
  }

  static Future<void> updateLastReminderTime(DateTime time) async {
    final settings = await loadSettings();
    final updatedSettings = settings.copyWith(lastReminderTime: time);
    await saveSettings(updatedSettings);
  }

  static Future<void> updateUnit(String unit) async {
    final settings = await loadSettings();
    final updatedSettings = settings.copyWith(unit: unit);
    await saveSettings(updatedSettings);
  }

  static Future<void> updateAppearance(bool isDarkMode) async {
    final settings = await loadSettings();
    final updatedSettings = settings.copyWith(isDarkMode: isDarkMode);
    await saveSettings(updatedSettings);
  }
} 