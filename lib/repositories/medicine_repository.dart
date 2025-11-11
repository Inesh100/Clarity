import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/medicine_model.dart';
import '../core/constants.dart';

class MedicineRepository {
  final _col = FirebaseFirestore.instance.collection(Collections.medicine);

  Future<void> addMedicine(Medicine m) => _col.doc(m.id).set(m.toMap());

  Stream<List<Medicine>> getMedicines(String uid) {
    return _col
        .where('userId', isEqualTo: uid)
        .snapshots()
        .map((snap) => snap.docs.map((d) {
              final data = d.data();

              return Medicine.fromMap({
                ...data,
                "id": d.id, // ✅ ensure Firestore doc ID is used
              });
            }).toList());
  }

  Future<void> deleteMedicine(String id) => _col.doc(id).delete();

  /// ✅ lookup medicine name by document ID
  Future<String> getMedicineName(String medicineId) async {
    final doc = await _col.doc(medicineId).get();
    if (!doc.exists) return "Unknown Medicine";
    return doc.data()?['name'] ?? "Unnamed";
  }
}
