import 'package:hive_flutter/hive_flutter.dart';

import '../../domain/entities/game_score.dart';
import '../models/game_score_model.dart';

/// Local (Hive) persistence for mini game scores and resumable board state.
///
/// Uses a dedicated box, opened lazily on first access. Hive itself is already
/// initialized by [LocalStorage.init] during core DI setup, so we only need to
/// open our box here. Score records live under `score_<gameId>`; board state
/// under `board_<gameId>` / `board_score_<gameId>`.
abstract class GameLocalDataSource {
  Future<GameScore> getScore(String gameId);
  Future<List<GameScore>> getAllScores();
  Future<GameScore> submitResult({required String gameId, required int score});
  Future<List<int>?> getSavedBoard(String gameId);
  Future<void> saveBoard({
    required String gameId,
    required List<int> board,
    required int score,
  });
  Future<int> getSavedBoardScore(String gameId);
  Future<void> clearBoard(String gameId);
}

class GameLocalDataSourceImpl implements GameLocalDataSource {
  static const String _boxName = 'bass_games_box';
  static const String _scorePrefix = 'score_';
  static const String _boardPrefix = 'board_';
  static const String _boardScorePrefix = 'board_score_';

  Box? _cachedBox;

  Future<Box> _box() async {
    final cached = _cachedBox;
    if (cached != null && cached.isOpen) return cached;
    final box = Hive.isBoxOpen(_boxName)
        ? Hive.box(_boxName)
        : await Hive.openBox(_boxName);
    _cachedBox = box;
    return box;
  }

  String _scoreKey(String gameId) => '$_scorePrefix$gameId';
  String _boardKey(String gameId) => '$_boardPrefix$gameId';
  String _boardScoreKey(String gameId) => '$_boardScorePrefix$gameId';

  @override
  Future<GameScore> getScore(String gameId) async {
    final box = await _box();
    final raw = box.get(_scoreKey(gameId));
    if (raw is Map) {
      return GameScoreModel.fromMap(gameId, raw);
    }
    return GameScore.empty(gameId);
  }

  @override
  Future<List<GameScore>> getAllScores() async {
    final box = await _box();
    final scores = <GameScore>[];
    for (final key in box.keys) {
      if (key is String && key.startsWith(_scorePrefix)) {
        final gameId = key.substring(_scorePrefix.length);
        final raw = box.get(key);
        if (raw is Map) {
          scores.add(GameScoreModel.fromMap(gameId, raw));
        }
      }
    }
    return scores;
  }

  @override
  Future<GameScore> submitResult({
    required String gameId,
    required int score,
  }) async {
    final box = await _box();
    final current = await getScore(gameId);
    final updated = current.registerResult(score);
    await box.put(_scoreKey(gameId), GameScoreModel.toMap(updated));
    return updated;
  }

  @override
  Future<List<int>?> getSavedBoard(String gameId) async {
    final box = await _box();
    final raw = box.get(_boardKey(gameId));
    if (raw is List) {
      return raw.map((e) => e is int ? e : int.tryParse('$e') ?? 0).toList();
    }
    return null;
  }

  @override
  Future<int> getSavedBoardScore(String gameId) async {
    final box = await _box();
    final raw = box.get(_boardScoreKey(gameId));
    return raw is int ? raw : 0;
  }

  @override
  Future<void> saveBoard({
    required String gameId,
    required List<int> board,
    required int score,
  }) async {
    final box = await _box();
    await box.put(_boardKey(gameId), board);
    await box.put(_boardScoreKey(gameId), score);
  }

  @override
  Future<void> clearBoard(String gameId) async {
    final box = await _box();
    await box.delete(_boardKey(gameId));
    await box.delete(_boardScoreKey(gameId));
  }
}
