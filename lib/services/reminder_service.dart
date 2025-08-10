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
    final intervalInMinutes = _getDurationInMinutes(snoozeDuration);
    
    // Get current time
    final now = DateTime.now();
    
    // Start time for reminders (8 AM today or tomorrow if it's already past 8 AM)
    DateTime startTime = DateTime(now.year, now.month, now.day, 8, 0);
    if (now.isAfter(startTime)) {
      // If it's already past 8 AM, start from tomorrow
      startTime = startTime.add(const Duration(days: 1));
    }
    
    // Calculate end time (10 PM)
    final endTime = DateTime(now.year, now.month, now.day, 22, 0);
    
    // Schedule recurring reminders throughout the day
    int notificationId = 1;
    DateTime currentTime = startTime;
    
    while (currentTime.isBefore(endTime)) {
      // Only schedule if the time hasn't passed today
      if (currentTime.isAfter(now)) {
        await _scheduleNotification(
          id: notificationId,
          title: 'Time to Hydrate! 💧',
          body: 'Stay healthy by drinking water regularly.',
          scheduledTime: currentTime,
          mode: mode,
        );
        notificationId++;
      }
      
      // Move to next reminder time
      currentTime = currentTime.add(Duration(minutes: intervalInMinutes));
    }
    
    // Also schedule reminders for the next 7 days
    for (int day = 1; day <= 7; day++) {
      final nextDayStart = startTime.add(Duration(days: day));
      currentTime = nextDayStart;
      
      while (currentTime.isBefore(nextDayStart.add(const Duration(hours: 14)))) { // 14 hours from 8 AM to 10 PM
        await _scheduleNotification(
          id: notificationId,
          title: 'Time to Hydrate! 💧',
          body: 'Stay healthy by drinking water regularly.',
          scheduledTime: currentTime,
          mode: mode,
        );
        notificationId++;
        
        // Move to next reminder time
        currentTime = currentTime.add(Duration(minutes: intervalInMinutes));
      }
    }
  }

  static int _getDurationInMinutes(int snoozeDuration) {
    switch (snoozeDuration) {
      case 0: return 30; // 0.5h = 30 minutes
      case 1: return 60; // 1h = 60 minutes
      case 2: return 90; // 1.5h = 90 minutes
      case 3: return 120; // 2h = 120 minutes
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
      autoCancel: true,
      ongoing: false,
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

  static Future<String> getPendingRemindersInfo() async {
    final pendingReminders = await getPendingReminders();
    if (pendingReminders.isEmpty) {
      return 'No pending reminders';
    }
    
    final now = DateTime.now();
    final nextReminder = pendingReminders.first;
    // Note: PendingNotificationRequest doesn't have scheduledDate property
    // We'll return a generic message for now
    return '${pendingReminders.length} reminders scheduled';
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