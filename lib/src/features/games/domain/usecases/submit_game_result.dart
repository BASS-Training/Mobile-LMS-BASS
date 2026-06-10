import '../entities/game_score.dart';
import '../repositories/game_score_repository.dart';

/// Records the outcome of a finished round and returns the updated record
/// (with the possibly-new high score).
class SubmitGameResult {
  final GameScoreRepository repository;

  SubmitGameResult(this.repository);

  Future<GameScore> call({required String gameId, required int score}) {
    return repository.submitResult(gameId: gameId, score: score);
  }
}
