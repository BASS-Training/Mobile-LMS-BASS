import 'app_exception.dart';
import 'failures.dart';

/// Helper class untuk mengkonversi AppException ke Failure
/// Digunakan di repository layer
class ErrorHandler {
  /// Convert AppException ke Failure berdasarkan tipe exception
  static Failure mapExceptionToFailure(dynamic exception) {
    if (exception is ServerException) {
      return ServerFailure(
        message: exception.message,
        statusCode: exception.statusCode,
        code: exception.code,
      );
    } else if (exception is NetworkException) {
      return NetworkFailure(message: exception.message, code: exception.code);
    } else if (exception is UnauthorizedException) {
      return UnauthorizedFailure(
        message: exception.message,
        code: exception.code,
      );
    } else if (exception is ValidationException) {
      return ValidationFailure(
        message: exception.message,
        code: exception.code,
      );
    } else if (exception is StorageException) {
      return StorageFailure(message: exception.message, code: exception.code);
    } else if (exception is AppException) {
      return UnknownFailure(message: exception.message, code: exception.code);
    } else {
      return UnknownFailure(message: exception.toString());
    }
  }

  /// Helper untuk menghandle error dari try-catch
  static Future<T> handle<T>({required Future<T> Function() operation}) async {
    try {
      return await operation();
    } on AppException {
      rethrow;
    } catch (e, stackTrace) {
      throw UnknownException(
        message: e.toString(),
        originalException: e,
        stackTrace: stackTrace,
      );
    }
  }
}
