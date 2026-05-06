import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms_mobile_app/config/theme.dart';
import 'package:lms_mobile_app/domain/entities/course_entity.dart';
import 'package:lms_mobile_app/domain/entities/course_section_entity.dart';
import 'package:lms_mobile_app/domain/entities/lesson_entity.dart';
import 'package:lms_mobile_app/presentation/bloc/course/course_bloc.dart';
import 'package:lms_mobile_app/presentation/bloc/course/course_event.dart';
import 'package:lms_mobile_app/presentation/bloc/course/course_state.dart';
import 'package:lms_mobile_app/presentation/bloc/lesson/lesson_bloc.dart';
import 'package:lms_mobile_app/presentation/bloc/lesson/lesson_event.dart';
import 'package:lms_mobile_app/utils/constants.dart';
import 'package:lms_mobile_app/presentation/widgets/progress_indicator.dart';

class CourseDetailScreen extends StatelessWidget {
  final CourseEntity course;

  const CourseDetailScreen({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CourseBloc, CourseState>(
      builder: (context, state) {
        CourseEntity currentCourseEntity = course;

        if (state is CourseLoaded) {
          final foundCourse = state.courses.firstWhere(
            (c) => c.id == course.id,
            orElse: () => course,
          );
          currentCourseEntity = foundCourse;
        }

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
                            currentCourseEntity.color.replaceFirst('#', '0xFF'),
                          ),
                        ),
                        Color(
                          int.parse(
                            currentCourseEntity.color.replaceFirst('#', '0xFF'),
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
                              child: Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                              ),
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
                                  courseId: currentCourseEntity.id,
                                ),
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
                                currentCourseEntity.icon,
                                style: TextStyle(fontSize: 80),
                              ),
                              SizedBox(height: 24),
                              Text(
                                currentCourseEntity.title,
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
                                  Icon(Icons.person, color: AppColors.primary),
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
                                    currentCourseEntity.instructor,
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
                                  Icon(Icons.timer, color: AppColors.secondary),
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
                                    currentCourseEntity.duration,
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
                        currentCourseEntity.description,
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
                      // Sections header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Sections',
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
                      // Sections list
                      ...currentCourseEntity.sections.map((section) {
                        return _buildSectionWidget(
                          context,
                          section,
                          currentCourseEntity,
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

  Widget _buildSectionWidget(
    BuildContext context,
    CourseSectionEntity section,
    CourseEntity course,
  ) {
    final List<LessonEntity> sectionLessons = section.lessons;
    var completedCount = 0;
    for (final lesson in sectionLessons) {
      if (lesson.isCompleted) {
        completedCount++;
      }
    }
    final totalCount = sectionLessons.length;
    final progressPercent = totalCount > 0
        ? (completedCount / totalCount) * 100
        : 0;

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: ExpansionTile(
          title: Row(
            children: [
              // Section number
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                ),
                child: Center(
                  child: Text(
                    '${section.sectionNumber}',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12),
              // Section info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      section.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      section.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          subtitle: Padding(
            padding: EdgeInsets.only(top: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progressPercent / 100,
                    minHeight: 4,
                    backgroundColor: AppColors.border,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '$completedCount/$totalCount lessons',
                  style: TextStyle(fontSize: 11, color: AppColors.textLight),
                ),
              ],
            ),
          ),
          initiallyExpanded: true,
          children: [
            Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                children: sectionLessons.asMap().entries.map((entry) {
                  final lessonIndexInSection = entry.key;
                  final lesson = entry.value;
                  final overallLessonIndex = course.allLessons.indexOf(lesson);

                  return Container(
                    margin: EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/lesson-detail',
                            arguments: {
                              'lesson': lesson,
                              'course': course,
                              'lessonIndex': overallLessonIndex,
                            },
                          );
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          child: Row(
                            children: [
                              // Lesson completion indicator
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: lesson.isCompleted
                                      ? AppColors.primary
                                      : AppColors.border,
                                ),
                                child: Center(
                                  child: lesson.isCompleted
                                      ? Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 14,
                                        )
                                      : Text(
                                          '${lessonIndexInSection + 1}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.text,
                                            fontSize: 12,
                                          ),
                                        ),
                                ),
                              ),
                              SizedBox(width: 10),
                              // Lesson info
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
                                        color: lesson.isCompleted
                                            ? AppColors.textLight
                                            : AppColors.text,
                                        decoration: lesson.isCompleted
                                            ? TextDecoration.lineThrough
                                            : null,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.timer,
                                          size: 12,
                                          color: AppColors.textLight,
                                        ),
                                        SizedBox(width: 3),
                                        Text(
                                          lesson.duration,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: AppColors.textLight,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        // Lesson type badge
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _getLessonTypeColor(
                                              lesson.type,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          child: Text(
                                            lesson.type.toUpperCase(),
                                            style: TextStyle(
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
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getLessonTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'video':
        return Colors.blue;
      case 'quiz':
        return Colors.orange;
      case 'document':
        return Colors.green;
      default:
        return AppColors.primary;
    }
  }
}
