import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../repositories/auth_repository.dart';
import '../repositories/user_repository.dart';
import '../models/user_model.dart';

class AuthViewModel extends ChangeNotifier {
  final _repo = AuthRepository();
  final _userRepo = UserRepository();

  User? firebaseUser;
  AppUser? appUser;
  bool loading = false;
  String? error;

  AuthViewModel() {
    _repo.authStateChanges().listen((u) async {
      firebaseUser = u;
      if (u != null) {
        appUser = await _userRepo.getUser(u.uid);
        if (appUser == null) {
          final newUser = AppUser(id: u.uid, name: u.displayName ?? 'User', email: u.email ?? '');
          await _userRepo.createUser(newUser);
          appUser = newUser;
        }
      } else {
        appUser = null;
      }
      notifyListeners();
    });
  }

  Future<void> signUp(String email, String password, String name) async {
    try {
      loading = true; notifyListeners();
      final user = await _repo.signUp(email, password);
      if (user != null) {
        final appU = AppUser(id: user.uid, name: name, email: user.email ?? '');
        await _userRepo.createUser(appU);
      }
    } catch (e) {
      error = e.toString();
    } finally { loading = false; notifyListeners(); }
  }

  Future<void> signIn(String email, String password) async {
    try { loading = true; notifyListeners(); await _repo.signIn(email, password); }
    catch (e) { error = e.toString(); } finally { loading = false; notifyListeners(); }
  }

  Future<void> googleSignIn() async {
    try { loading = true; notifyListeners(); await _repo.signInWithGoogle(); }
    catch (e) { error = e.toString(); } finally { loading = false; notifyListeners(); }
  }

  Future<void> signOut() async {
    await _repo.signOut();
  }
}
