import '../entities/game_score.dart';

/// Persistence for mini game scores and resumable board state.
///
/// Implemented today by a local (Hive) data source. The interface is kept free
/// of storage details so a remote leaderboard data source can be added later
/// without touching the presentation layer.
abstract class GameScoreRepository {
  /// The score record for [gameId], or an empty record if never played.
  Future<GameScore> getScore(String gameId);

  /// Score records for every game that has been played at least once.
  Future<List<GameScore>> getAllScores();

  /// Records the outcome of a finished round and returns the updated record.
  Future<GameScore> submitResult({required String gameId, required int score});

  /// Saved board state for a resumable game, or null if none. The shape of the
  /// list is owned by the game itself (e.g. 2048 stores a flattened 4x4 grid).
  Future<List<int>?> getSavedBoard(String gameId);

  /// Persists in-progress board state so the player can resume later.
  Future<void> saveBoard({
    required String gameId,
    required List<int> board,
    required int score,
  });

  /// The score that goes with a saved board (the in-progress round score).
  Future<int> getSavedBoardScore(String gameId);

  /// Clears any saved board state (e.g. after game over or starting over).
  Future<void> clearBoard(String gameId);
}
