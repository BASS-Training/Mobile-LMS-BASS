/// Failure abstraction untuk error handling konsisten
abstract class Failure {
  final String message;

  Failure({required this.message});

  @override
  String toString() => message;
}

/// Failure dari server/network
class ServerFailure extends Failure {
  final int? statusCode;

  ServerFailure({required String message, this.statusCode})
    : super(message: message);
}

/// Failure karena unauthorized
class UnauthorizedFailure extends Failure {
  UnauthorizedFailure({String? message})
    : super(message: message ?? 'Unauthorized. Please login again.');
}

/// Failure karena validation error
class ValidationFailure extends Failure {
  ValidationFailure({required String message}) : super(message: message);
}

/// Failure karena network error
class NetworkFailure extends Failure {
  NetworkFailure({String? message})
    : super(message: message ?? 'Network error. Please check your connection.');
}

/// Failure karena data tidak ditemukan
class NotFoundFailure extends Failure {
  NotFoundFailure({String? message})
    : super(message: message ?? 'Data not found.');
}

/// Failure unknown/generic
class UnknownFailure extends Failure {
  UnknownFailure({String? message})
    : super(message: message ?? 'An unexpected error occurred.');
}
