import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/medicine_model.dart';
import '../repositories/medicine_repository.dart';
import '../core/notification_service.dart';

class MedicineViewModel extends ChangeNotifier {
  final _repo = MedicineRepository();

  /// Stream of medicines for a user
  Stream<List<Medicine>> streamMedicines(String userId) => _repo.getMedicines(userId);

  /// Add a medicine and schedule its notification
  Future<void> addMedicine({
    required String userId,
    required String name,
    required String dosage,
    required int hour,
    required int minute,
    String repeat = 'daily', // daily by default
    int? weekday,
    int? weekOfMonth, // for monthly scheduling
  }) async {
    final id = const Uuid().v4();
    final notificationId = id.hashCode;

    // Save medicine to repository
    final medicine = Medicine(
      id: id,
      userId: userId,
      name: name,
      dosage: dosage,
      hour: hour,
      minute: minute,
    );
    await _repo.addMedicine(medicine);

    // Schedule notification based on repeat type
    switch (repeat) {
      case 'weekly':
        if (weekday != null) {
          await NotificationService.instance.scheduleWeekly(
            id: notificationId,
            title: 'Medicine: $name',
            body: dosage,
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
            title: 'Medicine: $name',
            body: dosage,
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
          title: 'Medicine: $name',
          body: dosage,
          hour: hour,
          minute: minute,
        );
        break;
    }
  }

  /// Delete medicine and cancel its notification
  Future<void> deleteMedicine(Medicine medicine) async {
    await _repo.deleteMedicine(medicine.id);
    await NotificationService.instance.cancel(medicine.id.hashCode);
  }
}
