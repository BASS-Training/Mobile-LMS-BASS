import 'dart:ui';

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
import 'package:lms_mobile_app/src/features/lessons/presentation/widgets/lesson_drawer.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';
import 'package:lms_mobile_app/src/shared/widgets/press_scale.dart';

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

  void _markComplete() {
    context.read<LessonBloc>().add(
      MarkLessonCompleteEvent(lessonId: widget.lesson.id),
    );
    context.read<CourseBloc>().add(const RefreshCoursesEvent());
  }

  @override
  Widget build(BuildContext context) {
    final lesson = widget.lesson;

    final List<DocumentSectionEntity> sections = [
      DocumentSectionEntity(
        title: '',
        paragraphs: [lesson.content],
        bullets: const [],
      ),
    ];

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
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.course.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Document lesson detail',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.82),
              ),
            ),
          ],
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        toolbarHeight: 72,
        leadingWidth: 72,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.red, AppColors.red],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: _buildIconButton(
            icon: Icons.arrow_back_rounded,
            onTap: () {
              Navigator.pop(context);
              context.read<CourseBloc>().add(const RefreshCoursesEvent());
            },
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: _buildIconButton(
              icon: Icons.menu_rounded,
              onTap: () => _scaffoldKey.currentState?.openDrawer(),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            _buildBackgroundOrbs(),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFF9FBFF), Color(0xFFF2F6FF)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAnimatedEntry(index: 0, child: _buildHeader(lesson)),
                  const SizedBox(height: 16),
                  _buildAnimatedEntry(index: 1, child: _buildMetaCard(lesson)),
                  const SizedBox(height: 16),
                  ...sections.asMap().entries.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildAnimatedEntry(
                        index: entry.key + 2,
                        child: _buildSectionCard(entry.value, entry.key),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  _buildAnimatedEntry(
                    index: sections.length + 3,
                    child: _buildNavigationCard(),
                  ),
                ],
              ),
            ),
          ],
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
              const Expanded(
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
                  'DOCUMENT',
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
          Text(
            lesson.content.isNotEmpty
                ? lesson.content
                : 'Materi ini akan diisi dari backend. Untuk sementara, ini adalah teks dummy yang menjelaskan isi pembelajaran secara rapi dan terstruktur.',
            style: const TextStyle(
              fontSize: 14,
              height: 1.9,
              color: AppColors.slate,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(DocumentSectionEntity section, int index) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.94),
            const Color(0xFFFDFDFF).withValues(alpha: 0.96),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.pearl.withValues(alpha: 0.8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...section.paragraphs.map(
            (paragraph) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                paragraph,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.85,
                  color: AppColors.slate,
                ),
              ),
            ),
          ),
          if (section.bullets.isNotEmpty) ...[
            const SizedBox(height: 6),
            ...section.bullets.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 5),
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: AppColors.peach.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.check_rounded,
                          size: 12,
                          color: AppColors.red,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.75,
                          color: AppColors.slate,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNavigationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.pearl.withValues(alpha: 0.7)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          if (canGoPrevious)
            Expanded(
              child: PressScale(
                child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  Future.delayed(const Duration(milliseconds: 200), () {
                    _openLesson(previousLesson!, widget.lessonIndex - 1);
                  });
                },
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text('Previous'),
                ),
              ),
            ),
          if (canGoPrevious && canGoNext) const SizedBox(width: 12),
          if (canGoNext)
            Expanded(
              child: PressScale(
                child: ElevatedButton.icon(
                onPressed: () async {
                  _markComplete();
                  await Future.delayed(const Duration(milliseconds: 100));
                  if (!mounted) return;
                  Navigator.pop(context);
                  Future.delayed(const Duration(milliseconds: 200), () {
                    _openLesson(nextLesson!, widget.lessonIndex + 1);
                  });
                },
                icon: const Icon(Icons.arrow_forward_rounded),
                label: const Text('Next'),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return PressScale(
      child: Material(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
            ),
            child: Icon(icon, color: Colors.white),
          ),
        ),
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

  Widget _buildBackgroundOrbs() {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -70,
            right: -40,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.tomato.withValues(alpha: 0.18),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 150,
            left: -60,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.red.withValues(alpha: 0.14),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
