import 'package:flutter/material.dart';
import 'package:lms_mobile_app/src/features/instructor/domain/entities/instructor_entities.dart';
import 'package:lms_mobile_app/src/features/instructor/presentation/cubit/instructor_overview_cubit.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';
import 'package:lms_mobile_app/src/shared/styles/app_measures.dart';
import 'package:lms_mobile_app/src/shared/styles/app_shadows.dart';
import 'package:lms_mobile_app/src/shared/widgets/animated_count.dart';

/// Ringkasan pengelolaan untuk instruktur/admin — menempati posisi yang sama
/// dengan [HomeSummaryCard] milik peserta, tapi isinya metrik pengelolaan:
/// berapa tugas menunggu dinilai, jumlah kelas, dan jumlah peserta.
class HomeInstructorSummary extends StatelessWidget {
  final InstructorDashboard? dashboard;
  final InstructorStatus status;

  const HomeInstructorSummary({
    super.key,
    required this.dashboard,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final loading =
        status == InstructorStatus.loading ||
        status == InstructorStatus.initial;

    final pending = dashboard?.pendingGrading ?? 0;
    final courses = dashboard?.totalCourses ?? 0;
    final published = dashboard?.publishedCourses ?? 0;
    final participants = dashboard?.totalParticipants ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppMeasures.paddingLarge),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderSubtle),
          boxShadow: AppShadows.sm,
        ),
        child: Row(
          children: [
            _pendingBadge(pending, loading),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                children: [
                  _StatRow(
                    icon: Icons.rate_review_rounded,
                    accent: AppColors.warning,
                    label: 'Perlu dinilai',
                    value: pending,
                  ),
                  const _StatDivider(),
                  _StatRow(
                    icon: Icons.menu_book_rounded,
                    accent: AppColors.brandPrimary,
                    label: 'Kelas terbit',
                    value: published,
                    total: courses,
                  ),
                  const _StatDivider(),
                  _StatRow(
                    icon: Icons.groups_rounded,
                    accent: AppColors.info,
                    label: 'Total peserta',
                    value: participants,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pendingBadge(int pending, bool loading) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.brandGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppShadows.brand(AppColors.brandPrimary, opacity: 0.16),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (loading)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: Colors.white,
                ),
              )
            else
              AnimatedCount(
                value: pending,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.0,
                ),
              ),
            const SizedBox(height: 2),
            const Text(
              'perlu\ndinilai',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 8.5,
                height: 1.1,
                fontWeight: FontWeight.w600,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final IconData icon;
  final Color accent;
  final String label;
  final int value;

  /// Opsional — bila diisi, ditampilkan sebagai `value/total`.
  final int? total;

  const _StatRow({
    required this.icon,
    required this.accent,
    required this.label,
    required this.value,
    this.total,
  });

  @override
  Widget build(BuildContext context) {
    final valueStyle = TextStyle(
      fontSize: 13.5,
      fontWeight: FontWeight.w800,
      color: AppColors.textPrimary,
    );
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: accent, size: 15),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
          ),
        ),
        AnimatedCount(value: value, style: valueStyle),
        if (total != null) Text('/$total', style: valueStyle),
      ],
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Divider(height: 1, thickness: 1, color: AppColors.borderSubtle),
    );
  }
}
