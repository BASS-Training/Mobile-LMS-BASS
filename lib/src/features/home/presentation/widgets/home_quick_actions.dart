import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lms_mobile_app/src/core/config/constants/app_routes.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';
import 'package:lms_mobile_app/src/shared/styles/app_measures.dart';
import 'package:lms_mobile_app/src/shared/widgets/press_scale.dart';

/// Row of quick shortcuts to the most useful destinations. Surfaces actions
/// (certificates, joining a class) that would otherwise be buried.
class HomeQuickActions extends StatelessWidget {
  final VoidCallback onShowCourses;
  final VoidCallback onShowSaved;

  const HomeQuickActions({
    super.key,
    required this.onShowCourses,
    required this.onShowSaved,
  });

  @override
  Widget build(BuildContext context) {
    final actions = [
      _QuickAction(
        icon: Icons.workspace_premium_rounded,
        label: 'Sertifikat',
        color: AppColors.warning,
        onTap: () => context.push(AppRoutes.certificateList),
      ),
      _QuickAction(
        icon: Icons.grid_view_rounded,
        label: 'Kursus',
        color: AppColors.brandPrimary,
        onTap: onShowCourses,
      ),
      _QuickAction(
        icon: Icons.bookmark_rounded,
        label: 'Tersimpan',
        color: AppColors.info,
        onTap: onShowSaved,
      ),
      _QuickAction(
        icon: Icons.vpn_key_rounded,
        label: 'Gabung Kelas',
        color: AppColors.success,
        onTap: () => context.push(AppRoutes.joinClass),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppMeasures.paddingLarge),
      child: Row(
        children: [
          for (var i = 0; i < actions.length; i++) ...[
            if (i > 0) const SizedBox(width: 12),
            Expanded(child: actions[i]),
          ],
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return PressScale(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          children: [
            Container(
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Center(
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(icon, color: color, size: 19),
                ),
              ),
            ),
            const SizedBox(height: 7),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
