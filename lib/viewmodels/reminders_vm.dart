import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/reminder_model.dart';
import '../repositories/reminder_repository.dart';
import '../core/notification_service.dart';

class RemindersViewModel extends ChangeNotifier {
  final _repo = ReminderRepository();

  Stream<List<ReminderModel>> streamReminders(String userId) => _repo.getRemindersForUser(userId);

  Future<void> addReminder({
    required String userId,
    required String title,
    required String message,
    required DateTime dateTime,
    required String repeat, // none,daily,weekly,monthly
    int? weekday,
  }) async {
    final id = const Uuid().v4();
    final r = ReminderModel(id: id, userId: userId, title: title, message: message, dateTime: dateTime, repeat: repeat, weekday: weekday);
    await _repo.addReminder(r);

    // schedule local notification
    if (repeat == 'daily') {
      await NotificationService.scheduleDaily(id: id, title: title, body: message, hour: dateTime.hour, minute: dateTime.minute);
    } else if (repeat == 'weekly' && weekday != null) {
      await NotificationService.scheduleWeekly(id: id, title: title, body: message, weekday: weekday, hour: dateTime.hour, minute: dateTime.minute);
    } else {
      // one-off: schedule for the date/time selected (approx using daily scheduler for same time/day)
      await NotificationService.scheduleDaily(id: id, title: title, body: message, hour: dateTime.hour, minute: dateTime.minute);
    }
  }

  Future<void> deleteReminder(String id) async {
    await _repo.deleteReminder(id);
    await NotificationService.cancel(id);
  }
}
