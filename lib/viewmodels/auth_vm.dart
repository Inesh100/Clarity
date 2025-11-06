import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../repositories/auth_repository.dart';
import '../repositories/user_repository.dart';
import '../models/app_user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthViewModel extends ChangeNotifier {
  final _repo = AuthRepository();
  final _userRepo = UserRepository();

  User? firebaseUser;
  AppUser? appUser;
  bool loading = false;
  String? error;

  AuthViewModel() {
    _repo.authStateChanges().listen((user) async {
      firebaseUser = user;

      if (user != null) {
        appUser = await _userRepo.getUser(user.uid);

        if (appUser == null) {
          final newUser = AppUser(
            id: user.uid,
            name: user.displayName ?? 'User',
            email: user.email ?? '',
          );
          await _userRepo.createUser(newUser);
          appUser = newUser;
        }
      } else {
        appUser = null;
      }

      notifyListeners();
    });
  }

  Future<bool> signUp(String email, String password, String name) async {
  try {
    loading = true;
    notifyListeners();

    final user = await _repo.signUp(email, password);
    if (user != null) {
      final appU = AppUser(
        id: user.uid,
        name: name,
        email: user.email ?? '',
      );
      await _userRepo.createUser(appU);

      // Update local state immediately
      firebaseUser = user;
      appUser = appU;
      notifyListeners();
      return true;
    }
    return false;
  } catch (e) {
    error = e.toString();
    return false;
  } finally {
    loading = false;
    notifyListeners();
  }
}


  Future<void> signIn(String email, String password) async {
    try {
      loading = true;
      notifyListeners();
      await _repo.signIn(email, password);
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> googleSignIn() async {
    try {
      loading = true;
      notifyListeners();
      await _repo.signInWithGoogle();
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    appUser = null;
    firebaseUser = null;
    await _repo.signOut();
    notifyListeners();
  }

  /// Delete account with reauthentication
  Future<void> deleteAccount({String? password}) async {
    try {
      loading = true;
      notifyListeners();

      final user = firebaseUser;
      if (user == null) throw Exception("No user logged in");

      // Determine provider
      final providers = user.providerData.map((p) => p.providerId).toList();

      // Email/password → require password
      if (providers.contains('password')) {
        if (password == null) {
          throw Exception("Password required to delete account.");
        }
        final credential =
            EmailAuthProvider.credential(email: user.email!, password: password);
        await user.reauthenticateWithCredential(credential);
      }

      // Google → reauthenticate
      if (providers.contains('google.com')) {
        final googleUser = await GoogleSignIn().signIn();
        if (googleUser == null) throw Exception("Google reauthentication cancelled");

        final googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        await user.reauthenticateWithCredential(credential);
      }

      // Delete Firestore profile
      await _userRepo.deleteUser(user.uid);

      // Delete Firebase Auth account
      await user.delete();

      // Clear local state
      firebaseUser = null;
      appUser = null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        error = 'Please log in again before deleting your account.';
      } else {
        error = e.message;
      }
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

 

  Future<void> saveLastEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_email', email);
  }

  Future<String?> getLastEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('last_email');
  }
  Future<void> clearLastEmail() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('last_email');
}
}

