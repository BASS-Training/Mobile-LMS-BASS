import 'package:dio/dio.dart';
import 'package:lms_mobile_app/src/core/config/constants/api_endpoints.dart';
import 'package:lms_mobile_app/src/core/network/dio_error.dart';

import '../models/catalog_course_model.dart';
import 'catalog_remote_data_source.dart';

/// Implementasi jaringan etalase (`/mobile/catalog`).
///
/// Tidak ada cache lokal di sini — berbeda dengan daftar kursus milik user.
/// Katalog berubah dari sisi admin (kursus baru dipublikasikan, harga diubah)
/// dan tidak dibutuhkan saat offline, sehingga menyimpannya ke Hive hanya
/// menambah risiko menampilkan etalase basi.
class CatalogRemoteDataSourceImpl implements CatalogRemoteDataSource {
  final Dio dio;

  CatalogRemoteDataSourceImpl({required this.dio});

  @override
  Future<CatalogPayload> fetchCatalog({
    String? query,
    String? priceFilter,
  }) async {
    // Backend mengabaikan kata kunci di bawah 2 huruf; jangan kirim sama sekali
    // supaya hasilnya tidak terlihat "berkedip" saat user baru mengetik 1 huruf.
    final trimmed = query?.trim() ?? '';
    final keyword = trimmed.length >= 2 ? trimmed : null;

    try {
      final response = await dio.get(
        ApiEndpoints.catalog,
        queryParameters: {'q': ?keyword, 'harga': ?priceFilter},
      );

      final data = response.data;
      final list = (data is Map && data['data'] is List)
          ? data['data'] as List
          : const [];
      final meta = (data is Map && data['meta'] is Map)
          ? Map<String, dynamic>.from(data['meta'] as Map)
          : const <String, dynamic>{};

      return CatalogPayload(
        courses: list
            .whereType<Map>()
            .map(
              (e) => CatalogCourseModel.fromJson(Map<String, dynamic>.from(e)),
            )
            .toList(),
        showPrice: meta['showPrice'] == true,
      );
    } on DioException catch (error) {
      throw Exception(friendlyDioMessage(error, 'Gagal memuat katalog kursus'));
    }
  }

  @override
  Future<CatalogCourseModel> fetchCatalogCourse(String id) async {
    try {
      final response = await dio.get(
        ApiEndpoints.catalogDetail.replaceFirst('{id}', id),
      );

      final data = response.data;
      final item = (data is Map && data['data'] is Map)
          ? Map<String, dynamic>.from(data['data'] as Map)
          : <String, dynamic>{};

      return CatalogCourseModel.fromJson(item);
    } on DioException catch (error) {
      throw Exception(friendlyDioMessage(error, 'Gagal memuat detail kursus'));
    }
  }

  @override
  Future<void> enrollFree(String id) async {
    try {
      await dio.post(ApiEndpoints.catalogEnrollFree.replaceFirst('{id}', id));
    } on DioException catch (error) {
      throw Exception(friendlyDioMessage(error, 'Gagal bergabung ke kursus'));
    }
  }
}
