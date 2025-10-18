import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';
import '../core/constants.dart';

class UserRepository {
  final _col = FirebaseFirestore.instance.collection(Collections.users);

  Future<void> createUser(AppUser user) => _col.doc(user.id).set(user.toMap());
  Future<AppUser?> getUser(String id) async {
    final doc = await _col.doc(id).get();
    if (!doc.exists) return null;
    return AppUser.fromMap(doc.data()!);
  }
  Future<void> updateUser(AppUser user) => _col.doc(user.id).update(user.toMap());
}
