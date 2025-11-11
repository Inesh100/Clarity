import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:timezone/timezone.dart' as tz;

import '../core/notification_service.dart';
import '../models/medicine_model.dart';
import '../repositories/medicine_repository.dart';
import '../core/exact_alarm_permission_helper.dart';

class MedicineViewModel extends ChangeNotifier {
  final _repo = MedicineRepository();
  // ✅ Request Exact Alarm permission first



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
    final id = const Uuid().v4();

    final medicine = Medicine(
      id: id,
      userId: userId,
      name: name,
      dosage: dosage,
      hour: hour,
      minute: minute,
    );

    await _repo.addMedicine(medicine);


    // New logId for tracking the dose
    final logId = DateTime.now().millisecondsSinceEpoch.toString();
    await ExactAlarmPermissionHelper.checkAndRequest(context);


    switch (repeat) {
      case 'weekly':
        if (weekday != null) {
          await NotificationService.instance.scheduleWeeklyMedicineReminder(
            logId: logId,
            medicineId: id,
            userId: userId,
            weekday: weekday,
            hour: hour,
            minute: minute,
            title: "Take $name",
            body: dosage,
          );
        }
        break;

      case 'monthly':
        if (monthlyDate != null) {
          tz.TZDateTime schedule = tz.TZDateTime(
            tz.local,
            monthlyDate.year,
            monthlyDate.month,
            monthlyDate.day,
            hour,
            minute,
          );

          if (schedule.isBefore(tz.TZDateTime.now(tz.local))) {
            final nextMonth = monthlyDate.month < 12 ? monthlyDate.month + 1 : 1;
            final nextYear = monthlyDate.month < 12 ? monthlyDate.year : monthlyDate.year + 1;
            schedule = tz.TZDateTime(
              tz.local,
              nextYear,
              nextMonth,
              monthlyDate.day,
              hour,
              minute,
            );
          }

          await NotificationService.instance.scheduleMonthlyMedicineReminder(
  logId: logId,
  medicineId: id,
  userId: userId,
  weekday: schedule.weekday,
  weekOfMonth: ((schedule.day - 1) ~/ 7) + 1,
  hour: hour,
  minute: minute,
  title: "Take $name",
  body: dosage,
);
        }
        break;

      default: // daily
        await NotificationService.instance.scheduleDailyMedicineReminder(
          logId: logId,
          medicineId: id,
          userId: userId,
          hour: hour,
          minute: minute,
          title: "Take $name",
          body: dosage,
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
