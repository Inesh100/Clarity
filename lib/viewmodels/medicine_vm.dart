import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/medicine_model.dart';
import '../repositories/medicine_repository.dart';
import '../core/notification_service.dart';

class MedicineViewModel extends ChangeNotifier {
  final _repo = MedicineRepository();

  Stream<List<Medicine>> streamMedicines(String userId) => _repo.getMedicines(userId);

  Future<void> addMedicine({
    required String userId,
    required String name,
    required String dosage,
    required int hour,
    required int minute,
    String repeat = 'daily', // default daily
    int? weekday, // only for weekly
  }) async {
    final id = const Uuid().v4();
    final notificationId = id.hashCode;

    final m = Medicine(
      id: id,
      userId: userId,
      name: name,
      dosage: dosage,
      hour: hour,
      minute: minute,
      repeat: repeat,
      weekday: weekday,
    );

    await _repo.addMedicine(m);

    // Schedule notification based on repeat type
    switch (repeat) {
      case 'daily':
        await NotificationService.scheduleDaily(
          id: notificationId,
          title: 'Medicine Reminder: $name',
          body: dosage,
          hour: hour,
          minute: minute,
        );
        break;
      case 'weekly':
        if (weekday != null) {
          await NotificationService.scheduleWeekly(
            id: notificationId,
            title: 'Medicine Reminder: $name',
            body: dosage,
            weekday: weekday,
            hour: hour,
            minute: minute,
          );
        }
        break;
      case 'none':
        final scheduledTime = DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
          hour,
          minute,
        );
        await NotificationService.scheduleOneTime(
          id: notificationId,
          title: 'Medicine Reminder: $name',
          body: dosage,
          dateTime: scheduledTime,
        );
        break;
    }
  }

  Future<void> deleteMedicine(String id) async {
    await _repo.deleteMedicine(id);
    await NotificationService.cancel(id.hashCode);
  }
}
