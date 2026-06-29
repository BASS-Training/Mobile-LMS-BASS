import 'package:dio/dio.dart';
import 'package:lms_mobile_app/src/core/config/constants/api_endpoints.dart';
import 'package:lms_mobile_app/src/core/network/dio_error.dart';
import 'package:lms_mobile_app/src/features/agenda/domain/entities/personal_agenda_item.dart';

/// Akses jaringan agenda pribadi peserta (`/mobile/agenda/personal`).
/// Server adalah sumber kebenaran; [PersonalAgendaStore] memakai ini lalu
/// mencerminkan hasilnya ke Hive untuk akses offline.
abstract class PersonalAgendaRemoteDataSource {
  Future<List<PersonalAgendaItem>> fetchAll();
  Future<PersonalAgendaItem> create(PersonalAgendaItem item);
  Future<void> delete(String id);
}

class PersonalAgendaRemoteDataSourceImpl implements PersonalAgendaRemoteDataSource {
  final Dio _dio;

  PersonalAgendaRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<List<PersonalAgendaItem>> fetchAll() async {
    try {
      final res = await _dio.get(ApiEndpoints.personalAgenda);
      final data = res.data;
      final list = (data is Map && data['data'] is List)
          ? data['data'] as List
          : const [];
      return list
          .whereType<Map>()
          .map((e) => PersonalAgendaItem.fromMap(e))
          .toList();
    } on DioException catch (e) {
      throw Exception(dioErrorMessage(e, 'Gagal memuat agenda pribadi'));
    }
  }

  @override
  Future<PersonalAgendaItem> create(PersonalAgendaItem item) async {
    try {
      final res = await _dio.post(
        ApiEndpoints.personalAgenda,
        data: {
          'title': item.title,
          'note': item.note,
          'date': item.date.toIso8601String(),
          'hour': item.hour,
          'minute': item.minute,
        },
      );
      final data = res.data;
      final map = (data is Map && data['data'] is Map) ? data['data'] as Map : null;
      if (map == null) {
        throw Exception('Respons agenda pribadi tidak valid');
      }
      return PersonalAgendaItem.fromMap(map);
    } on DioException catch (e) {
      throw Exception(dioErrorMessage(e, 'Gagal menyimpan agenda pribadi'));
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _dio.delete(
        ApiEndpoints.personalAgendaItem.replaceFirst('{id}', id),
      );
    } on DioException catch (e) {
      throw Exception(dioErrorMessage(e, 'Gagal menghapus agenda pribadi'));
    }
  }
}
