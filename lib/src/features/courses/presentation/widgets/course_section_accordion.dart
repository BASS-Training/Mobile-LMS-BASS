import 'package:flutter/material.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';
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
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.pearl),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: ExpansionTile(
          title: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.violet,
                ),
                child: Center(
                  child: Text(
                    '${section.sectionNumber}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
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
                        fontWeight: FontWeight.w600,
                        color: AppColors.charcoal,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      section.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.slate,
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
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progressPercent / 100,
                    minHeight: 4,
                    backgroundColor: AppColors.pearl,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.violet,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$completedCount/$totalCount lessons',
                  style: const TextStyle(fontSize: 11, color: AppColors.slate),
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
