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
    super.message = 'Network error occurred',
    String? code,
    super.originalException,
    super.stackTrace,
  }) : super(
         code: code ?? 'NETWORK_ERROR',
       );
}

/// Server/API exceptions
class ServerException extends AppException {
  final int? statusCode;

  ServerException({
    super.message = 'Server error',
    this.statusCode,
    String? code,
    super.originalException,
    super.stackTrace,
  }) : super(
         code: code ?? 'SERVER_ERROR',
       );
}

/// Unauthorized/Authentication exceptions
class UnauthorizedException extends AppException {
  UnauthorizedException({
    super.message = 'Unauthorized access',
    String? code,
    super.originalException,
    super.stackTrace,
  }) : super(
         code: code ?? 'UNAUTHORIZED',
       );
}

/// Validation exceptions
class ValidationException extends AppException {
  ValidationException({
    super.message = 'Validation failed',
    String? code,
    super.originalException,
    super.stackTrace,
  }) : super(
         code: code ?? 'VALIDATION_ERROR',
       );
}

/// Local storage/cache exceptions
class StorageException extends AppException {
  StorageException({
    super.message = 'Storage operation failed',
    String? code,
    super.originalException,
    super.stackTrace,
  }) : super(
         code: code ?? 'STORAGE_ERROR',
       );
}

/// Unknown/uncategorized exceptions
class UnknownException extends AppException {
  UnknownException({
    super.message = 'An unknown error occurred',
    String? code,
    super.originalException,
    super.stackTrace,
  }) : super(
         code: code ?? 'UNKNOWN_ERROR',
       );
}
