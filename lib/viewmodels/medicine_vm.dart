// viewmodels/medicine_vm.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:uuid/uuid.dart';
import 'package:timezone/timezone.dart' as tz;
import '../core/notification_service.dart';
import '../models/medicine_model.dart';
import '../repositories/medicine_repository.dart';

class MedicineViewModel extends ChangeNotifier {
  final _repo = MedicineRepository();

  Stream<List<Medicine>> streamMedicines(String userId) => _repo.getMedicines(userId);

  Future<void> addMedicine({
    required BuildContext context,
    required String userId,
    required String name,
    required String dosage,
    required int hour,
    required int minute,
    String repeat = 'daily',
    int? weekday,
    int? weekOfMonth,
    DateTime? monthlyDate,
  }) async {
    /*// Request exact alarm intent on Android when needed (helper or settings typically handles this)
    if (Platform.isAndroid) {
      final intent = AndroidIntent(action: 'android.settings.REQUEST_SCHEDULE_EXACT_ALARM');
      try {
        await intent.launch();
      } catch (_) {}
    }
    */

    final id = const Uuid().v4();
    final notificationId = id.hashCode;

    final medicine = Medicine(id: id, userId: userId, name: name, dosage: dosage, hour: hour, minute: minute);
    await _repo.addMedicine(medicine);

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
        if (monthlyDate != null) {
          var schedule = tz.TZDateTime(tz.local, monthlyDate.year, monthlyDate.month, monthlyDate.day, hour, minute);
          if (schedule.isBefore(tz.TZDateTime.now(tz.local))) {
            schedule = tz.TZDateTime(tz.local, monthlyDate.year, monthlyDate.month + 1, monthlyDate.day, hour, minute);
          }
          await NotificationService.instance.scheduleOneTime(
            id: notificationId,
            title: 'Medicine: $name',
            body: dosage,
            dateTime: schedule,
          );
        } else if (weekday != null && weekOfMonth != null) {
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

    notifyListeners();
  }

  Future<void> deleteMedicine(Medicine medicine) async {
    await _repo.deleteMedicine(medicine.id);
    await NotificationService.instance.cancel(medicine.id.hashCode);
    notifyListeners();
  }
}
