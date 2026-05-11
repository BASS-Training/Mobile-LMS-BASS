/// Exception base class untuk seluruh aplikasi
/// Digunakan di data layer untuk wrap berbagai jenis error
class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalException;
  final StackTrace? stackTrace;

  AppException({
    required this.message,
    this.code,
    this.originalException,
    this.stackTrace,
  });

  @override
  String toString() => 'AppException: $message (code: $code)';
}

/// Network-related exceptions
class NetworkException extends AppException {
  NetworkException({
    String message = 'Network error occurred',
    String? code,
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
         message: message,
         code: code ?? 'NETWORK_ERROR',
         originalException: originalException,
         stackTrace: stackTrace,
       );
}

/// Server/API exceptions
class ServerException extends AppException {
  final int? statusCode;

  ServerException({
    String message = 'Server error',
    this.statusCode,
    String? code,
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
         message: message,
         code: code ?? 'SERVER_ERROR',
         originalException: originalException,
         stackTrace: stackTrace,
       );
}

/// Unauthorized/Authentication exceptions
class UnauthorizedException extends AppException {
  UnauthorizedException({
    String message = 'Unauthorized access',
    String? code,
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
         message: message,
         code: code ?? 'UNAUTHORIZED',
         originalException: originalException,
         stackTrace: stackTrace,
       );
}

/// Validation exceptions
class ValidationException extends AppException {
  ValidationException({
    String message = 'Validation failed',
    String? code,
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
         message: message,
         code: code ?? 'VALIDATION_ERROR',
         originalException: originalException,
         stackTrace: stackTrace,
       );
}

/// Local storage/cache exceptions
class StorageException extends AppException {
  StorageException({
    String message = 'Storage operation failed',
    String? code,
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
         message: message,
         code: code ?? 'STORAGE_ERROR',
         originalException: originalException,
         stackTrace: stackTrace,
       );
}

/// Unknown/uncategorized exceptions
class UnknownException extends AppException {
  UnknownException({
    String message = 'An unknown error occurred',
    String? code,
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
         message: message,
         code: code ?? 'UNKNOWN_ERROR',
         originalException: originalException,
         stackTrace: stackTrace,
       );
}
