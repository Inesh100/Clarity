import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRepository {
  final _auth = FirebaseAuth.instance;
  final _google = GoogleSignIn();

  Future<User?> signUp(String email, String password) async {
    final creds = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    return creds.user;
  }

  Future<User?> signIn(String email, String password) async {
    final creds = await _auth.signInWithEmailAndPassword(email: email, password: password);
    return creds.user;
  }

  Future<User?> signInWithGoogle() async {
    final acct = await _google.signIn();
    if (acct == null) return null;
    final auth = await acct.authentication;
    final cred = GoogleAuthProvider.credential(idToken: auth.idToken, accessToken: auth.accessToken);
    final res = await _auth.signInWithCredential(cred);
    return res.user;
  }

  Future<void> signOut() async {
    await _auth.signOut();
    try { await _google.signOut(); } catch (_) {}
  }

  Stream<User?> authStateChanges() => _auth.authStateChanges();
}
