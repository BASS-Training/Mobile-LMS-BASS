import '../entities/game_score.dart';
import '../repositories/game_score_repository.dart';

/// Reads every played game's score record (used by the Games Hub).
class GetAllGameScores {
  final GameScoreRepository repository;

  GetAllGameScores(this.repository);

  Future<List<GameScore>> call() => repository.getAllScores();
}
