// viewmodels/reminders_vm.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:uuid/uuid.dart';
import 'package:timezone/timezone.dart' as tz;
import '../core/notification_service.dart';
import '../models/reminder_model.dart';
import '../repositories/reminder_repository.dart';

class RemindersViewModel extends ChangeNotifier {
  final _repo = ReminderRepository();

  Stream<List<Reminder>> streamReminders(String userId) => _repo.getRemindersForUser(userId);

  Future<void> addReminder({
    required BuildContext context,
    required String userId,
    required String title,
    required String description,
    required int hour,
    required int minute,
    String repeat = 'daily',
    int? weekday,
    DateTime? monthlyDate,
  }) async {
    // Request exact alarm intent on Android when needed (helper or settings typically handles this)
    if (Platform.isAndroid) {
      final intent = AndroidIntent(action: 'android.settings.REQUEST_SCHEDULE_EXACT_ALARM');
      try {
        await intent.launch();
      } catch (_) {}
    }

    final id = const Uuid().v4();
    final notificationId = id.hashCode;

    final r = Reminder(id: id, userId: userId, title: title, description: description, hour: hour, minute: minute);
    await _repo.addReminder(r);

    switch (repeat) {
      case 'weekly':
        if (weekday != null) {
          final scheduled = _nextWeekday(hour, minute, weekday);
          await NotificationService.instance.scheduleOneTime(
            id: notificationId,
            title: title,
            body: description,
            dateTime: scheduled,
          );
        }
        break;

      case 'monthly':
        if (monthlyDate != null) {
          tz.TZDateTime scheduled = tz.TZDateTime(tz.local, monthlyDate.year, monthlyDate.month, monthlyDate.day, hour, minute);
          if (scheduled.isBefore(tz.TZDateTime.now(tz.local))) {
            final nextMonth = monthlyDate.month < 12 ? monthlyDate.month + 1 : 1;
            final nextYear = monthlyDate.month < 12 ? monthlyDate.year : monthlyDate.year + 1;
            scheduled = tz.TZDateTime(tz.local, nextYear, nextMonth, monthlyDate.day, hour, minute);
          }
          await NotificationService.instance.scheduleOneTime(
            id: notificationId,
            title: title,
            body: description,
            dateTime: scheduled,
          );
        }
        break;

      case 'daily':
      default:
        await NotificationService.instance.scheduleDaily(
          id: notificationId,
          title: title,
          body: description,
          hour: hour,
          minute: minute,
        );
        break;
    }

    notifyListeners();
  }

  Future<void> deleteReminder(Reminder r) async {
    await _repo.deleteReminder(r.id);
    await NotificationService.instance.cancel(r.id.hashCode);
    notifyListeners();
  }

  tz.TZDateTime _nextWeekday(int hour, int minute, int weekday) {
    final now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    while (scheduled.weekday != weekday || scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    return scheduled;
  }
}
