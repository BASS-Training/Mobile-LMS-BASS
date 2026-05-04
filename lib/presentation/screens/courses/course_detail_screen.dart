import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms_mobile_app/config/theme.dart';
import 'package:lms_mobile_app/data/models/course.dart';
import 'package:lms_mobile_app/domain/entities/course_entity.dart';
import 'package:lms_mobile_app/presentation/bloc/course/course_bloc.dart';
import 'package:lms_mobile_app/presentation/bloc/course/course_event.dart';
import 'package:lms_mobile_app/presentation/bloc/course/course_state.dart';
import 'package:lms_mobile_app/presentation/bloc/lesson/lesson_bloc.dart';
import 'package:lms_mobile_app/presentation/bloc/lesson/lesson_event.dart';
import 'package:lms_mobile_app/utils/constants.dart';
import 'package:lms_mobile_app/presentation/widgets/lesson_tile.dart';
import 'package:lms_mobile_app/presentation/widgets/progress_indicator.dart';
import 'package:lms_mobile_app/data/mappers/course_mapper.dart';

class CourseDetailScreen extends StatelessWidget {
  final Course course;

  const CourseDetailScreen({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CourseBloc, CourseState>(
      builder: (context, state) {
        CourseEntity currentCourseEntity = CourseMapper.toDomain(course);
        
        if (state is CourseLoaded) {
          final foundCourse = state.courses.firstWhere(
            (c) => c.id == course.id,
            orElse: () => CourseMapper.toDomain(course),
          );
          currentCourseEntity = foundCourse;
        }

        final currentCourse = CourseMapper.fromDomain(currentCourseEntity);

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with course preview
                Container(
                  height: 280,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(
                          int.parse(
                            currentCourse.color.replaceFirst('#', '0xFF'),
                          ),
                        ),
                        Color(
                          int.parse(
                            currentCourse.color.replaceFirst('#', '0xFF'),
                          ),
                        ).withOpacity(0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: SafeArea(
                    child: Stack(
                      children: [
                        // Back button
                        Positioned(
                          top: 16,
                          left: 16,
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child:
                                  Icon(Icons.arrow_back, color: Colors.white),
                            ),
                          ),
                        ),
                        // Save button
                        Positioned(
                          top: 16,
                          right: 16,
                          child: GestureDetector(
                            onTap: () {
                              context.read<CourseBloc>().add(
                                    ToggleSaveCourseEvent(
                                        courseId: currentCourse.id),
                                  );
                            },
                            child: Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                currentCourseEntity.isSaved
                                    ? Icons.bookmark
                                    : Icons.bookmark_outline,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                        // Course icon and title
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                currentCourse.icon,
                                style: TextStyle(fontSize: 80),
                              ),
                              SizedBox(height: 24),
                              Text(
                                currentCourse.title,
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
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
                ),
                // Course info cards
                Padding(
                  padding: EdgeInsets.all(AppConstants.paddingLarge),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Instructor and info row
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.person,
                                      color: AppColors.primary),
                                  SizedBox(height: 8),
                                  Text(
                                    'Instructor',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textLight,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    currentCourse.instructor,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.text,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.timer,
                                      color: AppColors.secondary),
                                  SizedBox(height: 8),
                                  Text(
                                    'Duration',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textLight,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    currentCourse.duration,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.text,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24),
                      // About Course
                      Text(
                        'About Course',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.text,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        currentCourse.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textLight,
                          height: 1.6,
                        ),
                      ),
                      SizedBox(height: 24),
                      // Progress
                      CourseProgressIndicator(
                        progress: currentCourseEntity.progressPercentage,
                        label: 'Your Progress',
                        showPercentage: true,
                      ),
                      SizedBox(height: 24),
                      // Lessons header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Lessons',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.text,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${currentCourseEntity.completedLessons}/${currentCourseEntity.totalLessons}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      // Lessons list
                      ...currentCourse.lessons.asMap().entries.map((entry) {
                        final index = entry.key;
                        final lesson = entry.value;
                        return LessonTile(
                          lesson: lesson,
                          index: index,
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/lesson-detail',
                              arguments: {
                                'lesson': lesson,
                                'course': currentCourse,
                                'lessonIndex': index,
                              },
                            );
                          },
                          onCompletionChanged: (isCompleted) {
                            context.read<LessonBloc>().add(
                                  ToggleLessonCompletionEvent(
                                      lessonId: lesson.id),
                                );
                            context
                                .read<CourseBloc>()
                                .add(const RefreshCoursesEvent());
                          },
                        );
                      }),
                      SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
