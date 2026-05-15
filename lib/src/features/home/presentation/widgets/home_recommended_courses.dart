import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lms_mobile_app/src/core/config/constants/app_routes.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/bloc/course/course_bloc.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/bloc/course/course_event.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/bloc/course/course_state.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/widgets/course_card.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';
import 'package:lms_mobile_app/src/shared/styles/app_measures.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Recommended Courses Section with Edge Swipe Navigation
class HomeRecommendedCourses extends StatefulWidget {
  final CourseState courseState;
  final VoidCallback onNavigateToCourseList;

  const HomeRecommendedCourses({
    super.key,
    required this.courseState,
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
    if (widget.courseState is! CourseLoaded) {
      return const SizedBox.shrink();
    }

    final courseState = widget.courseState as CourseLoaded;
    final recommendedCourses = courseState.courses.skip(3).take(3).toList();

    return SizedBox(
      height: 280,
      child: NotificationListener<ScrollNotification>(
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
          padding: EdgeInsets.symmetric(horizontal: AppMeasures.paddingLarge),
          itemCount: recommendedCourses.length + 1,
          itemBuilder: (context, index) {
            if (index == recommendedCourses.length) {
              return _buildViewAllCard(context);
            }

            final courseEntity = recommendedCourses[index];
            return Container(
              width: 200,
              margin: const EdgeInsets.only(right: 12),
              child: CourseCard(
                course: courseEntity,
                isSaved: courseEntity.isSaved,
                onTap: () {
                  context.push(AppRoutes.courseDetail, extra: courseEntity);
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

  Widget _buildViewAllCard(BuildContext context) {
    return GestureDetector(
      onTap: _handleEdgeSwipeNavigation,
      child: Container(
        width: 210,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withValues(alpha: 0.95),
              const Color(0xFFF6F8FF).withValues(alpha: 0.98),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.pearl.withValues(alpha: 0.75)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.menu_book_rounded, color: AppColors.cherry, size: 30),
              Spacer(),
              Text(
                'Tampilkan Semua',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.charcoal,
                  height: 1.05,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Buka daftar kursus dan jelajahi semua materi',
                style: TextStyle(
                  fontSize: 12,
                  height: 1.5,
                  color: AppColors.slate,
                ),
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    'Lihat katalog',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.cherry,
                    ),
                  ),
                  Spacer(),
                  Icon(Icons.arrow_forward_rounded, color: AppColors.cherry),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
