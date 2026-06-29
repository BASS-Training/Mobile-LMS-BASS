import '../../domain/entities/game_score.dart';
import '../../domain/repositories/game_score_repository.dart';
import '../datasources/game_local_data_source.dart';
import '../datasources/game_remote_data_source.dart';

/// Local-backed implementation dengan sinkronisasi server opsional.
///
/// Best score & jumlah main disinkronkan per-user ke `/mobile/games/scores`
/// (lihat [GameRemoteDataSource]); board/resume mid-game tetap murni lokal.
/// Saat [remote] null (mode tes/offline), berperilaku lokal-saja seperti dulu.
class GameScoreRepositoryImpl implements GameScoreRepository {
  final GameLocalDataSource localDataSource;
  final GameRemoteDataSource? remote;

  GameScoreRepositoryImpl({required this.localDataSource, this.remote});

  @override
  Future<GameScore> getScore(String gameId) =>
      localDataSource.getScore(gameId);

  @override
  Future<List<GameScore>> getAllScores() async {
    final local = await localDataSource.getAllScores();
    final r = remote;
    if (r == null) return local;

    try {
      // Kirim best/plays lokal (max) + tarik daftar otoritatif (mencakup skor
      // dari device lain). Server memakai semantik max sehingga idempotent.
      final synced = await r.merge(local);

      // lastScore bersifat lokal/ephemeral — pasang kembali dari cache.
      final localById = {for (final s in local) s.gameId: s};
      final result = synced
          .map((s) => s.copyWith(lastScore: localById[s.gameId]?.lastScore ?? 0))
          .toList();

      for (final s in result) {
        await localDataSource.saveScore(s);
      }
      return result;
    } catch (_) {
      return local; // offline → cache
    }
  }

  @override
  Future<GameScore> submitResult({
    required String gameId,
    required int score,
  }) async {
    final updated = await localDataSource.submitResult(
      gameId: gameId,
      score: score,
    );
    // Best-effort push ronde ini; rekonsiliasi penuh terjadi di getAllScores.
    final r = remote;
    if (r != null) {
      try {
        await r.submitRound(gameId: gameId, score: score);
      } catch (_) {}
    }
    return updated;
  }

  @override
  Future<List<int>?> getSavedBoard(String gameId) =>
      localDataSource.getSavedBoard(gameId);

  @override
  Future<int> getSavedBoardScore(String gameId) =>
      localDataSource.getSavedBoardScore(gameId);

  @override
  Future<void> saveBoard({
    required String gameId,
    required List<int> board,
    required int score,
  }) {
    return localDataSource.saveBoard(gameId: gameId, board: board, score: score);
  }

  @override
  Future<void> clearBoard(String gameId) =>
      localDataSource.clearBoard(gameId);
}
