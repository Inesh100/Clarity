import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/reminder_model.dart';
import '../repositories/reminder_repository.dart';
import '../core/notification_service.dart';

class RemindersViewModel extends ChangeNotifier {
  final _repo = ReminderRepository();

  /// Stream of reminders for a user
  Stream<List<ReminderModel>> streamReminders(String userId) =>
      _repo.getRemindersForUser(userId);

  /// Add a reminder and schedule a notification
  Future<void> addReminder({
    required String userId,
    required String title,
    required String message,
    required DateTime dateTime,
    String repeat = 'none',
    int? weekday,
  }) async {
    final id = const Uuid().v4();
    final notificationId = id.hashCode;

    // Save to repository
    final r = ReminderModel(
      id: id,
      userId: userId,
      title: title,
      message: message,
      dateTime: dateTime,
      repeat: repeat,
      weekday: weekday,
    );
    await _repo.addReminder(r);

    // Schedule notification
    switch (repeat) {
      case 'daily':
        await NotificationService.scheduleDaily(
          id: notificationId,
          title: title,
          body: message,
          hour: dateTime.hour,
          minute: dateTime.minute,
        );
        break;

      case 'weekly':
        if (weekday != null) {
          await NotificationService.scheduleWeekly(
            id: notificationId,
            title: title,
            body: message,
            weekday: weekday,
            hour: dateTime.hour,
            minute: dateTime.minute,
          );
        }
        break;

      default: // one-time
        await NotificationService.scheduleOneTime(
          id: notificationId,
          title: title,
          body: message,
          dateTime: dateTime,
        );
        break;
    }
  }

  /// Delete reminder and cancel its notification
  Future<void> deleteReminder(ReminderModel reminder) async {
    await _repo.deleteReminder(reminder.id);
    await NotificationService.cancel(reminder.id.hashCode);
  }
}
