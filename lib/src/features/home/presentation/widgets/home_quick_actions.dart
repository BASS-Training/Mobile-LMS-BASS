import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lms_mobile_app/src/core/config/constants/app_routes.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';
import 'package:lms_mobile_app/src/shared/styles/app_measures.dart';
import 'package:lms_mobile_app/src/shared/styles/app_shadows.dart';
import 'package:lms_mobile_app/src/shared/widgets/press_scale.dart';

/// Grid of quick shortcuts to the most useful destinations. Laid out as a
/// 2-row, 4-column grid so the (growing) list of shortcuts stays tidy and
/// fully visible without an overflowing single row or a "more" sheet.
class HomeQuickActions extends StatelessWidget {
  final VoidCallback onShowCourses;

  /// Instruktur/admin: memakai grid 8 pintasan yang sama seperti peserta, hanya
  /// "Penugasan" mengarah ke antrian penilaian & "Sertifikat" diganti "Peserta".
  final bool canManage;

  const HomeQuickActions({
    super.key,
    required this.onShowCourses,
    this.canManage = false,
  });

  @override
  Widget build(BuildContext context) {
    // Instruktur/admin memakai grid 8 pintasan yang SAMA dengan peserta, hanya
    // dua yang berbeda maknanya:
    //  - "Penugasan" → antrian penilaian (instruktur menilai, bukan mengerjakan)
    //  - "Sertifikat" diganti "Peserta" (progres peserta)
    final actions = canManage
        ? <_QuickAction>[
            // Baris 1 — inti pengelolaan.
            _QuickAction(
              icon: Icons.assignment_turned_in_rounded,
              label: 'Penugasan',
              color: const Color(0xFFD97706),
              onTap: () => context.push(
                AppRoutes.instructorGradingQueue,
                extra: {'courseId': ''},
              ),
            ),
            _QuickAction(
              icon: Icons.grid_view_rounded,
              label: 'Kursus',
              color: AppColors.brandPrimary,
              onTap: onShowCourses,
            ),
            _QuickAction(
              icon: Icons.forum_rounded,
              label: 'Diskusi',
              color: const Color(0xFF3B82F6),
              onTap: () => context.push(AppRoutes.discussionHub),
            ),
            _QuickAction(
              icon: Icons.event_rounded,
              label: 'Jadwal',
              color: const Color(0xFF0EA5E9),
              onTap: () => context.push(AppRoutes.agenda),
            ),
            // Baris 2 — pemantauan & pelengkap.
            _QuickAction(
              icon: Icons.insights_rounded,
              label: 'Peserta',
              color: const Color(0xFF0F766E),
              onTap: () => context.push(AppRoutes.instructorHub),
            ),
            _QuickAction(
              icon: Icons.vpn_key_rounded,
              label: 'Gabung Kelas',
              color: AppColors.success,
              onTap: () => context.push(AppRoutes.joinClass),
            ),
            _QuickAction(
              icon: Icons.sports_esports_rounded,
              label: 'Game',
              color: const Color(0xFF7C4DFF),
              onTap: () => context.push(AppRoutes.gamesHub),
            ),
            _QuickAction(
              icon: Icons.emoji_events_rounded,
              label: 'Pencapaian',
              color: const Color(0xFFF59E0B),
              onTap: () => context.push(AppRoutes.achievements),
            ),
          ]
        : <_QuickAction>[
            // Baris 1 — aktivitas belajar inti.
            _QuickAction(
              icon: Icons.assignment_turned_in_rounded,
              label: 'Penugasan',
              color: const Color(0xFFD97706),
              onTap: () => context.push(AppRoutes.assignments),
            ),
            _QuickAction(
              icon: Icons.grid_view_rounded,
              label: 'Kursus',
              color: AppColors.brandPrimary,
              onTap: onShowCourses,
            ),
            _QuickAction(
              icon: Icons.forum_rounded,
              label: 'Diskusi',
              color: const Color(0xFF3B82F6),
              onTap: () => context.push(AppRoutes.discussionHub),
            ),
            _QuickAction(
              icon: Icons.event_rounded,
              label: 'Jadwal',
              color: const Color(0xFF0EA5E9),
              onTap: () => context.push(AppRoutes.agenda),
            ),
            // Baris 2 — pencapaian & pelengkap.
            _QuickAction(
              icon: Icons.workspace_premium_rounded,
              label: 'Sertifikat',
              color: AppColors.warning,
              onTap: () => context.push(AppRoutes.certificateList),
            ),
            _QuickAction(
              icon: Icons.vpn_key_rounded,
              label: 'Gabung Kelas',
              color: AppColors.success,
              onTap: () => context.push(AppRoutes.joinClass),
            ),
            _QuickAction(
              icon: Icons.sports_esports_rounded,
              label: 'Game',
              color: const Color(0xFF7C4DFF),
              onTap: () => context.push(AppRoutes.gamesHub),
            ),
            _QuickAction(
              icon: Icons.emoji_events_rounded,
              label: 'Pencapaian',
              color: const Color(0xFFF59E0B),
              onTap: () => context.push(AppRoutes.achievements),
            ),
          ];

    const columns = 4;
    const gap = 12.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppMeasures.paddingLarge),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final itemWidth =
              (constraints.maxWidth - (columns - 1) * gap) / columns;
          return Wrap(
            spacing: gap,
            runSpacing: gap,
            children: [
              for (final action in actions)
                SizedBox(width: itemWidth, child: action),
            ],
          );
        },
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
                boxShadow: AppShadows.xs,
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
              style: TextStyle(
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
