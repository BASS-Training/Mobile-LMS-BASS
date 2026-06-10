import '../entities/game_score.dart';
import '../repositories/game_score_repository.dart';

/// Reads a single game's score record (used by a game screen on entry).
class GetGameScore {
  final GameScoreRepository repository;

  GetGameScore(this.repository);

  Future<GameScore> call(String gameId) => repository.getScore(gameId);
}
