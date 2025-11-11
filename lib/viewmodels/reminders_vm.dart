// viewmodels/reminders_vm.dart
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:timezone/timezone.dart' as tz;
import '../core/exact_alarm_permission_helper.dart';
import '../core/notification_service.dart';
import '../models/reminder_model.dart';
import '../repositories/reminder_repository.dart';

class RemindersViewModel extends ChangeNotifier {
  final _repo = ReminderRepository();

  Stream<List<Reminder>> streamReminders(String userId) =>
      _repo.getRemindersForUser(userId);

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
    final id = const Uuid().v4();
    final notificationId = id.hashCode;

    final reminder = Reminder(
      id: id,
      userId: userId,
      title: title,
      description: description,
      hour: hour,
      minute: minute,
    );

    await _repo.addReminder(reminder);
    await ExactAlarmPermissionHelper.checkAndRequest(context);

    /// ---- SCHEDULING ----
    switch (repeat) {
      case 'weekly':
        if (weekday != null) {
          await NotificationService.instance.scheduleWeekly(
            id: notificationId,
            title: title,
            body: description,
            weekday: weekday,
            hour: hour,
            minute: minute,
          );
        }
        break;

      case 'monthly':
        if (monthlyDate != null) {
          tz.TZDateTime scheduled = tz.TZDateTime(
            tz.local,
            monthlyDate.year,
            monthlyDate.month,
            monthlyDate.day,
            hour,
            minute,
          );

          if (scheduled.isBefore(tz.TZDateTime.now(tz.local))) {
            int nextMonth = monthlyDate.month < 12 ? monthlyDate.month + 1 : 1;
            int nextYear = monthlyDate.month < 12
                ? monthlyDate.year
                : monthlyDate.year + 1;

            scheduled = tz.TZDateTime(
              tz.local,
              nextYear,
              nextMonth,
              monthlyDate.day,
              hour,
              minute,
            );
          }

          await NotificationService.instance.scheduleOneTime(
            id: notificationId,
            title: title,
            body: description,
            dateTime: scheduled,
          );
        }
        break;

      default: // DAILY
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

  Future<void> deleteReminder(Reminder reminder) async {
    await _repo.deleteReminder(reminder.id);
    await NotificationService.instance.cancel(reminder.id.hashCode);
    notifyListeners();
  }
}
