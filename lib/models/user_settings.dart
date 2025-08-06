class UserSettings {
  final double dailyGoal;
  final bool reminderEnabled;
  final String reminderMode;
  final int snoozeDuration;
  final DateTime? lastReminderTime;

  UserSettings({
    required this.dailyGoal,
    required this.reminderEnabled,
    required this.reminderMode,
    required this.snoozeDuration,
    this.lastReminderTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'dailyGoal': dailyGoal,
      'reminderEnabled': reminderEnabled,
      'reminderMode': reminderMode,
      'snoozeDuration': snoozeDuration,
      'lastReminderTime': lastReminderTime?.millisecondsSinceEpoch,
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
    );
  }

  UserSettings copyWith({
    double? dailyGoal,
    bool? reminderEnabled,
    String? reminderMode,
    int? snoozeDuration,
    DateTime? lastReminderTime,
  }) {
    return UserSettings(
      dailyGoal: dailyGoal ?? this.dailyGoal,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderMode: reminderMode ?? this.reminderMode,
      snoozeDuration: snoozeDuration ?? this.snoozeDuration,
      lastReminderTime: lastReminderTime ?? this.lastReminderTime,
    );
  }
} 