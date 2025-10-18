import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    tzdata.initializeTimeZones();
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const settings = InitializationSettings(android: androidSettings, iOS: iosSettings);
    await _plugin.initialize(settings, onDidReceiveNotificationResponse: (resp) {
      // optionally handle tap
    });
  }

  static NotificationDetails _defaultDetails() {
    const androidDetails = AndroidNotificationDetails(
      'default_channel', 'General Notifications',
      importance: Importance.max, priority: Priority.high);
    const iosDetails = DarwinNotificationDetails();
    return const NotificationDetails(android: androidDetails, iOS: iosDetails);
  }

  static tz.TZDateTime _nextInstance(int hour, int minute, {int? weekday}) {
    final now = tz.TZDateTime.now(tz.local);
    if (weekday != null) {
      tz.TZDateTime scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
      while (scheduled.weekday != weekday || scheduled.isBefore(now)) {
        scheduled = scheduled.add(const Duration(days: 1));
      }
      return scheduled;
    } else {
      tz.TZDateTime scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
      if (scheduled.isBefore(now)) scheduled = scheduled.add(const Duration(days: 1));
      return scheduled;
    }
  }

  static Future<void> showNow({required int id, required String title, required String body}) =>
      _plugin.show(id, title, body, _defaultDetails());

  static Future<void> scheduleDaily({required String id, required String title, required String body, required int hour, required int minute}) async {
    final scheduled = _nextInstance(hour, minute);
      await _plugin.zonedSchedule(
        id.hashCode, title, body, scheduled, _defaultDetails(),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time);
  }

  static Future<void> scheduleWeekly({
    required String id, required String title, required String body,
    required int weekday, required int hour, required int minute}) async {
    final scheduled = _nextInstance(hour, minute, weekday: weekday);
      await _plugin.zonedSchedule(
        id.hashCode, title, body, scheduled, _defaultDetails(),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime);
  }

  static Future<void> cancel(String id) => _plugin.cancel(id.hashCode);
  static Future<void> cancelAll() => _plugin.cancelAll();
}
