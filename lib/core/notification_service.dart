// core/notification_service.dart
import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin plugin = FlutterLocalNotificationsPlugin();

  /// Initialize plugin and timezone
  Future<void> init() async {
    tz.initializeTimeZones();
    try {
      final current = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(current));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('America/Port_of_Spain'));
    }

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const settings = InitializationSettings(android: androidInit, iOS: iosInit);

    await plugin.initialize(settings);

    // Android runtime permission (Android 13+)
    if (Platform.isAndroid) {
      final androidPlugin = plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        // For some plugin versions this method exists; call if available.
        try {
          await androidPlugin.requestNotificationsPermission();
        } catch (_) {
          // ignore if not available; runtime permission handled elsewhere
        }
      }
    }
  }

  NotificationDetails _details(String id, String name, String description) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        id,
        name,
        channelDescription: description,
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
      ),
      iOS: DarwinNotificationDetails(),
    );
  }

  /// Show instant notification
  Future<void> showInstant({
    required int id,
    required String title,
    required String body,
  }) async {
    await plugin.show(id, title, body, _details('instant', 'Instant', 'Immediate alerts'));
  }

  /// Schedule one-time notification (DateTime in local tz)
  Future<void> scheduleOneTime({
    required int id,
    required String title,
    required String body,
    required DateTime dateTime,
  }) async {
    final schedule = tz.TZDateTime.from(dateTime, tz.local);
    await plugin.zonedSchedule(
      id,
      title,
      body,
      schedule,
      _details('once', 'One-Time', 'One-time reminders'),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  /// Schedule daily notification
  Future<void> scheduleDaily({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var schedule = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (schedule.isBefore(now)) schedule = schedule.add(const Duration(days: 1));

    await plugin.zonedSchedule(
      id,
      title,
      body,
      schedule,
      _details('daily', 'Daily', 'Daily reminders'),
      matchDateTimeComponents: DateTimeComponents.time,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  /// Schedule weekly notification (weekday: 1 = Monday, 7 = Sunday)
  Future<void> scheduleWeekly({
    required int id,
    required String title,
    required String body,
    required int weekday,
    required int hour,
    required int minute,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime schedule = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    while (schedule.weekday != weekday) {
      schedule = schedule.add(const Duration(days: 1));
    }
    if (schedule.isBefore(now)) schedule = schedule.add(const Duration(days: 7));

    await plugin.zonedSchedule(
      id,
      title,
      body,
      schedule,
      _details('weekly', 'Weekly', 'Weekly reminders'),
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  /// Schedule monthly notification using nth weekday or a specific date.
  /// If using nth weekday scheduling, provide weekday & weekOfMonth and it will pick the Nth weekday.
  Future<void> scheduleMonthly({
    required int id,
    required String title,
    required String body,
    required int weekday,
    required int hour,
    required int minute,
    required int weekOfMonth,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime schedule = tz.TZDateTime(tz.local, now.year, now.month, 1, hour, minute);

    int count = 0;
    while (true) {
      if (schedule.weekday == weekday) {
        count++;
        if (count == weekOfMonth) break;
      }
      schedule = schedule.add(const Duration(days: 1));
    }

    if (schedule.isBefore(now)) {
      // next month
      schedule = tz.TZDateTime(tz.local, now.year, now.month + 1, 1, hour, minute);
      int c = 0;
      while (true) {
        if (schedule.weekday == weekday) {
          c++;
          if (c == weekOfMonth) break;
        }
        schedule = schedule.add(const Duration(days: 1));
      }
    }

    await plugin.zonedSchedule(
      id,
      title,
      body,
      schedule,
      _details('monthly', 'Monthly', 'Monthly reminders'),
      matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> cancel(int id) async => plugin.cancel(id);
  Future<void> cancelAll() async => plugin.cancelAll();
}
