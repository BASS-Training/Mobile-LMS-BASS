import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lms_mobile_app/src/core/utils/lesson_route_resolver.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/entities/lesson_entity.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';
import '../../domain/entities/course_entity.dart';

class CourseLessonTile extends StatelessWidget {
  final LessonEntity lesson;
  final CourseEntity course;
  final int lessonIndexInSection;
  final int overallLessonIndex;

  const CourseLessonTile({
    super.key,
    required this.lesson,
    required this.course,
    required this.lessonIndexInSection,
    required this.overallLessonIndex,
  });

  Color _getLessonTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'video':
        return Colors.blue;
      case 'quiz':
        return Colors.orange;
      case 'essay':
        return Colors.purple;
      case 'text':
        return Colors.green;
      case 'image':
        return Colors.teal;
      case 'zoom':
        return Colors.indigo;
      default:
        return AppColors.violet;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isUnlocked = course.isLessonUnlocked(lesson);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.mist,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.pearl),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isUnlocked
              ? () {
                  final safeLessonIndex = overallLessonIndex >= 0
                      ? overallLessonIndex
                      : lessonIndexInSection;
                  final routeName = LessonRouteResolver.routeForType(
                    lesson.type,
                  );
                  context.push(
                    routeName,
                    extra: {
                      'lesson': lesson,
                      'course': course,
                      'lessonIndex': safeLessonIndex,
                    },
                  );
                }
              : null,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                // Indikator Angka/Centang
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: lesson.isCompleted
                        ? AppColors.mediumSeaGreen
                        : isUnlocked
                        ? AppColors.pearl
                        : Colors.grey,
                  ),
                  child: Center(
                    child: lesson.isCompleted
                        ? const Icon(Icons.check, color: Colors.white, size: 14)
                        : Text(
                            '${lessonIndexInSection + 1}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.charcoal,
                              fontSize: 12,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 10),
                // Judul dan Detail
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        lesson.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isUnlocked
                              ? (lesson.isCompleted
                                    ? AppColors.slate
                                    : AppColors.charcoal)
                              : Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.timer,
                            size: 12,
                            color: isUnlocked ? AppColors.slate : Colors.grey,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            lesson.duration,
                            style: TextStyle(
                              fontSize: 11,
                              color: isUnlocked ? AppColors.slate : Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Badge Tipe
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: isUnlocked
                                  ? _getLessonTypeColor(lesson.type)
                                  : Colors.grey,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              lesson.type.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 9,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
