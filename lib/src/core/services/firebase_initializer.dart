import 'package:firebase_core/firebase_core.dart';

class FirebaseInitializer {
  static bool _isInitialized = false;

  static bool get isInitialized => _isInitialized;

  static Future<void> ensureInitialized() async {
    if (_isInitialized) {
      return;
    }

    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }
      _isInitialized = true;
    } catch (_) {
      _isInitialized = false;
    }
  }
}
