import 'package:cloud_firestore/cloud_firestore.dart';

class MedicineLog {
  final String id;
  final String medicineId;
  final String userId;
  final DateTime scheduledTime;
  final String status; // pending, taken, missed
  final DateTime? loggedAt;

  MedicineLog({
    required this.id,
    required this.medicineId,
    required this.userId,
    required this.scheduledTime,
    required this.status,
    this.loggedAt,
  });

  factory MedicineLog.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return MedicineLog(
      id: doc.id,
      medicineId: data['medicineId'],
      userId: data['userId'],
      scheduledTime: (data['scheduledTime'] as Timestamp).toDate(),
      status: data['status'] ?? "pending",
      loggedAt: data['loggedAt'] != null
          ? (data['loggedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() => {
        'medicineId': medicineId,
        'userId': userId,
        'scheduledTime': Timestamp.fromDate(scheduledTime),
        'status': status,
        'loggedAt': loggedAt != null
            ? Timestamp.fromDate(loggedAt!)
            : FieldValue.serverTimestamp(),
      };

  MedicineLog copyWith({
    String? id,
    String? medicineId,
    String? userId,
    DateTime? scheduledTime,
    String? status,
    DateTime? loggedAt,
  }) {
    return MedicineLog(
      id: id ?? this.id,
      medicineId: medicineId ?? this.medicineId,
      userId: userId ?? this.userId,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      status: status ?? this.status,
      loggedAt: loggedAt ?? this.loggedAt,
    );
  }
}
