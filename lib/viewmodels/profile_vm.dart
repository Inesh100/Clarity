import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../repositories/user_repository.dart';

class ProfileViewModel extends ChangeNotifier {
  final _repo = UserRepository();
  AppUser? user;
  bool loading = false;

  Future<void> loadProfile(String userId) async {
    loading = true; notifyListeners();
    user = await _repo.getUser(userId);
    loading = false; notifyListeners();
  }

  Future<void> updateProfile(AppUser u) async {
    await _repo.updateUser(u);
    user = u; notifyListeners();
  }
}
