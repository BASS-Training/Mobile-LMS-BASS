/// Exception umum untuk aplikasi
class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalException;

  AppException({required this.message, this.code, this.originalException});

  @override
  String toString() => message;
}

/// Exception untuk server/API errors
class ServerException extends AppException {
  final int? statusCode;

  ServerException({
    required String message,
    this.statusCode,
    String? code,
    dynamic originalException,
  }) : super(
         message: message,
         code: code,
         originalException: originalException,
       );
}

/// Exception untuk network errors
class NetworkException extends AppException {
  NetworkException({String? message, String? code, dynamic originalException})
    : super(
        message: message ?? 'Network error occurred',
        code: code,
        originalException: originalException,
      );
}

/// Exception untuk cache/local storage errors
class CacheException extends AppException {
  CacheException({String? message, String? code, dynamic originalException})
    : super(
        message: message ?? 'Cache operation failed',
        code: code,
        originalException: originalException,
      );
}

/// Exception untuk validation errors
class ValidationException extends AppException {
  ValidationException({
    required String message,
    String? code,
    dynamic originalException,
  }) : super(
         message: message,
         code: code,
         originalException: originalException,
       );
}
