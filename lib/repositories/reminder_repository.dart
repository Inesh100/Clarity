import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/reminder_model.dart';

class ReminderRepository {
  final _col = FirebaseFirestore.instance.collection('reminders');

  Future<void> addReminder(ReminderModel r) => _col.doc(r.id).set(r.toMap());
  Stream<List<ReminderModel>> getRemindersForUser(String uid) {
    return _col.where('userId', isEqualTo: uid).orderBy('dateTime').snapshots().map((snap) =>
      snap.docs.map((d) => ReminderModel.fromMap(d.data())).toList()
    );
  }
  Future<void> deleteReminder(String id) => _col.doc(id).delete();
}
