import 'package:flutter/material.dart';
import 'package:lms_mobile_app/src/features/achievements/domain/achievement.dart';
import 'package:lms_mobile_app/src/features/home/domain/entities/home_stats.entity.dart';

/// The single source of truth for the app's achievements. Every entry is
/// derived from *real* learning stats ([HomeStatsEntity]) so progress always
/// reflects what the learner actually did — nothing is faked or stored remotely.
List<AchievementProgress> buildAchievements(HomeStatsEntity s) {
  return [
    AchievementProgress(
      def: const AchievementDef(
        id: 'lessons',
        title: 'Pelahap Materi',
        subtitle: 'Selesaikan lesson',
        icon: Icons.menu_book_rounded,
        unit: 'lesson',
        thresholds: [1, 10, 30, 75],
      ),
      value: s.completedLessons,
    ),
    AchievementProgress(
      def: const AchievementDef(
        id: 'quizzes',
        title: 'Ahli Kuis',
        subtitle: 'Tuntaskan kuis',
        icon: Icons.psychology_rounded,
        unit: 'kuis',
        thresholds: [1, 5, 15, 30],
      ),
      value: s.completedQuizzes,
    ),
    AchievementProgress(
      def: const AchievementDef(
        id: 'courses',
        title: 'Juara Kelas',
        subtitle: 'Tuntaskan course 100%',
        icon: Icons.emoji_events_rounded,
        unit: 'kelas',
        thresholds: [1, 2, 5, 10],
      ),
      value: s.completedCourses,
    ),
    AchievementProgress(
      def: const AchievementDef(
        id: 'progress',
        title: 'Konsistensi',
        subtitle: 'Naikkan progres keseluruhan',
        icon: Icons.trending_up_rounded,
        unit: '%',
        thresholds: [25, 50, 80, 100],
      ),
      value: s.overallProgressPercentage,
    ),
    AchievementProgress(
      def: const AchievementDef(
        id: 'explorer',
        title: 'Penjelajah Ilmu',
        subtitle: 'Ikuti beragam kelas',
        icon: Icons.explore_rounded,
        unit: 'kelas',
        thresholds: [1, 3, 6, 10],
      ),
      value: s.totalCourses,
    ),
    AchievementProgress(
      def: const AchievementDef(
        id: 'grind',
        title: 'Kolektor Poin',
        subtitle: 'Kumpulkan aktivitas belajar',
        icon: Icons.auto_awesome_rounded,
        unit: 'aktivitas',
        thresholds: [5, 25, 60, 150],
      ),
      value: s.completedLessons + s.completedQuizzes,
    ),
  ];
}

/// Aggregate stats over the whole achievement set: total points, the learner's
/// level (100 pts per level) and how many tier-steps have been earned.
class AchievementSummary {
  /// Sum of points across every achievement.
  final int totalPoints;

  /// 1-based level number.
  final int level;
  final String levelTitle;

  /// Points accumulated within the current level (0..[pointsPerLevel]).
  final int pointsIntoLevel;
  final int pointsPerLevel;

  /// Earned tier-steps (each achievement contributes 0..4) and the max possible.
  final int earnedTiers;
  final int totalTiers;

  const AchievementSummary({
    required this.totalPoints,
    required this.level,
    required this.levelTitle,
    required this.pointsIntoLevel,
    required this.pointsPerLevel,
    required this.earnedTiers,
    required this.totalTiers,
  });

  double get levelProgress =>
      pointsPerLevel == 0 ? 1 : pointsIntoLevel / pointsPerLevel;

  static const List<String> _titles = [
    'Pemula',
    'Pelajar',
    'Rajin',
    'Mahir',
    'Ahli',
    'Juara',
    'Maestro',
    'Legenda',
  ];

  factory AchievementSummary.from(List<AchievementProgress> list) {
    const perLevel = 100;
    final totalPoints = list.fold<int>(0, (sum, a) => sum + a.points);
    final earnedTiers = list.fold<int>(0, (sum, a) => sum + a.tier.index);
    final totalTiers = list.length * 4;
    final levelIndex = totalPoints ~/ perLevel;
    final titleIndex =
        levelIndex >= _titles.length ? _titles.length - 1 : levelIndex;

    return AchievementSummary(
      totalPoints: totalPoints,
      level: levelIndex + 1,
      levelTitle: _titles[titleIndex],
      pointsIntoLevel: totalPoints % perLevel,
      pointsPerLevel: perLevel,
      earnedTiers: earnedTiers,
      totalTiers: totalTiers,
    );
  }
}
