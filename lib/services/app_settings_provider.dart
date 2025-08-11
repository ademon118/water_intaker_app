import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
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
      state = settings;
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

  Future<void> updateTheme(bool isDarkMode) async {
    try {
      await UserSettingsService.updateAppearance(isDarkMode);
      state = state.copyWith(isDarkMode: isDarkMode);
    } catch (e) {
      print('Error updating theme: $e');
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

  // Get current theme mode
  ThemeMode getThemeMode() {
    return state.isDarkMode ? ThemeMode.dark : ThemeMode.light;
  }
}

// Theme provider for MaterialApp
final themeProvider = Provider<ThemeData>((ref) {
  final settings = ref.watch(appSettingsProvider);
  return _buildTheme(settings.isDarkMode);
});

ThemeData _buildTheme(bool isDarkMode) {
  if (isDarkMode) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF00B4D8),
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
      cardColor: const Color(0xFF1E1E1E),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
      ),
      // Add more comprehensive dark theme colors
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF1E1E1E),
        selectedItemColor: Color(0xFF00B4D8),
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: TextStyle(color: Colors.white),
        unselectedLabelStyle: TextStyle(color: Colors.grey),
      ),
      // Define text colors for dark mode
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.white),
        bodyMedium: TextStyle(color: Colors.white),
        bodySmall: TextStyle(color: Colors.white70),
        titleLarge: TextStyle(color: Colors.white),
        titleMedium: TextStyle(color: Colors.white),
        titleSmall: TextStyle(color: Colors.white),
      ),
      // Define icon colors for dark mode
      iconTheme: const IconThemeData(
        color: Colors.white,
      ),
    );
  } else {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF00B4D8),
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: const Color(0xFFF1F5F9),
      cardColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      // Add more comprehensive light theme colors
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: Color(0xFF4A90E2),
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: TextStyle(color: Colors.black87),
        unselectedLabelStyle: TextStyle(color: Colors.grey),
      ),
      // Define text colors for light mode
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.black87),
        bodyMedium: TextStyle(color: Colors.black87),
        bodySmall: TextStyle(color: Colors.black54),
        titleLarge: TextStyle(color: Colors.black87),
        titleMedium: TextStyle(color: Colors.black87),
        titleSmall: TextStyle(color: Colors.black87),
      ),
      // Define icon colors for light mode
      iconTheme: const IconThemeData(
        color: Colors.black87,
      ),
    );
  }
}
