import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lms_mobile_app/src/core/utils/lesson_route_resolver.dart';
import 'package:lms_mobile_app/src/features/courses/domain/entities/course_entity.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/bloc/course/course_bloc.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/bloc/course/course_event.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/entities/document_section_entity.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/entities/lesson_entity.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/bloc/lesson/lesson_bloc.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/bloc/lesson/lesson_event.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/bloc/lesson/lesson_state.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/widgets/lesson_drawer.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/widgets/document_lesson_header.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/widgets/document_lesson_meta_card.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/widgets/document_section_card.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';

class DocumentLessonDetailScreen extends StatefulWidget {
  final LessonEntity lesson;
  final CourseEntity course;
  final int lessonIndex;

  const DocumentLessonDetailScreen({
    super.key,
    required this.lesson,
    required this.course,
    required this.lessonIndex,
  });

  @override
  State<DocumentLessonDetailScreen> createState() =>
      _DocumentLessonDetailScreenState();
}

class _DocumentLessonDetailScreenState
    extends State<DocumentLessonDetailScreen> {
  late GlobalKey<ScaffoldState> _scaffoldKey;

  @override
  void initState() {
    super.initState();
    _scaffoldKey = GlobalKey<ScaffoldState>();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  bool get canGoNext =>
      widget.lessonIndex < widget.course.allLessons.length - 1;
  bool get canGoPrevious => widget.lessonIndex > 0;

  LessonEntity? get nextLesson =>
      canGoNext ? widget.course.allLessons[widget.lessonIndex + 1] : null;
  LessonEntity? get previousLesson =>
      canGoPrevious ? widget.course.allLessons[widget.lessonIndex - 1] : null;

  void _openLesson(LessonEntity lesson, int lessonIndex) {
    final route = LessonRouteResolver.routeForType(lesson.type);

    context.push(
      route,
      extra: {
        'lesson': lesson,
        'course': widget.course,
        'lessonIndex': lessonIndex,
      },
    );
  }

  // Mark-complete moved to LessonBloc when requesting navigation.

  @override
  Widget build(BuildContext context) {
    final lesson = widget.lesson;

    final List<DocumentSectionEntity> sections =
        DocumentSectionEntity.generateDummy(lesson.content);

    return BlocListener<LessonBloc, LessonState>(
      listener: (context, state) {
        if (state is LessonNavigationIntent) {
          final idx = state.lessonIndex;
          if (idx != null &&
              idx >= 0 &&
              idx < widget.course.allLessons.length) {
            final target = widget.course.allLessons[idx];
            final route = LessonRouteResolver.routeForType(target.type);
            // Push new lesson screen; do not pop first to avoid invalidating context
            context.push(
              route,
              extra: {
                'lesson': target,
                'course': widget.course,
                'lessonIndex': idx,
              },
            );
            // Refresh courses list to reflect completion change
            context.read<CourseBloc>().add(const RefreshCoursesEvent());
          }
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        drawer: LessonDrawer(
          course: widget.course,
          currentLessonIndex: widget.lessonIndex,
          onSelectLesson: (selectedLesson, index) {
            final route = LessonRouteResolver.routeForType(selectedLesson.type);
            context.push(
              route,
              extra: {
                'lesson': selectedLesson,
                'course': widget.course,
                'lessonIndex': index,
              },
            );
          },
        ),
        backgroundColor: AppColors.ghostWhite,
        appBar: AppBar(
          title: Text(widget.course.title),
          elevation: 0,
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.violet, AppColors.azure],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
              context.read<CourseBloc>().add(const RefreshCoursesEvent());
            },
            child: const Icon(Icons.arrow_back),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: GestureDetector(
                  onTap: () => _scaffoldKey.currentState?.openDrawer(),
                  child: const Icon(Icons.list_alt, size: 24),
                ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.ghostWhite, AppColors.aliceBlue],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DocumentLessonHeader(
                    lesson: lesson,
                    lessonIndex: widget.lessonIndex,
                  ),
                  const SizedBox(height: 16),
                  DocumentLessonMetaCard(lesson: lesson),
                  const SizedBox(height: 16),
                  ...sections.map((s) => DocumentSectionCard(section: s)),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      if (canGoPrevious)
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _handlePreviousLesson,
                            icon: const Icon(Icons.arrow_back),
                            label: const Text('Previous'),
                          ),
                        ),
                      if (canGoPrevious && canGoNext) const SizedBox(width: 12),
                      if (canGoNext)
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _handleNextLesson,
                            icon: const Icon(Icons.arrow_forward),
                            label: const Text('Next'),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleNextLesson() async {
    // Ask bloc to perform mark-complete and emit navigation intent
    context.read<LessonBloc>().add(
      RequestNavigateNextEvent(
        course: widget.course,
        currentIndex: widget.lessonIndex,
      ),
    );
  }

  void _handlePreviousLesson() {
    context.read<LessonBloc>().add(
      RequestNavigatePreviousEvent(
        course: widget.course,
        currentIndex: widget.lessonIndex,
      ),
    );
  }
}
