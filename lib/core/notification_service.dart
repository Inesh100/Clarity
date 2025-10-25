import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  /// Initialize notifications and timezone
  static Future<void> initialize() async {
    await _configureLocalTimeZone();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const settings =
        InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (resp) {},
    );
  }

  /// Configure timezone using flutter_timezone 5.0.0
 static Future<void> _configureLocalTimeZone() async {
  tzdata.initializeTimeZones();

  final timezoneInfo = await FlutterTimezone.getLocalTimezone();
  final String timeZoneName = timezoneInfo.identifier; // <-- use .identifier
  tz.setLocalLocation(tz.getLocation(timeZoneName));
}

  /// Default notification details
  static NotificationDetails _defaultDetails() {
    const androidDetails = AndroidNotificationDetails(
      'default_channel',
      'General Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    return const NotificationDetails(android: androidDetails, iOS: iosDetails);
  }

  /// Calculate next instance for daily/weekly notifications
  static tz.TZDateTime _nextInstance(int hour, int minute, {int? weekday}) {
    final now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    if (weekday != null) {
      while (scheduled.weekday != weekday || scheduled.isBefore(now)) {
        scheduled = scheduled.add(const Duration(days: 1));
      }
    } else if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    return scheduled;
  }

  /// Show immediate notification
  static Future<void> showNow({
    required int id,
    required String title,
    required String body,
  }) async {
    await _plugin.show(id, title, body, _defaultDetails());
  }

  /// Schedule a daily notification
  static Future<void> scheduleDaily({
    required String id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    final scheduled = _nextInstance(hour, minute);
    await _plugin.zonedSchedule(
      id.hashCode,
      title,
      body,
      scheduled,
      _defaultDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Schedule a weekly notification
  static Future<void> scheduleWeekly({
    required String id,
    required String title,
    required String body,
    required int weekday,
    required int hour,
    required int minute,
  }) async {
    final scheduled = _nextInstance(hour, minute, weekday: weekday);
    await _plugin.zonedSchedule(
      id.hashCode,
      title,
      body,
      scheduled,
      _defaultDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  /// Cancel a notification by ID
  static Future<void> cancel(String id) => _plugin.cancel(id.hashCode);

  /// Cancel all notifications
  static Future<void> cancelAll() => _plugin.cancelAll();
}
