import 'package:equatable/equatable.dart';

import 'game_score.dart';

/// Aggregate stats across every mini game, derived from the per-game records.
/// Surfaced on the Games Hub header so players see overall progress, not just
/// individual high scores.
class OverallGameStats extends Equatable {
  final int gamesTried;
  final int totalPlays;
  final int totalHighScore;

  const OverallGameStats({
    required this.gamesTried,
    required this.totalPlays,
    required this.totalHighScore,
  });

  factory OverallGameStats.fromScores(Iterable<GameScore> scores) {
    var gamesTried = 0;
    var totalPlays = 0;
    var totalHighScore = 0;

    for (final score in scores) {
      if (score.hasBeenPlayed) gamesTried++;
      totalPlays += score.timesPlayed;
      totalHighScore += score.highScore;
    }

    return OverallGameStats(
      gamesTried: gamesTried,
      totalPlays: totalPlays,
      totalHighScore: totalHighScore,
    );
  }

  @override
  List<Object?> get props => [gamesTried, totalPlays, totalHighScore];
}
