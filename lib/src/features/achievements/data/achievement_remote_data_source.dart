import 'package:dio/dio.dart';
import 'package:lms_mobile_app/src/core/config/constants/api_endpoints.dart';
import 'package:lms_mobile_app/src/core/network/dio_error.dart';

/// Akses jaringan baseline perayaan achievement (`/mobile/achievements/tiers`).
/// Hanya menyimpan map { achievementId: tier-tertinggi-yang-sudah-dirayakan }
/// per-user, agar perayaan tidak muncul ulang di device baru.
abstract class AchievementRemoteDataSource {
  Future<Map<String, int>> fetchTiers();
  Future<void> syncTiers(Map<String, int> tiers);
}

class AchievementRemoteDataSourceImpl implements AchievementRemoteDataSource {
  final Dio _dio;

  AchievementRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<Map<String, int>> fetchTiers() async {
    try {
      final res = await _dio.get(ApiEndpoints.achievementTiers);
      return _parseMap(res.data);
    } on DioException catch (e) {
      throw Exception(dioErrorMessage(e, 'Gagal memuat baseline pencapaian'));
    }
  }

  @override
  Future<void> syncTiers(Map<String, int> tiers) async {
    try {
      await _dio.post(
        ApiEndpoints.achievementTiersSync,
        data: {'tiers': tiers},
      );
    } on DioException catch (e) {
      throw Exception(dioErrorMessage(e, 'Gagal menyinkronkan pencapaian'));
    }
  }

  Map<String, int> _parseMap(dynamic data) {
    final raw = (data is Map && data['data'] is Map) ? data['data'] as Map : null;
    if (raw == null) return {};
    final result = <String, int>{};
    raw.forEach((k, v) {
      final tier = v is int
          ? v
          : (v is num ? v.toInt() : int.tryParse('$v') ?? 0);
      result['$k'] = tier;
    });
    return result;
  }
}
