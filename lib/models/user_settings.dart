class UserSettings {
  final double dailyGoal;
  final bool reminderEnabled;
  final String reminderMode;
  final int snoozeDuration;
  final DateTime? lastReminderTime;
  final String unit;
  final bool isDarkMode;

  UserSettings({
    required this.dailyGoal,
    required this.reminderEnabled,
    required this.reminderMode,
    required this.snoozeDuration,
    this.lastReminderTime,
    this.unit = 'ml',
    this.isDarkMode = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'dailyGoal': dailyGoal,
      'reminderEnabled': reminderEnabled,
      'reminderMode': reminderMode,
      'snoozeDuration': snoozeDuration,
      'lastReminderTime': lastReminderTime?.millisecondsSinceEpoch,
      'unit': unit,
      'isDarkMode': isDarkMode,
    };
  }

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      dailyGoal: json['dailyGoal']?.toDouble() ?? 2800.0,
      reminderEnabled: json['reminderEnabled'] ?? false,
      reminderMode: json['reminderMode'] ?? 'Off',
      snoozeDuration: json['snoozeDuration'] ?? 0,
      lastReminderTime: json['lastReminderTime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['lastReminderTime'])
          : null,
      unit: json['unit'] ?? 'ml',
      isDarkMode: json['isDarkMode'] ?? false,
    );
  }

  UserSettings copyWith({
    double? dailyGoal,
    bool? reminderEnabled,
    String? reminderMode,
    int? snoozeDuration,
    DateTime? lastReminderTime,
    String? unit,
    bool? isDarkMode,
  }) {
    return UserSettings(
      dailyGoal: dailyGoal ?? this.dailyGoal,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderMode: reminderMode ?? this.reminderMode,
      snoozeDuration: snoozeDuration ?? this.snoozeDuration,
      lastReminderTime: lastReminderTime ?? this.lastReminderTime,
      unit: unit ?? this.unit,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }
} 