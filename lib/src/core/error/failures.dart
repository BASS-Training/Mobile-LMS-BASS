import 'package:equatable/equatable.dart';

/// Base Failure class untuk domain layer
/// Failures adalah representasi error yang "clean" untuk domain/presentation
abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure({required this.message, this.code});

  @override
  List<Object?> get props => [message, code];
}

/// Server/API error
class ServerFailure extends Failure {
  final int? statusCode;

  const ServerFailure(String message, {this.statusCode, String? code})
    : super(message: message, code: code ?? 'SERVER_ERROR');

  @override
  List<Object?> get props => [message, code, statusCode];
}

/// Network connectivity error
class NetworkFailure extends Failure {
  const NetworkFailure({
    String message = 'Network error. Please check your connection.',
    String? code,
  }) : super(message: message, code: code ?? 'NETWORK_ERROR');
}

/// Authentication/Authorization error
class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({
    String message = 'Unauthorized. Please login again.',
    String? code,
  }) : super(message: message, code: code ?? 'UNAUTHORIZED');
}

/// Validation/Input error
class ValidationFailure extends Failure {
  const ValidationFailure({required String message, String? code})
    : super(message: message, code: code ?? 'VALIDATION_ERROR');
}

/// Local storage error
class StorageFailure extends Failure {
  const StorageFailure({
    String message = 'Local storage error occurred.',
    String? code,
  }) : super(message: message, code: code ?? 'STORAGE_ERROR');
}

/// Unknown/Uncategorized error
class UnknownFailure extends Failure {
  const UnknownFailure({
    String message = 'An unexpected error occurred. Please try again.',
    String? code,
  }) : super(message: message, code: code ?? 'UNKNOWN_ERROR');
}
