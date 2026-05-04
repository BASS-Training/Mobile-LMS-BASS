import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms_mobile_app/config/theme.dart';
import 'package:lms_mobile_app/data/models/course.dart';
import 'package:lms_mobile_app/data/models/lesson.dart';
import 'package:lms_mobile_app/presentation/bloc/lesson/lesson_bloc.dart';
import 'package:lms_mobile_app/presentation/bloc/lesson/lesson_event.dart';
import 'package:lms_mobile_app/presentation/bloc/lesson/lesson_state.dart';
import 'package:lms_mobile_app/presentation/bloc/course/course_bloc.dart';
import 'package:lms_mobile_app/presentation/bloc/course/course_event.dart';

class LessonDetailScreen extends StatefulWidget {
  final Lesson lesson;
  final Course course;
  final int lessonIndex;

  const LessonDetailScreen({
    super.key,
    required this.lesson,
    required this.course,
    required this.lessonIndex,
  });

  @override
  State<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    context
        .read<LessonBloc>()
        .add(CheckLessonCompletionEvent(lessonId: widget.lesson.id));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  bool get canGoNext => widget.lessonIndex < widget.course.lessons.length - 1;
  bool get canGoPrevious => widget.lessonIndex > 0;

  Lesson? get nextLesson =>
      canGoNext ? widget.course.lessons[widget.lessonIndex + 1] : null;
  Lesson? get previousLesson =>
      canGoPrevious ? widget.course.lessons[widget.lessonIndex - 1] : null;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        context.read<CourseBloc>().add(const RefreshCoursesEvent());
        return false;
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(widget.course.title),
          elevation: 0,
          leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
              context.read<CourseBloc>().add(const RefreshCoursesEvent());
            },
            child: Icon(Icons.arrow_back),
          ),
        ),
        body: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(20),
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
                    SizedBox(height: 8),
                    Text(
                      'Lesson ${widget.lessonIndex + 1}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      widget.lesson.title,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.timer, color: Colors.white, size: 16),
                        SizedBox(width: 6),
                        Text(
                          widget.lesson.duration,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 13,
                          ),
                        ),
                        SizedBox(width: 16),
                        BlocBuilder<LessonBloc, LessonState>(
                          builder: (context, state) {
                            bool isCompleted = false;
                            if (state is LessonCompletionChecked) {
                              isCompleted = state.isCompleted;
                            } else if (state is LessonMarkedComplete) {
                              isCompleted = true;
                            } else if (state is LessonMarkedIncomplete) {
                              isCompleted = false;
                            }

                            if (isCompleted)
                              return Row(
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                    size: 16,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'Completed',
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              );
                            return SizedBox.shrink();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Content
              Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lesson Content',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.text,
                      ),
                    ),
                    SizedBox(height: 16),
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Text(
                        widget.lesson.content,
                        style: TextStyle(
                          fontSize: 15,
                          color: AppColors.textLight,
                          height: 1.8,
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                    // Mark complete button
                    BlocBuilder<LessonBloc, LessonState>(
                      builder: (context, state) {
                        bool isCompleted = false;
                        if (state is LessonCompletionChecked) {
                          isCompleted = state.isCompleted;
                        } else if (state is LessonMarkedComplete) {
                          isCompleted = true;
                        } else if (state is LessonMarkedIncomplete) {
                          isCompleted = false;
                        }

                        return SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              context.read<LessonBloc>().add(
                                    ToggleLessonCompletionEvent(
                                      lessonId: widget.lesson.id,
                                    ),
                                  );
                              context
                                  .read<CourseBloc>()
                                  .add(const RefreshCoursesEvent());
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    isCompleted
                                        ? 'Lesson marked as incomplete'
                                        : 'Lesson marked as complete! 🎉',
                                  ),
                                  duration: Duration(seconds: 2),
                                  backgroundColor: isCompleted
                                      ? Colors.orange
                                      : Colors.green,
                                ),
                              );
                            },
                            icon: Icon(
                              isCompleted
                                  ? Icons.close
                                  : Icons.check_circle,
                            ),
                            label: Text(
                              isCompleted
                                  ? 'Mark as Incomplete'
                                  : 'Mark as Complete',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isCompleted
                                  ? Colors.orange
                                  : Colors.green,
                              foregroundColor: Colors.white,
                              padding:
                                  EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 24),
                    // Navigation buttons
                    Row(
                      children: [
                        if (canGoPrevious)
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                Future.delayed(Duration(milliseconds: 200), () {
                                  Navigator.pushNamed(
                                    context,
                                    '/lesson-detail',
                                    arguments: {
                                      'lesson': previousLesson,
                                      'course': widget.course,
                                      'lessonIndex': widget.lessonIndex - 1,
                                    },
                                  );
                                });
                              },
                              icon: Icon(Icons.arrow_back),
                              label: Text('Previous'),
                            ),
                          ),
                        if (canGoPrevious && canGoNext) SizedBox(width: 12),
                        if (canGoNext)
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                Future.delayed(Duration(milliseconds: 200), () {
                                  Navigator.pushNamed(
                                    context,
                                    '/lesson-detail',
                                    arguments: {
                                      'lesson': nextLesson,
                                      'course': widget.course,
                                      'lessonIndex': widget.lessonIndex + 1,
                                    },
                                  );
                                });
                              },
                              icon: Icon(Icons.arrow_forward),
                              label: Text('Next'),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
