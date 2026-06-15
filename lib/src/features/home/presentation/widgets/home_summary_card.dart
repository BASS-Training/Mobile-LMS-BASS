import 'package:flutter/material.dart';
import 'package:lms_mobile_app/src/features/home/domain/entities/home_stats.entity.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';
import 'package:lms_mobile_app/src/shared/styles/app_measures.dart';
import 'package:lms_mobile_app/src/shared/styles/app_shadows.dart';
import 'package:lms_mobile_app/src/shared/widgets/animated_count.dart';
import 'package:lms_mobile_app/src/shared/widgets/progress_ring.dart';

/// Compact learning-summary card: an overall-progress ring paired with the key
/// metrics. Replaces the old 2×2 grid of mostly-empty stat cards with a single,
/// information-dense panel.
class HomeSummaryCard extends StatelessWidget {
  final HomeStatsEntity stats;

  const HomeSummaryCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
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
            ProgressRing(
              percent: stats.overallProgressPercentage / 100.0,
              size: 72,
              strokeWidth: 7,
              center: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedCount(
                    value: stats.overallProgressPercentage,
                    formatter: (v) => '$v%',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      height: 1.0,
                    ),
                  ),
                  const Text(
                    'progres',
                    style: TextStyle(
                      fontSize: 9,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                children: [
                  _MetricRow(
                    icon: Icons.menu_book_rounded,
                    accent: AppColors.brandPrimary,
                    label: 'Kursus selesai',
                    current: stats.completedCourses,
                    total: stats.totalCourses,
                  ),
                  const _MetricDivider(),
                  _MetricRow(
                    icon: Icons.task_alt_rounded,
                    accent: AppColors.success,
                    label: 'Lesson selesai',
                    current: stats.completedLessons,
                    total: stats.totalLessons,
                  ),
                  const _MetricDivider(),
                  _MetricRow(
                    icon: Icons.quiz_rounded,
                    accent: AppColors.info,
                    label: 'Kuis selesai',
                    current: stats.completedQuizzes,
                    total: stats.totalQuizzes,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  final IconData icon;
  final Color accent;
  final String label;
  final int current;
  final int total;

  const _MetricRow({
    required this.icon,
    required this.accent,
    required this.label,
    required this.current,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    const valueStyle = TextStyle(
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
            style: const TextStyle(
              fontSize: 12.5,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        // Animated numerator counting up; denominator stays fixed.
        AnimatedCount(value: current, style: valueStyle),
        Text('/$total', style: valueStyle),
      ],
    );
  }
}

class _MetricDivider extends StatelessWidget {
  const _MetricDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Divider(height: 1, thickness: 1, color: AppColors.borderSubtle),
    );
  }
}
