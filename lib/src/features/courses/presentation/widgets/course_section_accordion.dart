import 'package:flutter/material.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';
import 'package:lms_mobile_app/src/shared/styles/app_shadows.dart';
import '../../domain/entities/course_entity.dart';
import '../../domain/entities/course_section_entity.dart';
import 'course_lesson_tile.dart';

class CourseSectionAccordion extends StatelessWidget {
  final CourseSectionEntity section;
  final CourseEntity course;

  const CourseSectionAccordion({
    super.key,
    required this.section,
    required this.course,
  });

  @override
  Widget build(BuildContext context) {
    final sectionLessons = section.lessons;
    int completedCount = sectionLessons
        .where((lesson) => lesson.isCompleted)
        .length;
    final totalCount = sectionLessons.length;
    final progressPercent = totalCount > 0
        ? (completedCount / totalCount) * 100
        : 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle),
        boxShadow: AppShadows.xs,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: ExpansionTile(
          shape: const Border(),
          collapsedShape: const Border(),
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          title: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: AppColors.brandPrimary.withValues(alpha: 0.12),
                ),
                child: Center(
                  child: Text(
                    '${section.sectionNumber}',
                    style: const TextStyle(
                      color: AppColors.brandPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      section.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      section.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: progressPercent / 100,
                    minHeight: 5,
                    backgroundColor: AppColors.surfaceMuted,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.brandPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '$completedCount/$totalCount lesson selesai',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          initiallyExpanded: true,
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: sectionLessons.asMap().entries.map((entry) {
                  return CourseLessonTile(
                    lesson: entry.value,
                    course: course,
                    lessonIndexInSection: entry.key,
                    overallLessonIndex: course.allLessons.indexOf(entry.value),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
