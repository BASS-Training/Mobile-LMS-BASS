import 'package:equatable/equatable.dart';

/// Per-game progress record. This is the single source of truth for scoring;
/// aggregate/overall stats (total plays, games tried, total points) are derived
/// from a collection of these — never stored separately — to avoid drift.
class GameScore extends Equatable {
  final String gameId;
  final int highScore;
  final int lastScore;
  final int timesPlayed;
  final DateTime? lastPlayedAt;

  const GameScore({
    required this.gameId,
    this.highScore = 0,
    this.lastScore = 0,
    this.timesPlayed = 0,
    this.lastPlayedAt,
  });

  /// A fresh, never-played record for [gameId].
  factory GameScore.empty(String gameId) => GameScore(gameId: gameId);

  bool get hasBeenPlayed => timesPlayed > 0;

  /// Returns the record updated with the outcome of a finished round.
  /// Keeps the best [highScore] seen so far.
  GameScore registerResult(int score) {
    return GameScore(
      gameId: gameId,
      highScore: score > highScore ? score : highScore,
      lastScore: score,
      timesPlayed: timesPlayed + 1,
      lastPlayedAt: DateTime.now(),
    );
  }

  GameScore copyWith({
    int? highScore,
    int? lastScore,
    int? timesPlayed,
    DateTime? lastPlayedAt,
  }) {
    return GameScore(
      gameId: gameId,
      highScore: highScore ?? this.highScore,
      lastScore: lastScore ?? this.lastScore,
      timesPlayed: timesPlayed ?? this.timesPlayed,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
    );
  }

  @override
  List<Object?> get props => [
    gameId,
    highScore,
    lastScore,
    timesPlayed,
    lastPlayedAt,
  ];
}
