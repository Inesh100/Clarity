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
    String repeat = 'daily', // default daily
    int? weekday,
  }) async {
    final id = const Uuid().v4();
    final notificationId = id.hashCode;

    // Save to repository
    final m = Medicine(
      id: id,
      userId: userId,
      name: name,
      dosage: dosage,
      hour: hour,
      minute: minute,
    );
    await _repo.addMedicine(m);

    // Schedule notification
    switch (repeat) {
      case 'weekly':
        if (weekday != null) {
          await NotificationService.scheduleWeekly(
            id: notificationId,
            title: 'Medicine: $name',
            body: dosage,
            weekday: weekday,
            hour: hour,
            minute: minute,
          );
        }
        break;

      case 'daily':
      default:
        await NotificationService.scheduleDaily(
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
    await NotificationService.cancel(medicine.id.hashCode);
  }
}
