import 'package:flutter/material.dart';
import 'package:lms_mobile_app/src/core/di/injector.dart';
import 'package:lms_mobile_app/src/features/achievements/data/achievement_store.dart';
import 'package:lms_mobile_app/src/features/achievements/domain/achievement.dart';
import 'package:lms_mobile_app/src/features/achievements/domain/achievement_catalog.dart';
import 'package:lms_mobile_app/src/features/achievements/presentation/widgets/achievement_celebration.dart';
import 'package:lms_mobile_app/src/features/achievements/presentation/widgets/achievement_medal.dart';
import 'package:lms_mobile_app/src/features/home/domain/entities/home_stats.entity.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';
import 'package:lms_mobile_app/src/shared/styles/app_shadows.dart';
import 'package:lms_mobile_app/src/shared/widgets/brand_app_bar.dart';
import 'package:lms_mobile_app/src/shared/widgets/fade_slide_in.dart';
import 'package:lms_mobile_app/src/shared/widgets/press_scale.dart';

/// Dedicated, Duolingo-style achievements page: a level hero card on top, then
/// a grid of tiered badges. Everything is computed from real learning stats.
class AchievementsScreen extends StatefulWidget {
  final HomeStatsEntity stats;

  const AchievementsScreen({super.key, required this.stats});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  final _store = ServiceLocator().locator<AchievementStore>();
  late final List<AchievementProgress> _achievements;
  late final AchievementSummary _summary;

  @override
  void initState() {
    super.initState();
    _achievements = buildAchievements(widget.stats);
    _summary = AchievementSummary.from(_achievements);
    // Opening the page is a reliable moment to celebrate any tier that became
    // available since the learner last saw it.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final unlocked = await _store.detectNewlyUnlocked(_achievements);
      if (!mounted) return;
      await showAchievementCelebrations(context, unlocked);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const BrandAppBar(title: 'Pencapaian'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          FadeSlideIn(child: _LevelHero(summary: _summary)),
          const SizedBox(height: 22),
          Text(
            'Lencana',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tiap lencana punya 4 tingkat: Perunggu, Perak, Emas, Platinum.',
            style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 14),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _achievements.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.82,
            ),
            itemBuilder: (context, i) => FadeSlideIn(
              delayMs: 60 + i * 40,
              child: _AchievementCard(progress: _achievements[i]),
            ),
          ),
        ],
      ),
    );
  }
}

/// The brand-gradient hero: level ring, title, points and progress to next level.
class _LevelHero extends StatelessWidget {
  final AchievementSummary summary;

  const _LevelHero({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.brandGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppShadows.brand(AppColors.brandPrimary, opacity: 0.32),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _LevelRing(level: summary.level, progress: summary.levelProgress),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Level ${summary.level}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      summary.levelTitle,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${summary.totalPoints} poin',
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.military_tech_rounded,
                          color: Colors.white.withValues(alpha: 0.9),
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${summary.earnedTiers}/${summary.totalTiers} tingkat',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: summary.levelProgress,
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.25),
              valueColor: const AlwaysStoppedAnimation(Colors.white),
            ),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              summary.pointsIntoLevel == 0 && summary.totalPoints > 0
                  ? 'Level naik! 🎉'
                  : '${summary.pointsPerLevel - summary.pointsIntoLevel} poin lagi ke Level ${summary.level + 1}',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelRing extends StatelessWidget {
  final int level;
  final double progress;

  const _LevelRing({required this.level, required this.progress});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      height: 72,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 72,
            height: 72,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 6,
              backgroundColor: Colors.white.withValues(alpha: 0.25),
              valueColor: const AlwaysStoppedAnimation(Colors.white),
            ),
          ),
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '$level',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final AchievementProgress progress;

  const _AchievementCard({required this.progress});

  void _showDetail(BuildContext context) {
    final a = progress;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _AchievementDetailSheet(progress: a),
    );
  }

  @override
  Widget build(BuildContext context) {
    final a = progress;
    final next = a.nextThreshold;
    return PressScale(
      pressedScale: 0.96,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _showDetail(context),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderSubtle),
            boxShadow: AppShadows.xs,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AchievementMedal(icon: a.def.icon, tier: a.tier, size: 58),
              const SizedBox(height: 10),
              Text(
                a.def.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              TierChip(tier: a.tier),
              const Spacer(),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: a.progress,
                  minHeight: 6,
                  backgroundColor: AppColors.surfaceMuted,
                  valueColor: AlwaysStoppedAnimation(
                    a.unlocked ? a.tier.color : AppColors.brandPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                a.maxed
                    ? 'Maks • ${a.value} ${a.def.unit}'
                    : '${a.value}/$next ${a.def.unit}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Detail sheet listing all four tiers for one achievement, marking which are
/// reached and showing the active goal.
class _AchievementDetailSheet extends StatelessWidget {
  final AchievementProgress progress;

  const _AchievementDetailSheet({required this.progress});

  @override
  Widget build(BuildContext context) {
    final a = progress;
    final tiers = [
      AchievementTier.bronze,
      AchievementTier.silver,
      AchievementTier.gold,
      AchievementTier.platinum,
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AchievementMedal(icon: a.def.icon, tier: a.tier, size: 52),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      a.def.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      a.def.subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          for (var i = 0; i < tiers.length; i++)
            _TierRow(
              tier: tiers[i],
              threshold: a.def.thresholds[i],
              unit: a.def.unit,
              reached: a.value >= a.def.thresholds[i],
              isCurrentGoal: a.nextThreshold == a.def.thresholds[i],
            ),
        ],
      ),
    );
  }
}

class _TierRow extends StatelessWidget {
  final AchievementTier tier;
  final int threshold;
  final String unit;
  final bool reached;
  final bool isCurrentGoal;

  const _TierRow({
    required this.tier,
    required this.threshold,
    required this.unit,
    required this.reached,
    required this.isCurrentGoal,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isCurrentGoal
            ? tier.color.withValues(alpha: 0.08)
            : AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isCurrentGoal ? tier.color.withValues(alpha: 0.5) : AppColors.borderSubtle,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: reached
                  ? LinearGradient(colors: [tier.colorLight, tier.color])
                  : null,
              color: reached ? null : AppColors.surface,
              border: reached ? null : Border.all(color: AppColors.borderDefault),
            ),
            child: Icon(
              reached ? Icons.check_rounded : Icons.lock_rounded,
              size: 17,
              color: reached ? Colors.white : AppColors.textTertiary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              tier.label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: reached ? AppColors.textPrimary : AppColors.textSecondary,
              ),
            ),
          ),
          Text(
            '$threshold $unit',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: reached ? tier.color : AppColors.textTertiary,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '+${tier.award}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.warning,
            ),
          ),
        ],
      ),
    );
  }
}
