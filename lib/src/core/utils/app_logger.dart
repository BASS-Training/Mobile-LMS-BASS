import 'package:flutter/foundation.dart';

/// Lightweight debug logger. No-ops in release/profile builds, so it's safe to
/// leave diagnostic logging in production code (replaces raw `print`, which is
/// flagged by `avoid_print` and ships to release).
///
/// Keep a short bracketed tag at the start of [message] to group related logs,
/// e.g. `logDebug('[QUIZ][REMOTE] started');`. Accepts any object (mirrors
/// `print`), so errors/stack traces can be logged directly.
void logDebug(Object? message) {
  if (kDebugMode) {
    debugPrint(message?.toString());
  }
}
