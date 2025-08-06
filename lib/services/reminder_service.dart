import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class ReminderService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize timezone
    tz.initializeTimeZones();

    // Initialize notifications
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(initSettings);
    _isInitialized = true;
  }

  static Future<void> scheduleReminder({
    required String mode,
    required int snoozeDuration,
  }) async {
    if (!_isInitialized) await initialize();

    // Cancel existing reminders
    await cancelAllReminders();

    if (mode == 'Off') {
      return; // Don't schedule if mode is Off
    }

    // Calculate reminder intervals based on snooze duration
    final durationInMinutes = _getDurationInMinutes(snoozeDuration);
    
    // Schedule multiple reminders throughout the day
    final now = DateTime.now();
    final startTime = DateTime(now.year, now.month, now.day, 8, 0); // Start at 8 AM
    
    // Schedule reminders every 2-3 hours during waking hours
    final reminderTimes = [
      startTime,
      startTime.add(const Duration(hours: 2)),
      startTime.add(const Duration(hours: 4)),
      startTime.add(const Duration(hours: 6)),
      startTime.add(const Duration(hours: 8)),
      startTime.add(const Duration(hours: 10)),
    ];

    for (int i = 0; i < reminderTimes.length; i++) {
      final reminderTime = reminderTimes[i];
      
      // Only schedule if the time hasn't passed today
      if (reminderTime.isAfter(now)) {
        await _scheduleNotification(
          id: i + 1,
          title: 'Time to Hydrate! 💧',
          body: 'Stay healthy by drinking water regularly.',
          scheduledTime: reminderTime,
          mode: mode,
        );
      }
    }
  }

  static int _getDurationInMinutes(int snoozeDuration) {
    switch (snoozeDuration) {
      case 0: return 30; // 0.5h
      case 1: return 60; // 1h
      case 2: return 90; // 1.5h
      case 3: return 120; // 2h
      default: return 60;
    }
  }

  static Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    required String mode,
  }) async {
    final tz.TZDateTime scheduledTZDate = tz.TZDateTime.from(scheduledTime, tz.local);

    const androidDetails = AndroidNotificationDetails(
      'water_reminder_channel',
      'Water Reminders',
      channelDescription: 'Reminders to drink water',
      importance: Importance.high,
      priority: Priority.high,
      sound: RawResourceAndroidNotificationSound('notification_sound'),
      playSound: true,
      enableVibration: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      scheduledTZDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> cancelAllReminders() async {
    await _notifications.cancelAll();
  }

  static Future<void> cancelReminder(int id) async {
    await _notifications.cancel(id);
  }

  static Future<List<PendingNotificationRequest>> getPendingReminders() async {
    return await _notifications.pendingNotificationRequests();
  }

  static Future<void> showTestNotification() async {
    if (!_isInitialized) await initialize();

    const androidDetails = AndroidNotificationDetails(
      'water_reminder_channel',
      'Water Reminders',
      channelDescription: 'Reminders to drink water',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      999, // Test notification ID
      'Test Reminder 💧',
      'This is a test notification for water intake reminder.',
      details,
    );
  }

  static Future<bool> areNotificationsEnabled() async {
    if (!_isInitialized) await initialize();
    
    final bool? result = await _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()?.areNotificationsEnabled();
    
    return result ?? false;
  }

  static Future<void> requestPermissions() async {
    if (!_isInitialized) await initialize();
    
    await _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
  }
} 