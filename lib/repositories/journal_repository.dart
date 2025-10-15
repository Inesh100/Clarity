import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/journal_entry_model.dart';

class JournalRepository {
  final _col = FirebaseFirestore.instance.collection('journal_entries');

  Future<void> addEntry(JournalEntry e) => _col.doc(e.id).set(e.toMap());

  Stream<List<JournalEntry>> getEntries(String uid) {
    return _col.where('userId', isEqualTo: uid).orderBy('createdAt', descending: true)
      .snapshots().map((snap) => snap.docs.map((d) => JournalEntry.fromMap(d.data())).toList());
  }

  Future<void> deleteEntry(String id) => _col.doc(id).delete();
}
