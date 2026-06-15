import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Best-effort Firebase init + App Check. Everything is wrapped so a project
/// that hasn't dropped in its Firebase config yet (GoogleService-Info.plist /
/// google-services.json) still launches — the AI analysis feature simply stays
/// unavailable until it's configured.
abstract final class FirebaseService {
  static bool _ready = false;

  /// True once Firebase + App Check are initialised.
  static bool get isReady => _ready;

  static Future<void> initialize() async {
    try {
      // Reads native config (GoogleService-Info.plist / google-services.json).
      await Firebase.initializeApp();
      await FirebaseAppCheck.instance.activate(
        // Debug provider lets you test locally; register the debug token printed
        // to the console in the Firebase App Check settings.
        appleProvider:
            kDebugMode ? AppleProvider.debug : AppleProvider.appAttest,
        androidProvider:
            kDebugMode ? AndroidProvider.debug : AndroidProvider.playIntegrity,
      );
      _ready = true;
    } catch (e) {
      _ready = false;
      debugPrint('Firebase/App Check not configured: $e');
    }
  }

  /// Returns a fresh App Check token, or null when Firebase isn't configured.
  static Future<String?> appCheckToken() async {
    if (!_ready) return null;
    try {
      return await FirebaseAppCheck.instance.getToken();
    } catch (e) {
      debugPrint('App Check getToken failed: $e');
      return null;
    }
  }
}
