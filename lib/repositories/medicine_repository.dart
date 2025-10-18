import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/medicine_model.dart';
import '../core/constants.dart';

class MedicineRepository {
  final _col = FirebaseFirestore.instance.collection(Collections.medicine);

  Future<void> addMedicine(Medicine m) => _col.doc(m.id).set(m.toMap());
  Stream<List<Medicine>> getMedicines(String uid) =>
    _col.where('userId', isEqualTo: uid).snapshots().map((snap) => snap.docs.map((d) => Medicine.fromMap(d.data())).toList());
  Future<void> deleteMedicine(String id) => _col.doc(id).delete();
}
