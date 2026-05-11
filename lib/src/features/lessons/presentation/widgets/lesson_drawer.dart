import 'package:flutter/material.dart';
import 'package:lms_mobile_app/src/features/courses/domain/entities/course_entity.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/entities/lesson_entity.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';

class LessonDrawer extends StatelessWidget {
  final CourseEntity course;
  final int currentLessonIndex;
  final void Function(LessonEntity lesson, int index) onSelectLesson;

  const LessonDrawer({
    super.key,
    required this.course,
    required this.currentLessonIndex,
    required this.onSelectLesson,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: AppColors.background,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    'Lessons',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${course.allLessons.length} lessons',
                    style: TextStyle(fontSize: 13, color: Colors.white),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: course.allLessons.length,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemBuilder: (context, index) {
                  final lesson = course.allLessons[index];
                  final isCurrent = index == currentLessonIndex;

                  return Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isCurrent ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isCurrent ? AppColors.primary : AppColors.border,
                        width: isCurrent ? 2 : 1,
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: isCurrent
                            ? null
                            : (_isLessonUnlocked(lesson, course)
                                  ? () {
                                      Navigator.pop(context);
                                      Future.delayed(
                                        const Duration(milliseconds: 200),
                                        () {
                                          onSelectLesson(lesson, index);
                                        },
                                      );
                                    }
                                  : null),
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isCurrent
                                      ? AppColors.primary
                                      : _isLessonUnlocked(lesson, course)
                                      ? AppColors.border
                                      : Colors.grey.withOpacity(0.3),
                                ),
                                child: Center(
                                  child: lesson.isCompleted
                                      ? const Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 18,
                                        )
                                      : _isLessonUnlocked(lesson, course)
                                      ? Text(
                                          '${index + 1}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: isCurrent
                                                ? Colors.white
                                                : AppColors.text,
                                            fontSize: 14,
                                          ),
                                        )
                                      : const Icon(
                                          Icons.lock,
                                          color: Colors.grey,
                                          size: 16,
                                        ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      lesson.title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: isCurrent
                                            ? AppColors.primary
                                            : _isLessonUnlocked(lesson, course)
                                            ? AppColors.text
                                            : Colors.grey,
                                        decoration: lesson.isCompleted
                                            ? TextDecoration.lineThrough
                                            : null,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      lesson.duration,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: _isLessonUnlocked(lesson, course)
                                            ? AppColors.textLight
                                            : Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isCurrent)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'Now',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isLessonUnlocked(LessonEntity lesson, CourseEntity course) {
    final lessonIndex = course.allLessons.indexOf(lesson);

    // Lesson pertama selalu bisa dibuka
    if (lessonIndex == 0) return true;

    // Cek apakah lesson sebelumnya sudah selesai
    final previousLesson = course.allLessons[lessonIndex - 1];
    return previousLesson.isCompleted;
  }
}
