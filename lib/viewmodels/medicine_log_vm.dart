import 'package:flutter/material.dart';
import '../models/medicine_log_model.dart';
import '../core/medicine_log_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'medicine_vm.dart';
import '../viewmodels/auth_vm.dart';

class MedicineLogViewModel extends ChangeNotifier {
  final _service = MedicineLogService.instance;
 


  /// Stream logs for calendar and history
  Stream<List<MedicineLog>> streamLogs(String userId) {
    return _service.streamLogs(userId);
  }

  // ---- Today's Progress Tracking ----
  List<MedicineLog> _todayLogs = [];
  List<MedicineLog> get todayLogs => _todayLogs;

  /// Progress = taken / total
  double get todayProgress {
    if (_todayLogs.isEmpty) return 0.0;
    final takenCount = _todayLogs.where((log) => log.status == "taken").length;
    return takenCount / _todayLogs.length;
  }

  /// Load all logs for today
  Future<void> loadTodayLogs(String userId) async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));

    _todayLogs = await _service.getLogsByDateRange(userId, start, end);
    notifyListeners();
  }

  // ---- Update Status ----

  Future<void> markTaken(String logId) async {
    await _service.markTaken(logId);

    _todayLogs = _todayLogs.map((log) {
      if (log.id == logId) return log.copyWith(status: "taken");
      return log;
    }).toList();

    notifyListeners();
  }

  Future<void> markMissed(String logId) async {
    await _service.markMissed(logId);

    _todayLogs = _todayLogs.map((log) {
      if (log.id == logId) return log.copyWith(status: "missed");
      return log;
    }).toList();

    notifyListeners();
  }
}
