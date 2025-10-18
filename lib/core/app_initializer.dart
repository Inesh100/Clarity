import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../firebase_options.dart';

class AppInitializer {
  static Future<void> initialize() async {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    // Enable offline persistence for Firestore
    FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true);
  }
}
