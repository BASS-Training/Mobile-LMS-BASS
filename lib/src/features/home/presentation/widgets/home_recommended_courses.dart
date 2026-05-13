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
        width: 200,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.pearl),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.menu_book_rounded, color: AppColors.violet, size: 28),
              Spacer(),
              Text(
                'Tampilkan Semua',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.charcoal,
                  height: 1.1,
                ),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    'Buka daftar Kursus',
                    style: TextStyle(fontSize: 12, color: AppColors.silver),
                  ),
                  Spacer(),
                  Icon(Icons.arrow_forward_rounded, color: AppColors.charcoal),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
