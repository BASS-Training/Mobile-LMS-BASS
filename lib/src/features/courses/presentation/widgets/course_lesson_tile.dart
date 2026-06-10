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
        return const Color(0xFF2D7FF9);
      case 'quiz':
        return const Color(0xFFE8890C);
      case 'essay':
        return const Color(0xFF8B5CF6);
      case 'text':
        return const Color(0xFF16A34A);
      case 'image':
        return const Color(0xFF0D9488);
      case 'zoom':
        return const Color(0xFF4F46E5);
      case 'case_study':
        return const Color(0xFFD97706);
      default:
        return AppColors.violet;
    }
  }

  IconData _getLessonTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'video':
        return Icons.play_circle_fill_rounded;
      case 'quiz':
        return Icons.quiz_rounded;
      case 'essay':
        return Icons.edit_note_rounded;
      case 'text':
        return Icons.article_rounded;
      case 'image':
        return Icons.image_rounded;
      case 'zoom':
        return Icons.videocam_rounded;
      case 'case_study':
        return Icons.assignment_rounded;
      default:
        return Icons.menu_book_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isUnlocked = course.isLessonUnlocked(lesson);
    final bool isCompleted = lesson.isCompleted;
    final Color typeColor = isUnlocked
        ? _getLessonTypeColor(lesson.type)
        : Colors.grey;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isCompleted ? const Color(0xFFF4FBF6) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isCompleted
              ? AppColors.emerald.withValues(alpha: 0.45)
              : AppColors.borderDefault,
        ),
        boxShadow: isUnlocked
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
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
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            child: Row(
              children: [
                _buildLeading(isUnlocked: isUnlocked, isCompleted: isCompleted),
                const SizedBox(width: 12),
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
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: !isUnlocked
                              ? Colors.grey
                              : (isCompleted
                                    ? AppColors.slate
                                    : AppColors.charcoal),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          // Badge tipe lesson (ikon + label, soft tint)
                          _buildTypeBadge(typeColor),
                          if (isCompleted) ...[
                            const SizedBox(width: 6),
                            _buildStatusPill(
                              icon: Icons.check_circle_rounded,
                              label: 'Selesai',
                              color: AppColors.emerald,
                            ),
                          ] else if (!isUnlocked) ...[
                            const SizedBox(width: 6),
                            _buildStatusPill(
                              icon: Icons.lock_rounded,
                              label: 'Terkunci',
                              color: Colors.grey,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Afordans: panah saat bisa dibuka, gembok saat terkunci
                Icon(
                  isUnlocked
                      ? Icons.chevron_right_rounded
                      : Icons.lock_outline_rounded,
                  size: isUnlocked ? 22 : 18,
                  color: isUnlocked
                      ? AppColors.slate.withValues(alpha: 0.7)
                      : Colors.grey,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Lingkaran nomor urut. Saat selesai, nomor tetap tampil (putih di lingkaran
  /// hijau) dengan badge centang kecil di pojok agar keduanya terlihat.
  Widget _buildLeading({required bool isUnlocked, required bool isCompleted}) {
    final Color circleColor = isCompleted
        ? AppColors.emerald
        : isUnlocked
        ? AppColors.brandPrimary.withValues(alpha: 0.10)
        : const Color(0xFFEDEDED);

    final Color numberColor = isCompleted
        ? Colors.white
        : isUnlocked
        ? AppColors.brandPrimary
        : Colors.grey;

    return SizedBox(
      width: 40,
      height: 40,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: circleColor,
            ),
            child: Center(
              child: Text(
                '${lessonIndexInSection + 1}',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: numberColor,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          if (isCompleted)
            Positioned(
              right: -2,
              bottom: -2,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  size: 16,
                  color: AppColors.emerald,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTypeBadge(Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getLessonTypeIcon(lesson.type), size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            lesson.type.toUpperCase(),
            style: TextStyle(
              fontSize: 9.5,
              color: color,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusPill({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 9.5,
              color: color,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
