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
