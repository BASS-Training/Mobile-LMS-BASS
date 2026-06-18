import 'dart:ui';
import 'package:lms_mobile_app/src/features/lessons/presentation/utils/lesson_actions.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lms_mobile_app/src/core/utils/lesson_route_resolver.dart';
import 'package:lms_mobile_app/src/features/courses/domain/entities/course_entity.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/bloc/course/course_bloc.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/bloc/course/course_event.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/entities/lesson_entity.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/bloc/lesson/lesson_bloc.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/bloc/lesson/lesson_event.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/utils/lesson_navigation_mixin.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/widgets/lesson_drawer.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';
import 'package:lms_mobile_app/src/shared/widgets/lesson_app_bar.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/widgets/discussion/discussion_button.dart';
import 'package:lms_mobile_app/src/shared/widgets/html_content.dart';
import 'package:lms_mobile_app/src/shared/widgets/lesson_background.dart';
import 'package:lms_mobile_app/src/shared/widgets/lesson_navigation_bar.dart';

class TextLessonDetailScreen extends StatefulWidget {
  final LessonEntity lesson;
  final CourseEntity course;
  final int lessonIndex;

  const TextLessonDetailScreen({
    super.key,
    required this.lesson,
    required this.course,
    required this.lessonIndex,
  });

  @override
  State<TextLessonDetailScreen> createState() => _TextLessonDetailScreenState();
}

class _TextLessonDetailScreenState extends State<TextLessonDetailScreen>
    with LessonNavigationMixin {
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
    super.dispose();
  }

  @override
  CourseEntity get currentCourse => widget.course;

  @override
  int get currentLessonIndex => widget.lessonIndex;

  void _markComplete() {
    context.read<LessonBloc>().add(
      MarkLessonCompleteEvent(lessonId: widget.lesson.id),
    );
    context.read<CourseBloc>().add(const RefreshCoursesEvent());
  }

  @override
  Widget build(BuildContext context) {
    final lesson = widget.lesson;

    return Scaffold(
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
      backgroundColor: Colors.transparent,
      appBar: LessonAppBar(
        courseTitle: widget.course.title,
        subtitle: 'TEXT LESSON',
        action: DiscussionIconButton(
          lessonId: widget.lesson.id,
          lessonTitle: widget.lesson.title,
        ),
        onBack: () {
          popToCourse(context);
        },
        onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      body: SafeArea(
        child: LessonBackground(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAnimatedEntry(index: 0, child: _buildHeader(lesson)),
                const SizedBox(height: 16),
                _buildAnimatedEntry(index: 1, child: _buildMetaCard(lesson)),
                const SizedBox(height: 20),
                _buildAnimatedEntry(
                  index: 2,
                  child: LessonNavigationBar(
                    canGoPrevious: canGoPrevious,
                    canGoNext: canGoNext,
                    onPrevious: canGoPrevious
                        ? () {
                            Navigator.pop(context);
                            Future.delayed(
                              const Duration(milliseconds: 200),
                              () => navigateToLesson(
                                previousLesson!,
                                widget.lessonIndex - 1,
                              ),
                            );
                          }
                        : null,
                    onForward: () async {
                      _markComplete();
                      await Future.delayed(const Duration(milliseconds: 100));
                      if (!context.mounted) return;
                      Navigator.pop(context);
                      if (canGoNext && nextLesson != null) {
                        Future.delayed(
                          const Duration(milliseconds: 200),
                          () => navigateToLesson(
                            nextLesson!,
                            widget.lessonIndex + 1,
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(LessonEntity lesson) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.red.withValues(alpha: 0.96),
                AppColors.red.withValues(alpha: 0.96),
                AppColors.tomato.withValues(alpha: 0.96),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
            boxShadow: [
              BoxShadow(
                color: AppColors.crimson.withValues(alpha: 0.24),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.18),
                      ),
                    ),
                    child: Text(
                      'LESSON ${widget.lessonIndex + 1}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.auto_awesome_rounded,
                          size: 14,
                          color: Colors.white,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'READING MODE',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                lesson.title,
                style: const TextStyle(
                  fontSize: 26,
                  height: 1.15,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  _buildHeaderStat(
                    icon: Icons.description_rounded,
                    label: lesson.duration,
                  ),
                  const SizedBox(width: 10),
                  _buildHeaderStat(
                    icon: Icons.menu_book_rounded,
                    label: '${widget.course.allLessons.length} lessons',
                  ),
                ],
              ),
              const SizedBox(height: 18),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value:
                      (widget.lessonIndex + 1) /
                      widget.course.allLessons.length,
                  minHeight: 8,
                  backgroundColor: Colors.white.withValues(alpha: 0.16),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetaCard(LessonEntity lesson) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.94),
            const Color(0xFFF8FAFF).withValues(alpha: 0.96),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.pearl.withValues(alpha: 0.65)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.red, AppColors.tomato],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.chrome_reader_mode_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Materi Pembelajaran',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.charcoal,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Ringkasan dan konteks utama lesson',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.slate,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.peach.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'TEXT',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppColors.cherry,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(height: 1, color: AppColors.pearl),
          const SizedBox(height: 8),
          lesson.content.trim().isNotEmpty
              ? HtmlContent(html: lesson.content)
              : Text(
                  'Materi untuk lesson ini belum tersedia.',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.9,
                    color: AppColors.slate,
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildHeaderStat({required IconData icon, required String label}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedEntry({required Widget child, required int index}) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 420 + (index * 70)),
      curve: Curves.easeOutCubic,
      child: child,
      builder: (context, value, child) {
        final eased = Curves.easeOut.transform(value);
        return Opacity(
          opacity: eased,
          child: Transform.translate(
            offset: Offset(0, 18 * (1 - eased)),
            child: child,
          ),
        );
      },
    );
  }
}
