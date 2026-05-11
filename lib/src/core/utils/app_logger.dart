/// Logger utility untuk debugging dan logging
class AppLogger {
  static const String _tag = 'LMS_APP';
  static bool _isDevelopment = true;

  static void init({bool isDevelopment = true}) {
    _isDevelopment = isDevelopment;
  }

  /// Log debug message
  static void debug(
    String message, {
    String? tag,
    dynamic error,
    StackTrace? stackTrace,
  }) {
    if (_isDevelopment) {
      final logTag = tag ?? _tag;
      print('[$logTag] DEBUG: $message');
      if (error != null) {
        print('[$logTag] Error: $error');
      }
      if (stackTrace != null) {
        print('[$logTag] StackTrace: $stackTrace');
      }
    }
  }

  /// Log info message
  static void info(String message, {String? tag}) {
    if (_isDevelopment) {
      final logTag = tag ?? _tag;
      print('[$logTag] INFO: $message');
    }
  }

  /// Log warning message
  static void warning(String message, {String? tag, dynamic error}) {
    final logTag = tag ?? _tag;
    print('[$logTag] WARNING: $message');
    if (error != null) {
      print('[$logTag] Error: $error');
    }
  }

  /// Log error message
  static void error(
    String message, {
    String? tag,
    dynamic error,
    StackTrace? stackTrace,
  }) {
    final logTag = tag ?? _tag;
    print('[$logTag] ERROR: $message');
    if (error != null) {
      print('[$logTag] Exception: $error');
    }
    if (stackTrace != null) {
      print('[$logTag] StackTrace: $stackTrace');
    }
  }

  /// Log API call
  static void logApiCall(
    String endpoint,
    String method, {
    Map<String, dynamic>? data,
  }) {
    debug('API Call: $method $endpoint', tag: 'API');
    if (data != null) {
      debug('Data: $data', tag: 'API');
    }
  }

  /// Log API response
  static void logApiResponse(
    String endpoint,
    int statusCode, {
    dynamic response,
  }) {
    debug('API Response: $endpoint - Status: $statusCode', tag: 'API');
    if (response != null && _isDevelopment) {
      debug('Response: $response', tag: 'API');
    }
  }
}
