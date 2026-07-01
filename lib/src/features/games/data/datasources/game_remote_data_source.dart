import 'package:dio/dio.dart';
import 'package:lms_mobile_app/src/core/config/constants/api_endpoints.dart';
import 'package:lms_mobile_app/src/core/network/dio_error.dart';

import '../../domain/entities/game_score.dart';

/// Akses jaringan best score mini-game (`/mobile/games/scores`). Best score &
/// jumlah main disinkronkan per-user; board/resume mid-game tetap lokal.
abstract class GameRemoteDataSource {
  Future<List<GameScore>> fetchAll();
  Future<void> submitRound({required String gameId, required int score});

  /// Upsert best/plays (max) dari [scores] ke server, kembalikan daftar
  /// otoritatif terkini (termasuk skor dari device lain). [scores] boleh kosong
  /// untuk sekadar menarik daftar server.
  Future<List<GameScore>> merge(List<GameScore> scores);
}

class GameRemoteDataSourceImpl implements GameRemoteDataSource {
  final Dio _dio;

  GameRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<List<GameScore>> fetchAll() async {
    try {
      final res = await _dio.get(ApiEndpoints.gameScores);
      return _parseList(res.data);
    } on DioException catch (e) {
      throw Exception(dioErrorMessage(e, 'Gagal memuat skor game'));
    }
  }

  @override
  Future<void> submitRound({required String gameId, required int score}) async {
    try {
      await _dio.post(
        ApiEndpoints.gameScores,
        data: {'gameId': gameId, 'score': score},
      );
    } on DioException catch (e) {
      throw Exception(dioErrorMessage(e, 'Gagal mengirim skor game'));
    }
  }

  @override
  Future<List<GameScore>> merge(List<GameScore> scores) async {
    try {
      final res = await _dio.post(
        ApiEndpoints.gameScoresMerge,
        data: {
          'scores': scores
              .map((s) => {
                    'gameId': s.gameId,
                    'highScore': s.highScore,
                    'timesPlayed': s.timesPlayed,
                    'lastPlayedAt': s.lastPlayedAt?.toIso8601String(),
                  })
              .toList(),
        },
      );
      return _parseList(res.data);
    } on DioException catch (e) {
      throw Exception(dioErrorMessage(e, 'Gagal menyinkronkan skor game'));
    }
  }

  List<GameScore> _parseList(dynamic data) {
    final list = (data is Map && data['data'] is List)
        ? data['data'] as List
        : const [];
    return list.whereType<Map>().map((e) {
      final lastRaw = e['lastPlayedAt'];
      return GameScore(
        gameId: '${e['gameId'] ?? ''}',
        highScore: _asInt(e['highScore']),
        timesPlayed: _asInt(e['timesPlayed']),
        lastPlayedAt: lastRaw is String ? DateTime.tryParse(lastRaw) : null,
      );
    }).toList();
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
