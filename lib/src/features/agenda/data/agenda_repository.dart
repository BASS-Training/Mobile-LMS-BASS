import 'package:dio/dio.dart';
import 'package:lms_mobile_app/src/core/config/constants/api_endpoints.dart';
import 'package:lms_mobile_app/src/core/network/dio_error.dart';
import 'package:lms_mobile_app/src/features/agenda/domain/entities/agenda_item.dart';

/// Akses baca-saja ke agenda sesi terjadwal (`/mobile/agenda`), mencakup setiap
/// course yang bisa diakses user. Berbagi tabel `contents` dengan web.
class AgendaRepository {
  final Dio _dio;

  AgendaRepository({required Dio dio}) : _dio = dio;

  Future<List<AgendaItem>> getAgenda() async {
    try {
      final res = await _dio.get(ApiEndpoints.agenda);
      final data = res.data;
      final list = (data is Map && data['data'] is List)
          ? data['data'] as List
          : const [];
      return list
          .whereType<Map>()
          .map((e) => AgendaItem.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } on DioException catch (e) {
      throw Exception(dioErrorMessage(e, 'Gagal memuat agenda'));
    }
  }
}
