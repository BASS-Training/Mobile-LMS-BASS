import 'dart:math' as math;

import 'package:hive_flutter/hive_flutter.dart';
import 'package:lms_mobile_app/src/core/utils/local_storage.dart';
import 'package:lms_mobile_app/src/features/achievements/data/achievement_remote_data_source.dart';
import 'package:lms_mobile_app/src/features/achievements/domain/achievement.dart';

/// Local (Hive) memory of which achievement tiers we have already celebrated,
/// so the app can pop a celebration the moment a learner reaches a *new* tier.
///
/// Hive itself is initialised by core DI; we just open a dedicated box lazily,
/// mirroring [GameLocalDataSource].
///
/// Baseline perayaan di-scope per user ([LocalStorage.scopedKey]) supaya tidak
/// tercampur antar-akun di perangkat yang sama. Akun baru mulai tanpa baseline
/// sehingga tier yang sudah ada tidak dirayakan ulang secara retroaktif.
class AchievementStore {
  static const String _boxName = 'bass_achievements_box';
  static const String _seenKeyBase = 'seen_tiers';
  static const String _initKeyBase = 'initialized';

  final AchievementRemoteDataSource? remote;

  AchievementStore({this.remote});

  String get _seenKey => LocalStorage.scopedKey(_seenKeyBase);
  String get _initKey => LocalStorage.scopedKey(_initKeyBase);

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
    var initialized = box.get(_initKey) == true;

    final raw = box.get(_seenKey);
    final seen = <String, int>{};
    if (raw is Map) {
      raw.forEach((k, v) {
        if (k is String && v is int) seen[k] = v;
      });
    }

    // Gabungkan baseline dari server agar perayaan tidak muncul ulang di device
    // baru. Jika server sudah punya baseline, anggap sudah ter-inisialisasi.
    final r = remote;
    if (r != null) {
      try {
        final serverTiers = await r.fetchTiers();
        if (serverTiers.isNotEmpty) initialized = true;
        serverTiers.forEach((k, v) {
          seen[k] = math.max(seen[k] ?? 0, v);
        });
      } catch (_) {
        // offline → pakai baseline lokal saja
      }
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

    // Dorong baseline terbaru ke server (best-effort) agar tersinkron.
    if (r != null) {
      try {
        await r.syncTiers(updated);
      } catch (_) {}
    }

    return initialized ? newlyUnlocked : const [];
  }
}
