import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Connects to Firebase and signs the learner in anonymously so security rules
/// have a uid to key progress on. Returns false if anything fails, which lets
/// the app fall back to bundled content rather than showing an error screen.
Future<bool> bootFirebase(FirebaseOptions options) async {
  try {
    await Firebase.initializeApp(options: options);
    if (FirebaseAuth.instance.currentUser == null) {
      await FirebaseAuth.instance.signInAnonymously();
    }
    return true;
  } catch (error) {
    if (kDebugMode) debugPrint('Firebase boot failed: $error');
    return false;
  }
}
