import 'package:dio/dio.dart';
import 'package:lms_mobile_app/src/core/config/constants/api_endpoints.dart';
import 'package:lms_mobile_app/src/core/network/dio_error.dart';
import 'package:lms_mobile_app/src/core/utils/local_storage.dart';

class SupportApi {
  const SupportApi(this.dio);

  final Dio dio;

  Future<Map<String, dynamic>> customerService() =>
      _get(ApiEndpoints.customerService);

  Future<Map<String, dynamic>> privacyPolicy() =>
      _get(ApiEndpoints.privacyPolicy, query: {'lang': 'id'});

  Future<Map<String, dynamic>> _get(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    final response = await dio.get<dynamic>(
      path,
      queryParameters: query,
      options: Options(headers: {'Accept': 'application/json'}),
    );
    final body = response.data;
    if (body is! Map || body['status'] != 'success' || body['data'] is! Map) {
      throw const FormatException('Konten dari server tidak tersedia.');
    }
    return Map<String, dynamic>.from(body['data'] as Map);
  }

  Future<void> deleteAccount(String password) async {
    final token = LocalStorage.getAuthToken();
    if (token == null) {
      throw const DeleteAccountException('Sesi tidak valid. Masuk kembali.');
    }
    try {
      final response = await dio.delete<dynamic>(
        ApiEndpoints.deleteProfile,
        data: {'password': password},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
          contentType: Headers.jsonContentType,
        ),
      );
      final body = response.data;
      if (response.statusCode != 200 ||
          body is! Map ||
          body['status'] != 'success') {
        throw const DeleteAccountException(
          'Server belum mengonfirmasi penghapusan akun.',
        );
      }
      await LocalStorage.clearDeletedAccount();
    } on DioException catch (error) {
      switch (error.response?.statusCode) {
        case 422:
          final body = error.response?.data;
          final errors = body is Map ? body['errors'] : null;
          final passwordErrors = errors is Map ? errors['password'] : null;
          final message = passwordErrors is List && passwordErrors.isNotEmpty
              ? passwordErrors.first.toString()
              : 'Kata sandi salah. Periksa lalu coba lagi.';
          throw DeleteAccountException(message, passwordError: true);
        case 429:
          throw const DeleteAccountException(
            'Terlalu banyak percobaan. Tunggu sebentar lalu coba lagi.',
          );
        case 401:
          throw const DeleteAccountException(
            'Sesi tidak valid. Masuk kembali.',
          );
        default:
          throw DeleteAccountException(
            friendlyDioMessage(error, 'Penghapusan gagal. Coba lagi.'),
          );
      }
    }
  }
}

class DeleteAccountException implements Exception {
  const DeleteAccountException(this.message, {this.passwordError = false});
  final String message;
  final bool passwordError;
}
