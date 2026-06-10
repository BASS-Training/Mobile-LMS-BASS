import '../../domain/entities/game_score.dart';

/// Maps a [GameScore] to/from the plain Map form persisted in Hive.
/// Stored as a primitive Map (no Hive TypeAdapter codegen) to stay consistent
/// with the rest of the app's local storage approach.
class GameScoreModel {
  static GameScore fromMap(String gameId, Map<dynamic, dynamic> map) {
    final lastPlayedRaw = map['lastPlayedAt'];
    return GameScore(
      gameId: gameId,
      highScore: _asInt(map['highScore']),
      lastScore: _asInt(map['lastScore']),
      timesPlayed: _asInt(map['timesPlayed']),
      lastPlayedAt: lastPlayedRaw is String
          ? DateTime.tryParse(lastPlayedRaw)
          : null,
    );
  }

  static Map<String, dynamic> toMap(GameScore score) {
    return {
      'highScore': score.highScore,
      'lastScore': score.lastScore,
      'timesPlayed': score.timesPlayed,
      'lastPlayedAt': score.lastPlayedAt?.toIso8601String(),
    };
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
