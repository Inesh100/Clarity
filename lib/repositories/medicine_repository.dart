import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/medicine_model.dart';

class MedicineRepository {
  final _col = FirebaseFirestore.instance.collection('medicine_schedule');

  Future<void> addMedicine(Medicine m) => _col.doc(m.id).set(m.toMap());
  Stream<List<Medicine>> getMedicines(String uid) =>
    _col.where('userId', isEqualTo: uid).snapshots().map((snap) => snap.docs.map((d) => Medicine.fromMap(d.data())).toList());
  Future<void> deleteMedicine(String id) => _col.doc(id).delete();
}
