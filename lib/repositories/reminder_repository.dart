import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/reminder_model.dart';
import '../core/constants.dart';

class ReminderRepository {
  final _col = FirebaseFirestore.instance.collection(Collections.reminders);

  Future<void> addReminder(Reminder r) => _col.doc(r.id).set(r.toMap());

  Stream<List<Reminder>> getRemindersForUser(String uid) {
    return _col
        .where('userId', isEqualTo: uid)
        .orderBy('hour') // you can also order by 'minute' or 'dateTime' if needed
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => Reminder.fromMap(d.data())).toList());
  }

  Future<void> deleteReminder(String id) => _col.doc(id).delete();
}
