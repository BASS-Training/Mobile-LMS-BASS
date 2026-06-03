import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lms_mobile_app/src/core/config/constants/app_routes.dart';
import 'package:lms_mobile_app/src/core/utils/local_storage.dart';
import 'dart:math';
import 'package:lms_mobile_app/src/features/courses/domain/entities/course_entity.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/bloc/course/course_bloc.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/bloc/course/course_event.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/widgets/course_card.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';
import 'package:lms_mobile_app/src/shared/styles/app_measures.dart';
import 'package:lms_mobile_app/src/shared/styles/app_shadows.dart';

/// Horizontal rail of the learner's courses, with edge-swipe-to-see-all.
class HomeRecommendedCourses extends StatefulWidget {
  final List<CourseEntity> courses;
  final VoidCallback onNavigateToCourseList;

  const HomeRecommendedCourses({
    super.key,
    required this.courses,
    required this.onNavigateToCourseList,
  });

  @override
  State<HomeRecommendedCourses> createState() => _HomeRecommendedCoursesState();
}

class _HomeRecommendedCoursesState extends State<HomeRecommendedCourses> {
  bool _didNavigateFromEdgeSwipe = false;
  double _edgeOverscrollAccumulator = 0.0;
  static const double _edgeSwipeThreshold = 80.0;

  void _resetNavigationState() {
    _didNavigateFromEdgeSwipe = false;
    _edgeOverscrollAccumulator = 0;
  }

  void _handleEdgeSwipeNavigation() {
    if (!mounted || _didNavigateFromEdgeSwipe) return;

    _didNavigateFromEdgeSwipe = true;
    widget.onNavigateToCourseList();

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _resetNavigationState();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final recentCourseIds = LocalStorage.getRecentCourses();
    final recentCourses = recentCourseIds
        .map((courseId) {
          try {
            return widget.courses.firstWhere(
              (course) => course.id == courseId,
            );
          } catch (_) {
            return null;
          }
        })
        .whereType<CourseEntity>()
        .toList();
    final visibleRecentCourses = _buildVisibleCourses(
      widget.courses,
      recentCourses,
    );

    return SizedBox(
      height: 250,
      child: visibleRecentCourses.isEmpty
          ? _buildTokenPrompt()
          : NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (_didNavigateFromEdgeSwipe) return false;
                if (notification.metrics.axis != Axis.horizontal) return false;

                if (notification is OverscrollNotification) {
                  final atRightEdge =
                      notification.metrics.pixels >=
                      notification.metrics.maxScrollExtent;
                  final pushingBeyondRight = notification.overscroll > 0;

                  if (atRightEdge && pushingBeyondRight) {
                    _edgeOverscrollAccumulator += notification.overscroll;

                    if (_edgeOverscrollAccumulator >= _edgeSwipeThreshold) {
                      _handleEdgeSwipeNavigation();
                      return true;
                    }
                  } else {
                    _edgeOverscrollAccumulator = 0;
                  }
                }

                if (notification is ScrollEndNotification) {
                  _edgeOverscrollAccumulator = 0;
                }

                return false;
              },
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: AppMeasures.paddingLarge,
                ),
                itemCount: visibleRecentCourses.length,
                itemBuilder: (context, index) {
                  final courseEntity = visibleRecentCourses[index];
                  return Container(
                    width: 200,
                    margin: const EdgeInsets.only(right: 12),
                    child: CourseCard(
                      course: courseEntity,
                      isSaved: courseEntity.isSaved,
                      onTap: () {
                        context.push(
                          AppRoutes.courseDetail,
                          extra: courseEntity,
                        );
                      },
                      onSavePressed: () {
                        context.read<CourseBloc>().add(
                          ToggleSaveCourseEvent(courseId: courseEntity.id),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
    );
  }

  List<CourseEntity> _buildVisibleCourses(
    List<CourseEntity> allCourses,
    List<CourseEntity> recentCourses,
  ) {
    if (allCourses.isEmpty) {
      return <CourseEntity>[];
    }

    final visibleCourses = <CourseEntity>[];
    final addedIds = <String>{};

    for (final course in recentCourses) {
      if (visibleCourses.length == 3) break;
      if (addedIds.add(course.id)) {
        visibleCourses.add(course);
      }
    }

    if (visibleCourses.length < 3) {
      final remainingCourses = allCourses
          .where((course) => !addedIds.contains(course.id))
          .toList();
      remainingCourses.shuffle(Random());

      for (final course in remainingCourses) {
        if (visibleCourses.length == 3) break;
        visibleCourses.add(course);
      }
    }

    return visibleCourses.take(3).toList();
  }

  Widget _buildTokenPrompt() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppMeasures.paddingLarge),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.brandSurfaceAlt,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderSubtle),
        boxShadow: AppShadows.xs,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.brandPrimary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.vpn_key_rounded,
              color: AppColors.brandPrimary,
              size: 26,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Masukkan token untuk mendapatkan course',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

}
