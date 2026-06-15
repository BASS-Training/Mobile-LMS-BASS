import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lms_mobile_app/src/core/config/constants/app_routes.dart';
import 'package:lms_mobile_app/src/features/courses/domain/entities/course_entity.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';
import 'package:lms_mobile_app/src/shared/styles/app_measures.dart';
import 'package:lms_mobile_app/src/shared/styles/app_shadows.dart';
import 'package:lms_mobile_app/src/shared/widgets/press_scale.dart';
import 'package:lms_mobile_app/src/shared/widgets/progress_ring.dart';

/// The signature LMS "continue learning" hero. Surfaces the course the learner
/// is most likely to resume (the in-progress course closest to completion,
/// falling back to the first available course) inside a vibrant brand card.
class HomeContinueLearning extends StatelessWidget {
  final List<CourseEntity> courses;

  const HomeContinueLearning({super.key, required this.courses});

  CourseEntity? get _continueCourse {
    if (courses.isEmpty) return null;
    final inProgress =
        courses
            .where((c) => c.progressPercentage > 0 && c.progressPercentage < 100)
            .toList()
          ..sort(
            (a, b) => b.progressPercentage.compareTo(a.progressPercentage),
          );
    if (inProgress.isNotEmpty) return inProgress.first;
    // No started course yet — nudge the learner toward the first one.
    return courses.first;
  }

  @override
  Widget build(BuildContext context) {
    final course = _continueCourse;
    if (course == null) return const SizedBox.shrink();

    final percent = course.progressPercentage / 100.0;
    final started = course.progressPercentage > 0;
    final lessonsLeft = course.totalLessons - course.completedLessons;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppMeasures.paddingLarge),
      child: PressScale(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => context.push(AppRoutes.courseDetail, extra: course),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              // Softer, airier red sweep (bright coral → brand) instead of the
              // heavy near-maroon, so the hero feels lighter on the eyes during
              // long sessions while still reading as the signature brand card.
              gradient: const LinearGradient(
                colors: [Color(0xFFFF5147), Color(0xFFE7140C), Color(0xFFC10000)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: AppShadows.brand(AppColors.brandPrimary, opacity: 0.18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _overline(started ? 'LANJUTKAN BELAJAR' : 'MULAI BELAJAR'),
                    const Spacer(),
                    if (started && lessonsLeft > 0) _lessonsLeftBadge(lessonsLeft),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _emojiBadge(course.icon),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            course.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.person_rounded,
                                size: 13,
                                color: Colors.white70,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  course.instructor,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    color: Colors.white70,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    ProgressRing(
                      percent: percent,
                      size: 58,
                      strokeWidth: 6,
                      color: Colors.white,
                      trackColor: Colors.white.withValues(alpha: 0.28),
                      center: Text(
                        '${course.progressPercentage.toInt()}%',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _continueButton(started),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _overline(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 10.5,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.2,
        color: Colors.white.withValues(alpha: 0.85),
      ),
    );
  }

  Widget _lessonsLeftBadge(int lessonsLeft) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$lessonsLeft lesson tersisa',
        style: const TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _emojiBadge(String icon) {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
      ),
      child: Center(child: Text(icon, style: const TextStyle(fontSize: 30))),
    );
  }

  Widget _continueButton(bool started) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.play_arrow_rounded,
            color: AppColors.brandPrimary,
            size: 20,
          ),
          const SizedBox(width: 6),
          Text(
            started ? 'Lanjutkan' : 'Mulai Sekarang',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.brandPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
