import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../models/user_settings.dart';
import 'user_settings_service.dart';

// Global app settings provider
final appSettingsProvider = StateNotifierProvider<AppSettingsNotifier, UserSettings>((ref) {
  return AppSettingsNotifier();
});

// App settings notifier that manages all app-wide settings
class AppSettingsNotifier extends StateNotifier<UserSettings> {
  AppSettingsNotifier() : super(UserSettings(
    dailyGoal: 2800.0,
    reminderEnabled: false,
    reminderMode: 'Off',
    snoozeDuration: 0,
    unit: 'ml',
    isDarkMode: false,
  )) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final settings = await UserSettingsService.loadSettings();
      // Force light mode — dark mode is no longer supported
      state = settings.copyWith(isDarkMode: false);
    } catch (e) {
      print('Error loading app settings: $e');
      // Keep default values
    }
  }

  Future<void> updateDailyGoal(double goal) async {
    try {
      await UserSettingsService.updateDailyGoal(goal);
      state = state.copyWith(dailyGoal: goal);
    } catch (e) {
      print('Error updating daily goal: $e');
    }
  }

  Future<void> updateUnit(String unit) async {
    try {
      await UserSettingsService.updateUnit(unit);
      state = state.copyWith(unit: unit);
    } catch (e) {
      print('Error updating unit: $e');
    }
  }

  Future<void> updateReminderSettings({
    bool? enabled,
    String? mode,
    int? snoozeDuration,
  }) async {
    try {
      await UserSettingsService.updateReminderSettings(
        enabled: enabled,
        mode: mode,
        snoozeDuration: snoozeDuration,
      );
      state = state.copyWith(
        reminderEnabled: enabled,
        reminderMode: mode,
        snoozeDuration: snoozeDuration,
      );
    } catch (e) {
      print('Error updating reminder settings: $e');
    }
  }

  // Unit conversion helpers
  double convertToDisplayUnit(double mlValue) {
    if (state.unit == 'oz') {
      return mlValue * 0.033814; // Convert ml to oz
    }
    return mlValue; // Return as ml
  }

  double convertFromDisplayUnit(double displayValue) {
    if (state.unit == 'oz') {
      return displayValue / 0.033814; // Convert oz to ml
    }
    return displayValue; // Return as ml
  }

  String getUnitLabel() {
    return state.unit;
  }

  String getUnitAbbreviation() {
    return state.unit == 'oz' ? 'oz' : 'ml';
  }
}

// Theme provider for MaterialApp
final themeProvider = Provider<ThemeData>((ref) {
  return AppTheme.light;
});
