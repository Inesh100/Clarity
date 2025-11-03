import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/reminder_model.dart';
import '../repositories/reminder_repository.dart';
import '../core/notification_service.dart';

class ReminderViewModel extends ChangeNotifier {
  final _repo = ReminderRepository();

  Stream<List<Reminder>> streamReminders(String userId) =>
      _repo.getRemindersForUser(userId);

  Future<void> addReminder({
    required String userId,
    required String title,
    required String description,
    required int hour,
    required int minute,
    String repeat = 'daily',
    int? weekday,
    int? weekOfMonth,
  }) async {
    final id = const Uuid().v4();
    final notificationId = id.hashCode;

    final r = Reminder(
      id: id,
      userId: userId,
      title: title,
      description: description,
      hour: hour,
      minute: minute,
    );

    await _repo.addReminder(r);

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
        if (weekday != null && weekOfMonth != null) {
          await NotificationService.instance.scheduleMonthly(
            id: notificationId,
            title: title,
            body: description,
            weekday: weekday,
            hour: hour,
            minute: minute,
            weekOfMonth: weekOfMonth,
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
  }

  Future<void> deleteReminder(Reminder reminder) async {
    await _repo.deleteReminder(reminder.id);
    await NotificationService.instance.cancel(reminder.id.hashCode);
  }
}
