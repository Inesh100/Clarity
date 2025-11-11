// core/notification_service.dart
import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../core/medicine_log_service.dart';

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

    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );

    await plugin.initialize(settings);

    if (Platform.isAndroid) {
      final androidPlugin = plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      try {
        await androidPlugin?.requestNotificationsPermission();
      } catch (_) {}
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

  /// -------------------
  /// GENERAL REMINDERS (no logs)
  /// -------------------

  Future<void> showInstant({
    required int id,
    required String title,
    required String body,
  }) async {
    await plugin.show(id, title, body, _details('instant', 'Instant', 'Immediate alerts'));
  }

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

  Future<void> scheduleDaily({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    var schedule = _nextDaily(hour, minute);
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

  Future<void> scheduleWeekly({
    required int id,
    required String title,
    required String body,
    required int weekday,
    required int hour,
    required int minute,
  }) async {
    var schedule = _nextWeekly(weekday, hour, minute);
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

  Future<void> scheduleMonthly({
    required int id,
    required String title,
    required String body,
    required int weekday,
    required int hour,
    required int minute,
    required int weekOfMonth,
  }) async {
    var schedule = _nextMonthly(weekday, hour, minute, weekOfMonth);
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

  /// -------------------
  /// MEDICINE NOTIFICATIONS (with logs)
  /// -------------------

  Future<void> scheduleDailyMedicineReminder({
    required String logId,
    required String medicineId,
    required String userId,
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    var schedule = _nextDaily(hour, minute);

    await plugin.zonedSchedule(
      logId.hashCode,
      title,
      body,
      schedule,
      _details('daily', 'Daily', 'Daily medicine reminders'),
      payload: logId,
      matchDateTimeComponents: DateTimeComponents.time,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );

    await MedicineLogService.instance.createLog(
      logId: logId,
      medicineId: medicineId,
      userId: userId,
      scheduledTime: schedule,
    );

    Future.delayed(const Duration(minutes: 30), () async {
      await MedicineLogService.instance.markMissed(logId);
    });
  }

  Future<void> scheduleWeeklyMedicineReminder({
    required String logId,
    required String medicineId,
    required String userId,
    required int weekday,
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    var schedule = _nextWeekly(weekday, hour, minute);

    await plugin.zonedSchedule(
      logId.hashCode,
      title,
      body,
      schedule,
      _details('weekly', 'Weekly', 'Weekly medicine reminders'),
      payload: logId,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );

    await MedicineLogService.instance.createLog(
      logId: logId,
      medicineId: medicineId,
      userId: userId,
      scheduledTime: schedule,
    );

    Future.delayed(const Duration(minutes: 30), () async {
      await MedicineLogService.instance.markMissed(logId);
    });
  }

  Future<void> scheduleMonthlyMedicineReminder({
    required String logId,
    required String medicineId,
    required String userId,
    required int weekday,
    required int hour,
    required int minute,
    required int weekOfMonth,
    required String title,
    required String body,
  }) async {
    var schedule = _nextMonthly(weekday, hour, minute, weekOfMonth);

    await plugin.zonedSchedule(
      logId.hashCode,
      title,
      body,
      schedule,
      _details('monthly', 'Monthly', 'Monthly medicine reminders'),
      payload: logId,
      matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );

    await MedicineLogService.instance.createLog(
      logId: logId,
      medicineId: medicineId,
      userId: userId,
      scheduledTime: schedule,
    );

    Future.delayed(const Duration(minutes: 30), () async {
      await MedicineLogService.instance.markMissed(logId);
    });
  }

  /// -------------------
  /// HELPERS
  /// -------------------

  tz.TZDateTime _nextDaily(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var schedule = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (schedule.isBefore(now)) schedule = schedule.add(const Duration(days: 1));
    return schedule;
  }

  tz.TZDateTime _nextWeekly(int weekday, int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var schedule = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    while (schedule.weekday != weekday) schedule = schedule.add(const Duration(days: 1));
    if (schedule.isBefore(now)) schedule = schedule.add(const Duration(days: 7));
    return schedule;
  }

  tz.TZDateTime _nextMonthly(int weekday, int hour, int minute, int weekOfMonth) {
    final now = tz.TZDateTime.now(tz.local);
    var schedule = tz.TZDateTime(tz.local, now.year, now.month, 1, hour, minute);
    int count = 0;
    while (true) {
      if (schedule.weekday == weekday) {
        count++;
        if (count == weekOfMonth) break;
      }
      schedule = schedule.add(const Duration(days: 1));
    }

    if (schedule.isBefore(now)) {
      schedule = tz.TZDateTime(tz.local, now.year, now.month + 1, 1, hour, minute);
      int count2 = 0;
      while (true) {
        if (schedule.weekday == weekday) {
          count2++;
          if (count2 == weekOfMonth) break;
        }
        schedule = schedule.add(const Duration(days: 1));
      }
    }

    return schedule;
  }

  Future<void> cancel(int id) async => plugin.cancel(id);
  Future<void> cancelAll() async => plugin.cancelAll();

  /// -------------------
/// DEBUG TEST NOTIFICATIONS
/// -------------------
Future<void> showTestNotification(String title, String body) async {
  await plugin.show(
    DateTime.now().millisecondsSinceEpoch ~/ 1000, // unique id
    title,
    body,
    _details('test', 'Test Notifications', 'Debugging test notifications'),
  );
}

}
