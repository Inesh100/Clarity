// lib/repositories/medicine_log_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/medicine_log_model.dart';

class MedicineLogRepository {
  final _db = FirebaseFirestore.instance.collection('medicine_logs');

  Stream<List<MedicineLog>> streamLogs(String userId) {
    return _db
        .where('userId', isEqualTo: userId)
        .orderBy('scheduledTime', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => MedicineLog.fromDoc(doc)).toList());
  }

  Future<void> markTaken(String logId) {
    return _db.doc(logId).update({
      'status': 'taken',
      'loggedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> markMissed(String logId) {
    return _db.doc(logId).update({
      'status': 'missed',
      'loggedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<List<MedicineLog>> logsForDay(String userId, DateTime day) async {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));

    final snap = await _db
        .where('userId', isEqualTo: userId)
        .where('scheduledTime', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('scheduledTime', isLessThan: Timestamp.fromDate(end))
        .orderBy('scheduledTime')
        .get();

    return snap.docs.map((doc) => MedicineLog.fromDoc(doc)).toList();
  }

  Future<void> createLog(MedicineLog log) async {
    await _db.doc(log.id).set(log.toMap());
  }
}
