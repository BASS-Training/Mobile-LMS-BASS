import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lms_mobile_app/src/core/config/constants/app_routes.dart';
import 'package:lms_mobile_app/src/features/achievements/domain/achievement.dart';
import 'package:lms_mobile_app/src/features/achievements/domain/achievement_catalog.dart';
import 'package:lms_mobile_app/src/features/achievements/presentation/widgets/achievement_medal.dart';
import 'package:lms_mobile_app/src/features/home/domain/entities/home_stats.entity.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';
import 'package:lms_mobile_app/src/shared/styles/app_measures.dart';
import 'package:lms_mobile_app/src/shared/styles/app_shadows.dart';
import 'package:lms_mobile_app/src/shared/widgets/press_scale.dart';

/// Home teaser for the achievements feature. Shows the learner's real level and
/// their most-progressed tiered badges (a preview of the dedicated page), so it
/// always matches what they actually own. Tapping anywhere opens the full page.
class HomeAchievements extends StatelessWidget {
  final HomeStatsEntity stats;

  const HomeAchievements({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final achievements = buildAchievements(stats);
    final summary = AchievementSummary.from(achievements);

    // Surface the most impressive badges first: highest tier, then closest to
    // the next tier. Show the top four as a preview.
    final preview = [...achievements]
      ..sort((a, b) {
        final byTier = b.tier.index.compareTo(a.tier.index);
        if (byTier != 0) return byTier;
        return b.progress.compareTo(a.progress);
      });
    final shown = preview.take(4).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppMeasures.paddingLarge),
      child: PressScale(
        pressedScale: 0.98,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => context.push(AppRoutes.achievements, extra: stats),
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
                    _LevelChip(summary: summary),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                      color: AppColors.textTertiary,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '${summary.earnedTiers}/${summary.totalTiers} tingkat lencana diraih · ${summary.totalPoints} poin',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    for (final a in shown)
                      Expanded(child: _BadgeView(progress: a)),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Lihat semua pencapaian',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.brandText,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 15,
                      color: AppColors.brandText,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Small "Lv N" pill summarising the learner's overall level.
class _LevelChip extends StatelessWidget {
  final AchievementSummary summary;

  const _LevelChip({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.brandPrimary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.workspace_premium_rounded,
            size: 14,
            color: AppColors.brandText,
          ),
          const SizedBox(width: 4),
          Text(
            'Lv ${summary.level}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.brandText,
            ),
          ),
        ],
      ),
    );
  }
}

/// One preview badge: the real tier medal plus the achievement's title.
class _BadgeView extends StatelessWidget {
  final AchievementProgress progress;

  const _BadgeView({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AchievementMedal(
          icon: progress.def.icon,
          tier: progress.tier,
          size: 54,
        ),
        const SizedBox(height: 8),
        Text(
          progress.def.title,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 10.5,
            height: 1.2,
            fontWeight: FontWeight.w600,
            color: progress.unlocked
                ? AppColors.textPrimary
                : AppColors.textTertiary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          progress.unlocked ? progress.tier.label : 'Terkunci',
          style: TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
            color: progress.unlocked
                ? progress.tier.color
                : AppColors.textTertiary,
          ),
        ),
      ],
    );
  }
}
