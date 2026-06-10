import '../../domain/entities/game_score.dart';
import '../../domain/repositories/game_score_repository.dart';
import '../datasources/game_local_data_source.dart';

/// Local-backed implementation. A thin pass-through today; when a remote
/// leaderboard is added, the merge/sync logic lands here without the rest of
/// the feature having to change.
class GameScoreRepositoryImpl implements GameScoreRepository {
  final GameLocalDataSource localDataSource;

  GameScoreRepositoryImpl({required this.localDataSource});

  @override
  Future<GameScore> getScore(String gameId) =>
      localDataSource.getScore(gameId);

  @override
  Future<List<GameScore>> getAllScores() => localDataSource.getAllScores();

  @override
  Future<GameScore> submitResult({
    required String gameId,
    required int score,
  }) {
    return localDataSource.submitResult(gameId: gameId, score: score);
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
