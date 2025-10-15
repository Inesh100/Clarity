import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/medicine_model.dart';
import '../repositories/medicine_repository.dart';
import '../core/notification_service.dart';

class MedicineViewModel extends ChangeNotifier {
  final _repo = MedicineRepository();

  Stream<List<Medicine>> streamMedicines(String userId) => _repo.getMedicines(userId);

  Future<void> addMedicine({ required String userId, required String name, required String dosage, required int hour, required int minute }) async {
    final id = const Uuid().v4();
    final m = Medicine(id: id, userId: userId, name: name, dosage: dosage, hour: hour, minute: minute);
    await _repo.addMedicine(m);
    // schedule daily local notification
    await NotificationService.scheduleDaily(id: id, title: 'Medicine: $name', body: '$dosage', hour: hour, minute: minute);
  }

  Future<void> deleteMedicine(String id) async {
    await _repo.deleteMedicine(id);
    await NotificationService.cancel(id);
  }
}
