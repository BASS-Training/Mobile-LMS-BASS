import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';
import '../../domain/entities/course_entity.dart';
import '../bloc/course/course_bloc.dart';
import '../bloc/course/course_event.dart';

class CourseDetailHeader extends StatelessWidget {
  final CourseEntity course;

  const CourseDetailHeader({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final primaryColor = AppColors.red;
    final secondaryColor = AppColors.tomato;
    final accentColor = AppColors.red;

    return Container(
      height: 280,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [secondaryColor, primaryColor,  accentColor, secondaryColor,],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Stack(
          children: [
            // Back Button
            Positioned(
              top: 16,
              left: 16,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back, color: Colors.white),
                ),
              ),
            ),
            // Save/Bookmark Button
            Positioned(
              top: 16,
              right: 16,
              child: GestureDetector(
                onTap: () {
                  context.read<CourseBloc>().add(
                    ToggleSaveCourseEvent(courseId: course.id),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    course.isSaved ? Icons.bookmark : Icons.bookmark_outline,
                    color: AppColors.cherry,
                  ),
                ),
              ),
            ),
            // Icon & Title
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.14),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        course.icon,
                        style: const TextStyle(fontSize: 52),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    course.title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
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
