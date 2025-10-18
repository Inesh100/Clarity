import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRepository {
  final _auth = FirebaseAuth.instance;
  // Use the singleton instance directly.
  final _google = GoogleSignIn.instance;

  // You must call initialize() before using any methods.
  // This can be done in a class initializer or main function.
  Future<void> initializeGoogleSignIn() async {
    await _google.initialize(
      requestScopes(): <String>[
        'email',
        'https://www.googleapis.com/auth/contacts.readonly', // Example scope
      ],
    );
  }

  Future<User?> signUp(String email, String password) async {
    final creds = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    return creds.user;
  }

  Future<User?> signIn(String email, String password) async {
    final creds = await _auth.signInWithEmailAndPassword(email: email, password: password);
    return creds.user;
  }

  Future<User?> signInWithGoogle() async {
    try {
      // First, try to sign in silently using a cached account.
      final GoogleSignInAccount? acct = await _google.signInSilently();

      // If there is no cached account, start the interactive sign-in flow.
      if (acct == null) {
        final GoogleSignInAccount? interactiveAcct = await _google.signIn();
        if (interactiveAcct == null) {
          return null; // User cancelled the sign-in.
        }
        return _firebaseSignIn(interactiveAcct);
      }
      
      // If a cached account was found, use it to sign in to Firebase.
      return _firebaseSignIn(acct);
    } catch (e) {
      print('Google sign-in error: $e');
      return null;
    }
  }

  Future<User?> _firebaseSignIn(GoogleSignInAccount googleUser) async {
    final auth = await googleUser.authentication;
    final cred = GoogleAuthProvider.credential(
      idToken: auth.idToken,
      // The accessToken is no longer part of GoogleSignInAuthentication in v7.x.x
      // and is not needed for Firebase Auth.
      // accessToken: auth.accessToken, // This line was removed.
    );
    final res = await _auth.signInWithCredential(cred);
    return res.user;
  }

  Future<void> signOut() async {
    await _auth.signOut();
    try {
      await _google.signOut();
    } catch (_) {}
  }

  Stream<User?> authStateChanges() => _auth.authStateChanges();
}
