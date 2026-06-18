import 'package:flutter/material.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';

/// Achievement tiers in ascending order. [none] = not yet unlocked.
///
/// The built-in `enum.index` is the ordinal (none=0 … platinum=4) and is used
/// throughout for "how far along" comparisons and celebration detection.
enum AchievementTier { none, bronze, silver, gold, platinum }

extension AchievementTierX on AchievementTier {
  String get label {
    switch (this) {
      case AchievementTier.none:
        return 'Terkunci';
      case AchievementTier.bronze:
        return 'Perunggu';
      case AchievementTier.silver:
        return 'Perak';
      case AchievementTier.gold:
        return 'Emas';
      case AchievementTier.platinum:
        return 'Platinum';
    }
  }

  /// Primary colour for the tier's medal & accents.
  Color get color {
    switch (this) {
      case AchievementTier.none:
        return AppColors.textTertiary;
      case AchievementTier.bronze:
        return const Color(0xFFCD7F32);
      case AchievementTier.silver:
        return const Color(0xFF9AA7B0);
      case AchievementTier.gold:
        return const Color(0xFFE8A92E);
      case AchievementTier.platinum:
        return const Color(0xFF3FB6C9);
    }
  }

  /// A slightly lighter partner colour for medal gradients.
  Color get colorLight {
    switch (this) {
      case AchievementTier.none:
        return AppColors.textTertiary;
      case AchievementTier.bronze:
        return const Color(0xFFE9A368);
      case AchievementTier.silver:
        return const Color(0xFFC5CED5);
      case AchievementTier.gold:
        return const Color(0xFFF6C95B);
      case AchievementTier.platinum:
        return const Color(0xFF7BD6E3);
    }
  }

  /// Points awarded for *reaching* this tier. Summed across reached tiers, a
  /// fully maxed achievement is worth 100 points.
  int get award {
    switch (this) {
      case AchievementTier.none:
        return 0;
      case AchievementTier.bronze:
        return 10;
      case AchievementTier.silver:
        return 20;
      case AchievementTier.gold:
        return 30;
      case AchievementTier.platinum:
        return 40;
    }
  }
}

/// A single tiered achievement: one real learning metric with four ascending
/// thresholds (bronze → silver → gold → platinum).
class AchievementDef {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;

  /// Singular noun the count refers to, e.g. "lesson", "kuis".
  final String unit;

  /// Thresholds for bronze, silver, gold, platinum (ascending, exactly 4).
  final List<int> thresholds;

  const AchievementDef({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.unit,
    required this.thresholds,
  });
}

/// A definition combined with the user's current value — computes the earned
/// tier, progress toward the next tier and the points earned.
class AchievementProgress {
  final AchievementDef def;
  final int value;

  const AchievementProgress({required this.def, required this.value});

  AchievementTier get tier {
    final t = def.thresholds;
    if (value >= t[3]) return AchievementTier.platinum;
    if (value >= t[2]) return AchievementTier.gold;
    if (value >= t[1]) return AchievementTier.silver;
    if (value >= t[0]) return AchievementTier.bronze;
    return AchievementTier.none;
  }

  bool get unlocked => tier != AchievementTier.none;
  bool get maxed => tier == AchievementTier.platinum;

  /// The next threshold to reach, or null when maxed.
  int? get nextThreshold {
    for (final th in def.thresholds) {
      if (value < th) return th;
    }
    return null;
  }

  /// Threshold of the current tier (0 when still locked).
  int get currentThreshold {
    final t = def.thresholds;
    if (value >= t[3]) return t[3];
    if (value >= t[2]) return t[2];
    if (value >= t[1]) return t[1];
    if (value >= t[0]) return t[0];
    return 0;
  }

  /// Progress toward the next tier, 0..1 (1.0 when maxed).
  double get progress {
    final next = nextThreshold;
    if (next == null) return 1;
    final base = currentThreshold;
    final span = next - base;
    if (span <= 0) return 1;
    return ((value - base) / span).clamp(0.0, 1.0);
  }

  /// Total points earned = sum of awards for every tier reached so far.
  int get points {
    var p = 0;
    for (final tr in AchievementTier.values) {
      if (tr.index >= 1 && tr.index <= tier.index) p += tr.award;
    }
    return p;
  }
}
