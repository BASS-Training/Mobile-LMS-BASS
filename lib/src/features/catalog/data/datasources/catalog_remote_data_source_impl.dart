import 'package:dio/dio.dart';

import '../../../../core/config/constants/api_endpoints.dart';
import '../../../../core/error/app_exception.dart';
import '../../../../core/network/dio_error.dart';
import '../models/catalog_course_model.dart';
import '../models/catalog_page_model.dart';
import 'catalog_remote_data_source.dart';

class CatalogRemoteDataSourceImpl implements CatalogRemoteDataSource {
  final Dio dio;

  const CatalogRemoteDataSourceImpl({required this.dio});

  @override
  Future<CatalogPage> getCatalog({
    String? q,
    String? harga,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'page': page,
        'perPage': perPage,
      };
      final trimmedQuery = q?.trim();
      if (trimmedQuery != null && trimmedQuery.isNotEmpty) {
        queryParameters['q'] = trimmedQuery;
      }
      if (harga == 'free' || harga == 'paid') {
        queryParameters['harga'] = harga;
      }

      final response = await dio.get(
        ApiEndpoints.catalog,
        queryParameters: queryParameters,
      );
      return CatalogPage.fromJson(_parseEnvelope(response.data));
    } on DioException catch (error) {
      throw _mapDioError(error, fallback: 'Gagal memuat katalog kursus');
    } on AppException {
      rethrow;
    } catch (_) {
      throw UnknownException(message: 'Gagal memuat katalog kursus');
    }
  }

  @override
  Future<CatalogCourseModel> getDetail(String courseId) async {
    try {
      final response = await dio.get(
        ApiEndpoints.catalogDetail.replaceFirst('{id}', courseId),
      );
      final data = _parseEnvelope(response.data);
      final rawData = data['data'];
      if (rawData is! Map) {
        throw const FormatException('Respons detail katalog tidak valid.');
      }
      return CatalogCourseModel.fromJson(Map<String, dynamic>.from(rawData));
    } on DioException catch (error) {
      throw _mapDioError(error, fallback: 'Gagal memuat detail kursus');
    } on FormatException {
      throw UnknownException(message: 'Gagal memuat detail kursus');
    } on AppException {
      rethrow;
    } catch (_) {
      throw UnknownException(message: 'Gagal memuat detail kursus');
    }
  }

  @override
  Future<void> enrollFree(String courseId) async {
    try {
      final response = await dio.post(
        ApiEndpoints.catalogEnrollFree.replaceFirst('{id}', courseId),
      );
      final data = _parseEnvelope(response.data);
      final status = data['status']?.toString();

      if (status == null || status == 'success') return;

      throw ValidationException(
        message: _nonEmpty(data['message']) ?? 'Course belum dapat diikuti.',
      );
    } on DioException catch (error) {
      throw _mapDioError(error, fallback: 'Gagal mengikuti kursus');
    } on AppException {
      rethrow;
    } catch (_) {
      throw UnknownException(message: 'Gagal mengikuti kursus');
    }
  }

  /// Terjemahkan [DioException] ke exception aplikasi agar lapisan repository
  /// bisa membedakan mana yang boleh difallback ke data lokal (jaringan/server)
  /// dan mana yang harus diteruskan ke UI (auth/validasi).
  AppException _mapDioError(DioException error, {required String fallback}) {
    final statusCode = error.response?.statusCode;
    final message = dioErrorMessage(error, fallback);

    if (statusCode == 401) {
      return UnauthorizedException(
        message: 'Sesi berakhir. Silakan masuk kembali.',
      );
    }
    if (statusCode == 422) {
      return ValidationException(message: message);
    }
    if (statusCode == 429) {
      final data = error.response?.data;
      final retryAfter = data is Map
          ? int.tryParse(data['retry_after']?.toString() ?? '')
          : null;
      final rateLimitMessage = retryAfter != null && retryAfter > 0
          ? '$message Coba lagi dalam $retryAfter detik.'
          : message;
      return ServerException(message: rateLimitMessage, statusCode: statusCode);
    }
    if (statusCode == null) {
      // Tanpa respons: timeout, koneksi terputus, DNS, dst.
      return NetworkException(message: message);
    }
    return ServerException(message: message, statusCode: statusCode);
  }

  /// Baca envelope standar `{status, message, data, meta}` dari body respons.
  static Map<String, dynamic> _parseEnvelope(dynamic body) {
    if (body is Map<String, dynamic>) return body;
    if (body is Map) return Map<String, dynamic>.from(body);
    throw const FormatException('Respons server tidak valid.');
  }

  static String? _nonEmpty(dynamic value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }
}
