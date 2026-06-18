import 'package:flutter/material.dart';
import 'package:lms_mobile_app/src/features/achievements/domain/achievement.dart';
import 'package:lms_mobile_app/src/features/achievements/presentation/widgets/achievement_medal.dart';
import 'package:lms_mobile_app/src/features/achievements/presentation/widgets/confetti_overlay.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';
import 'package:lms_mobile_app/src/shared/styles/app_shadows.dart';

/// Shows a celebratory dialog for each newly reached tier, one after another.
///
/// Returns once every celebration has been dismissed. Safe to call with an
/// empty list (no-op).
Future<void> showAchievementCelebrations(
  BuildContext context,
  List<AchievementProgress> unlocked,
) async {
  for (final a in unlocked) {
    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (_) => _CelebrationDialog(achievement: a),
    );
  }
}

class _CelebrationDialog extends StatefulWidget {
  final AchievementProgress achievement;

  const _CelebrationDialog({required this.achievement});

  @override
  State<_CelebrationDialog> createState() => _CelebrationDialogState();
}

class _CelebrationDialogState extends State<_CelebrationDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pop;

  @override
  void initState() {
    super.initState();
    _pop = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    )..forward();
  }

  @override
  void dispose() {
    _pop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.achievement;
    final tier = a.tier;
    final scale = CurvedAnimation(parent: _pop, curve: Curves.elasticOut);

    return Stack(
      children: [
        Positioned.fill(
          child: ConfettiOverlay(
            colors: [
              tier.color,
              tier.colorLight,
              AppColors.brandPrimary,
              AppColors.warning,
              AppColors.success,
            ],
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 22),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: AppShadows.md,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ScaleTransition(
                      scale: scale,
                      child: AchievementMedal(
                        icon: a.def.icon,
                        tier: tier,
                        size: 96,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Tingkat ${tier.label}!',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                        color: tier.color,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      a.def.title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      a.maxed
                          ? 'Sempurna! Kamu sudah memaksimalkan pencapaian ini. 🏆'
                          : 'Kerja bagus! Teruskan untuk meraih tingkat berikutnya.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13.5,
                        height: 1.4,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: AppColors.warning,
                            size: 18,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '+${tier.award} poin',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppColors.warning,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.brandPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text(
                          'Mantap!',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
