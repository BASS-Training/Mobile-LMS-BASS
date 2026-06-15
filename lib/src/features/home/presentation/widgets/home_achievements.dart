import 'package:flutter/material.dart';
import 'package:lms_mobile_app/src/features/home/domain/entities/home_stats.entity.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';
import 'package:lms_mobile_app/src/shared/styles/app_measures.dart';
import 'package:lms_mobile_app/src/shared/styles/app_shadows.dart';
import 'package:lms_mobile_app/src/shared/widgets/press_scale.dart';

/// Gamified achievements strip. Every badge is derived from *real* learning
/// stats, so progress feels earned. Tapping a badge explains how to unlock it.
class HomeAchievements extends StatelessWidget {
  final HomeStatsEntity stats;

  const HomeAchievements({super.key, required this.stats});

  List<_Badge> _badges() => [
    _Badge(
      icon: Icons.flag_rounded,
      label: 'Langkah\nPertama',
      color: AppColors.brandPrimary,
      earned: stats.completedLessons >= 1,
      hint: 'Selesaikan 1 lesson pertamamu.',
    ),
    _Badge(
      icon: Icons.local_fire_department_rounded,
      label: 'Rajin\nBelajar',
      color: AppColors.warning,
      earned: stats.completedLessons >= 5,
      hint: 'Selesaikan total 5 lesson.',
    ),
    _Badge(
      icon: Icons.psychology_rounded,
      label: 'Ahli\nKuis',
      color: AppColors.info,
      earned: stats.completedQuizzes >= 1,
      hint: 'Selesaikan minimal 1 kuis.',
    ),
    _Badge(
      icon: Icons.emoji_events_rounded,
      label: 'Juara\nCourse',
      color: AppColors.success,
      earned: stats.completedCourses >= 1,
      hint: 'Tuntaskan sebuah course hingga 100%.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final badges = _badges();
    final earnedCount = badges.where((b) => b.earned).length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppMeasures.paddingLarge),
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.borderSubtle),
          boxShadow: AppShadows.sm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Pencapaianmu',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.brandPrimary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '$earnedCount/${badges.length}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.brandPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                for (final badge in badges)
                  Expanded(child: _BadgeView(badge: badge)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge {
  final IconData icon;
  final String label;
  final Color color;
  final bool earned;
  final String hint;

  const _Badge({
    required this.icon,
    required this.label,
    required this.color,
    required this.earned,
    required this.hint,
  });
}

class _BadgeView extends StatelessWidget {
  final _Badge badge;

  const _BadgeView({required this.badge});

  @override
  Widget build(BuildContext context) {
    return PressScale(
      pressedScale: 0.93,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                badge.earned
                    ? '✅ ${badge.label.replaceAll('\n', ' ')} — sudah diraih!'
                    : '🔒 ${badge.hint}',
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        },
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: badge.earned
                        ? LinearGradient(
                            colors: [
                              badge.color,
                              badge.color.withValues(alpha: 0.7),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: badge.earned ? null : AppColors.surfaceMuted,
                    boxShadow: badge.earned
                        ? AppShadows.brand(badge.color, opacity: 0.3)
                        : null,
                  ),
                  child: Icon(
                    badge.icon,
                    color: badge.earned ? Colors.white : AppColors.textTertiary,
                    size: 26,
                  ),
                ),
                if (!badge.earned)
                  Positioned(
                    right: 2,
                    bottom: 2,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.lock_rounded,
                        size: 11,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              badge.label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10.5,
                height: 1.2,
                fontWeight: FontWeight.w600,
                color: badge.earned
                    ? AppColors.textPrimary
                    : AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
