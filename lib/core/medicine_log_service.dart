import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/medicine_log_model.dart';

class MedicineLogService {
  MedicineLogService._();
  static final MedicineLogService instance = MedicineLogService._();

  final _db = FirebaseFirestore.instance.collection('medicine_logs');

  /// Create a new log entry
  Future<void> createLog({
    required String logId,
    required String medicineId,
    required String userId,
    required DateTime scheduledTime,
  }) async {
    final log = MedicineLog(
      id: logId,
      medicineId: medicineId,
      userId: userId,
      scheduledTime: scheduledTime,
      status: "pending",
    );

    await _db.doc(logId).set(log.toMap());
  }

  /// Mark medicine as Taken
  Future<void> markTaken(String logId) async {
    await _db.doc(logId).update({
      'status': "taken",
      'loggedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Mark medicine as Missed (only if still pending)
  Future<void> markMissed(String logId) async {
    final doc = await _db.doc(logId).get();
    if (!doc.exists) return;

    final data = doc.data()!;
    if (data['status'] == "pending") {
      await _db.doc(logId).update({
        'status': "missed",
        'loggedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  /// Stream logs (history / calendar)
  Stream<List<MedicineLog>> streamLogs(String userId) {
    return _db
        .where('userId', isEqualTo: userId)
        .orderBy('scheduledTime', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => MedicineLog.fromDoc(doc)).toList());
  }

  /// ✅ Fetch logs for a specific day (used for progress bar)
  Future<List<MedicineLog>> getLogsByDateRange(
      String userId, DateTime start, DateTime end) async {
    final snap = await _db
        .where('userId', isEqualTo: userId)
        .where('scheduledTime', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('scheduledTime', isLessThan: Timestamp.fromDate(end))
        .orderBy('scheduledTime')
        .get();

    return snap.docs.map((doc) => MedicineLog.fromDoc(doc)).toList();
  }
}
