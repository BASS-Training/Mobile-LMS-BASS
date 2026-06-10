import '../repositories/game_score_repository.dart';

/// Saving/loading/clearing of a resumable game's in-progress board.
/// Grouped into one use case since they're a single cohesive concern used only
/// by resumable games (e.g. 2048).
class ManageBoardState {
  final GameScoreRepository repository;

  ManageBoardState(this.repository);

  Future<List<int>?> load(String gameId) => repository.getSavedBoard(gameId);

  Future<int> loadScore(String gameId) =>
      repository.getSavedBoardScore(gameId);

  Future<void> save({
    required String gameId,
    required List<int> board,
    required int score,
  }) {
    return repository.saveBoard(gameId: gameId, board: board, score: score);
  }

  Future<void> clear(String gameId) => repository.clearBoard(gameId);
}
