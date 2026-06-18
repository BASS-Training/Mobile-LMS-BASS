import 'package:flutter/material.dart';
import 'package:lms_mobile_app/src/core/utils/local_storage.dart';

/// App-wide light/dark theme controller. Holds the user's [ThemeMode]
/// preference (light / dark / system), persists it, and notifies listeners so
/// the root can rebuild. A single shared instance is used across the app.
class ThemeController extends ChangeNotifier {
  ThemeController._(this._mode);

  static final ThemeController instance = ThemeController._(_load());

  ThemeMode _mode;
  ThemeMode get mode => _mode;

  static ThemeMode _load() {
    switch (LocalStorage.getThemeMode()) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  static String _encode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  Future<void> setMode(ThemeMode mode) async {
    if (mode == _mode) return;
    _mode = mode;
    await LocalStorage.setThemeMode(_encode(mode));
    notifyListeners();
  }

  /// Resolve the effective brightness given the platform's current brightness.
  Brightness resolveBrightness(Brightness platform) {
    switch (_mode) {
      case ThemeMode.light:
        return Brightness.light;
      case ThemeMode.dark:
        return Brightness.dark;
      case ThemeMode.system:
        return platform;
    }
  }
}
