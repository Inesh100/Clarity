import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._(); // Private constructor for singleton
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  /// Initialize plugin and timezone
  Future<void> init() async {
    // Initialize timezone data
    tz.initializeTimeZones();

    try {
      final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(currentTimeZone));
    } catch (e) {
      tz.setLocalLocation(tz.getLocation('America/Port_of_Spain')); // fallback
    }

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();

    const initSettings =
        InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _plugin.initialize(initSettings);
  }

  /// Show an instant notification
  Future<void> showInstant({
    required int id,
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'instant_notification_channel_id',
      'Instant Notifications',
      channelDescription: 'Instant notification channel',
      importance: Importance.max,
      priority: Priority.high,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _plugin.show(id, title, body, details);
  }

  /// Schedule one-time notification
  Future<void> scheduleOneTime({
    required int id,
    required String title,
    required String body,
    required DateTime dateTime,
  }) async {
    final tzDateTime = tz.TZDateTime.from(dateTime, tz.local);

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tzDateTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'scheduled_channel',
          'Scheduled Notifications',
          channelDescription: 'One-time scheduled notifications',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: null,
    );
  }

  /// Schedule daily notification at given hour and minute
  Future<void> scheduleDaily({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_channel',
          'Daily Notifications',
          channelDescription: 'Daily recurring alerts',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Schedule weekly notification on a specific weekday, hour, and minute
  Future<void> scheduleWeekly({
    required int id,
    required String title,
    required String body,
    required int weekday,
    required int hour,
    required int minute,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    while (scheduledDate.weekday != weekday) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 7));
    }

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'weekly_channel',
          'Weekly Notifications',
          channelDescription: 'Weekly recurring alerts',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

 Future<void> scheduleMonthly({
  required int id,
  required String title,
  required String body,
  required int weekday, // 1 = Monday, 7 = Sunday
  required int hour,
  required int minute,
  required int weekOfMonth, // 1 = first week, 2 = second week, etc.
}) async {
  final now = tz.TZDateTime.now(tz.local); // Current local time

  // Start from the first day of the current month at the specified time
  tz.TZDateTime scheduledDate =
      tz.TZDateTime(tz.local, now.year, now.month, 1, hour, minute);

  // Count the number of weekdays until we reach the desired one in the month
  int weekdayCount = 0;
  while (true) {
    if (scheduledDate.weekday == weekday) {
      weekdayCount++;
      if (weekdayCount == weekOfMonth) break;
    }
    scheduledDate = scheduledDate.add(const Duration(days: 1));
  }

  // If the scheduled date has already passed, move to the same weekday next month
  if (scheduledDate.isBefore(now)) {
    scheduledDate = tz.TZDateTime(tz.local, now.year, now.month + 1, 1, hour, minute);
    weekdayCount = 0;
    while (true) {
      if (scheduledDate.weekday == weekday) {
        weekdayCount++;
        if (weekdayCount == weekOfMonth) break;
      }
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
  }

  // Schedule the notification
  await _plugin.zonedSchedule(
    id,
    title,
    body,
    scheduledDate,
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'monthly_channel',
        'Monthly Notifications',
        channelDescription: 'Monthly recurring alerts',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    ),
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime,
  );
}


  /// Cancel a specific notification by id
  Future<void> cancel(int id) async {
    await _plugin.cancel(id);
  }

  /// Cancel all notifications
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
