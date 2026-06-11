import 'package:dio/dio.dart';

/// Extracts a user-facing message from a [DioException]: prefers the API's
/// `{ "message": ... }` response body, otherwise returns [fallback] (a friendly,
/// localized default). Centralizes the error-message handling that every remote
/// data source needs.
String dioErrorMessage(DioException error, String fallback) {
  final data = error.response?.data;
  if (data is Map<String, dynamic>) {
    final message = data['message']?.toString().trim();
    if (message != null && message.isNotEmpty) {
      return message;
    }
  }
  return fallback;
}

/// Like [dioErrorMessage] but maps "server panic" and connectivity failures to
/// friendly, end-user-facing Indonesian messages instead of leaking technical
/// detail (e.g. a `500` page or "Http status error [500]"). Use this on
/// user-facing flows such as login/register.
String friendlyDioMessage(DioException error, String fallback) {
  // Connectivity / timeout problems — the request never got a real answer.
  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return 'Koneksi terlalu lama. Periksa internet Anda lalu coba lagi.';
    case DioExceptionType.connectionError:
      return 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.';
    default:
      break;
  }

  // Server-side errors (500/502/503/504): don't surface the raw error.
  final status = error.response?.statusCode ?? 0;
  if (status >= 500) {
    return 'Server sedang mengalami gangguan internal. Tim kami sedang '
        'memperbaikinya, silakan coba beberapa saat lagi.';
  }

  // Otherwise prefer the API's message, then Dio's, then the fallback.
  final data = error.response?.data;
  if (data is Map<String, dynamic>) {
    final message = data['message']?.toString().trim();
    if (message != null && message.isNotEmpty) {
      return message;
    }
  }
  final raw = error.message?.trim();
  return (raw != null && raw.isNotEmpty) ? raw : fallback;
}
