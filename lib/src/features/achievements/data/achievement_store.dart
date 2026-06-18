import 'package:hive_flutter/hive_flutter.dart';
import 'package:lms_mobile_app/src/features/achievements/domain/achievement.dart';

/// Local (Hive) memory of which achievement tiers we have already celebrated,
/// so the app can pop a celebration the moment a learner reaches a *new* tier.
///
/// Hive itself is initialised by core DI; we just open a dedicated box lazily,
/// mirroring [GameLocalDataSource].
class AchievementStore {
  static const String _boxName = 'bass_achievements_box';
  static const String _seenKey = 'seen_tiers';
  static const String _initKey = 'initialized';

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

  /// Compares the freshly computed [current] tiers against what was last
  /// celebrated and returns every achievement that just stepped up to a higher
  /// tier. The very first call (no baseline yet) seeds silently — pre-existing
  /// progress is *not* celebrated retroactively.
  Future<List<AchievementProgress>> detectNewlyUnlocked(
    List<AchievementProgress> current,
  ) async {
    final box = await _box();
    final initialized = box.get(_initKey) == true;

    final raw = box.get(_seenKey);
    final seen = <String, int>{};
    if (raw is Map) {
      raw.forEach((k, v) {
        if (k is String && v is int) seen[k] = v;
      });
    }

    final newlyUnlocked = <AchievementProgress>[];
    final updated = <String, int>{};
    for (final a in current) {
      final prev = seen[a.def.id] ?? 0;
      final now = a.tier.index;
      updated[a.def.id] = now > prev ? now : prev;
      if (initialized && now > prev) newlyUnlocked.add(a);
    }

    await box.put(_seenKey, updated);
    await box.put(_initKey, true);

    return initialized ? newlyUnlocked : const [];
  }
}
