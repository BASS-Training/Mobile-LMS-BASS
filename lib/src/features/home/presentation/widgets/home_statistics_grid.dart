import 'package:flutter/material.dart';
import 'package:lms_mobile_app/src/features/home/domain/entities/home_stats.entity.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';
import 'package:lms_mobile_app/src/shared/styles/app_measures.dart';
import 'package:lms_mobile_app/src/shared/widgets/statistics_card.dart';

/// Dashboard metrics grid. Renders a uniform 2×2 set of [StatisticsCard]s so
/// every tile shares the same modern visual treatment.
class HomeStatisticsGrid extends StatelessWidget {
  final HomeStatsEntity stats;
  final VoidCallback? onOpenUserGuide;

  const HomeStatisticsGrid({
    super.key,
    required this.stats,
    this.onOpenUserGuide,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppMeasures.paddingLarge),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        childAspectRatio: 0.92,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        children: [
          StatisticsCard(
            icon: Icons.menu_book_rounded,
            value: stats.totalCourses.toString(),
            title: 'Kursus',
            description:
                '${stats.completedCourses} selesai · ${stats.incompleteCourses} berjalan',
            accent: AppColors.brandPrimary,
          ),
          StatisticsCard(
            icon: Icons.trending_up_rounded,
            value: '${stats.overallProgressPercentage}%',
            title: 'Progress',
            description: 'Keseluruhan lesson selesai',
            accent: AppColors.warning,
            progress: stats.overallProgressPercentage / 100.0,
          ),
          StatisticsCard(
            icon: Icons.task_alt_rounded,
            value: stats.completedLessons.toString(),
            title: 'Konten Selesai',
            description: 'dari ${stats.totalLessons} total lesson',
            accent: AppColors.success,
          ),
          StatisticsCard(
            icon: Icons.lightbulb_rounded,
            value: 'Panduan',
            title: 'User Guide',
            description: 'Cara memakai aplikasi LMS',
            accent: AppColors.info,
            onTap: onOpenUserGuide,
          ),
        ],
      ),
    );
  }
}
