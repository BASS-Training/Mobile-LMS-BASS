import 'package:flutter/material.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';
import 'package:lms_mobile_app/src/shared/styles/app_shadows.dart';
import '../../domain/entities/course_entity.dart';

/// Quick-facts row shown under the course hero: instructor and lesson count.
/// (Duration already lives in the header, so it isn't repeated here.)
class CourseInfoCards extends StatelessWidget {
  final CourseEntity course;

  const CourseInfoCards({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _InfoCard(
          icon: Icons.person_rounded,
          accent: AppColors.brandPrimary,
          label: 'Instruktur',
          value: course.instructor,
        ),
        const SizedBox(width: 12),
        _InfoCard(
          icon: Icons.menu_book_rounded,
          accent: AppColors.info,
          label: 'Total Lesson',
          value: '${course.totalLessons} lesson',
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final Color accent;
  final String label;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.accent,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderSubtle),
          boxShadow: AppShadows.xs,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: accent, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
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
