import 'package:flutter/material.dart';
import 'package:lms_mobile_app/src/features/achievements/domain/achievement.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';
import 'package:lms_mobile_app/src/shared/styles/app_shadows.dart';

/// A circular tier medal: the achievement icon set on a tier-coloured disc with
/// a subtle rim. Locked achievements render muted with a small lock badge.
class AchievementMedal extends StatelessWidget {
  final IconData icon;
  final AchievementTier tier;
  final double size;

  const AchievementMedal({
    super.key,
    required this.icon,
    required this.tier,
    this.size = 56,
  });

  @override
  Widget build(BuildContext context) {
    final locked = tier == AchievementTier.none;
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: locked
                ? null
                : LinearGradient(
                    colors: [tier.colorLight, tier.color],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            color: locked ? AppColors.surfaceMuted : null,
            boxShadow: locked ? null : AppShadows.brand(tier.color, opacity: 0.32),
            border: Border.all(
              color: locked
                  ? AppColors.borderDefault
                  : Colors.white.withValues(alpha: 0.55),
              width: 2,
            ),
          ),
          child: Icon(
            icon,
            size: size * 0.45,
            color: locked ? AppColors.textTertiary : Colors.white,
          ),
        ),
        if (locked)
          Positioned(
            right: size * 0.04,
            bottom: size * 0.04,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Icon(
                Icons.lock_rounded,
                size: size * 0.18,
                color: AppColors.textTertiary,
              ),
            ),
          ),
      ],
    );
  }
}

/// A small pill showing the tier name in the tier colour (or "Terkunci").
class TierChip extends StatelessWidget {
  final AchievementTier tier;

  const TierChip({super.key, required this.tier});

  @override
  Widget build(BuildContext context) {
    final locked = tier == AchievementTier.none;
    final color = tier.color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: locked
            ? AppColors.surfaceMuted
            : color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        tier.label,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.2,
          color: locked ? AppColors.textTertiary : color,
        ),
      ),
    );
  }
}
