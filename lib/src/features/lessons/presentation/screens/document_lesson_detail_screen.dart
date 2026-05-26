import 'dart:async';
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
import 'package:lms_mobile_app/src/features/lessons/presentation/widgets/lesson_drawer.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';
import 'package:lms_mobile_app/src/shared/widgets/press_scale.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

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
  late final GlobalKey<ScaffoldState> _scaffoldKey;
  PdfViewerController? _pdfViewerController;
  double _zoomLevel = 1.0;

  @override
  void initState() {
    super.initState();
    _scaffoldKey = GlobalKey<ScaffoldState>();
    _pdfViewerController = PdfViewerController();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  void dispose() {
    _pdfViewerController?.dispose();
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

  String? get _documentUrl {
    final candidate = widget.lesson.documentUrl?.trim();
    if (candidate != null && candidate.isNotEmpty) {
      return candidate;
    }

    final content = widget.lesson.content.trim();
    if (content.isEmpty) {
      return null;
    }

    final uri = Uri.tryParse(content);
    if (uri != null && uri.hasScheme) {
      return content;
    }

    return null;
  }

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

  Future<void> _markComplete({bool goToNext = false}) async {
    if (!widget.lesson.isCompleted) {
      context.read<LessonBloc>().add(
        MarkLessonCompleteEvent(lessonId: widget.lesson.id),
      );
      context.read<CourseBloc>().add(const RefreshCoursesEvent());
    }

    await Future.delayed(const Duration(milliseconds: 120));
    if (!mounted) return;

    if (goToNext && nextLesson != null) {
      context.pop();
      Future.delayed(const Duration(milliseconds: 180), () {
        if (!mounted) return;
        _openLesson(nextLesson!, widget.lessonIndex + 1);
      });
      return;
    }

    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final documentUrl = _documentUrl;

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
      backgroundColor: const Color(0xFFF6F8FF),
      appBar: _buildCompactAppBar(),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: _buildNavigationCard(),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: _buildDocumentToolbar(documentUrl),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildDocumentCard(documentUrl),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildCompactAppBar() {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.course.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'DOCUMENT READER',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.red, AppColors.tomato],
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
        child: const Icon(Icons.arrow_back_rounded, color: Colors.white),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: GestureDetector(
            onTap: () => _scaffoldKey.currentState?.openDrawer(),
            child: const Icon(Icons.menu_rounded, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildBackgroundOrbs() {
    return Stack(
      children: [
        Positioned(
          top: -60,
          right: -40,
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.tomato.withValues(alpha: 0.16),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 120,
          left: -70,
          child: Container(
            width: 170,
            height: 170,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.red.withValues(alpha: 0.12),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentToolbar(String? documentUrl) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dokumen Lesson',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.charcoal.withValues(alpha: 0.92),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                documentUrl == null
                    ? 'PDF belum tersedia untuk lesson ini.'
                    : 'Layar baca dibuat lebar supaya PDF lebih nyaman di-scroll.',
                style: TextStyle(fontSize: 11.5, color: AppColors.slate),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF3F6FF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: PopupMenuButton<String>(
            icon: const Icon(Icons.zoom_in_rounded, color: AppColors.red),
            onSelected: (value) {
              switch (value) {
                case 'zoom_in':
                  setState(() {
                    _zoomLevel = (_zoomLevel + 0.25).clamp(1.0, 3.5);
                    _pdfViewerController?.zoomLevel = _zoomLevel;
                  });
                  break;
                case 'zoom_out':
                  setState(() {
                    _zoomLevel = (_zoomLevel - 0.25).clamp(1.0, 3.5);
                    _pdfViewerController?.zoomLevel = _zoomLevel;
                  });
                  break;
                case 'reset':
                  setState(() {
                    _zoomLevel = 1.0;
                    _pdfViewerController?.zoomLevel = _zoomLevel;
                  });
                  break;
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'zoom_in', child: Text('Zoom in')),
              PopupMenuItem(value: 'zoom_out', child: Text('Zoom out')),
              PopupMenuItem(value: 'reset', child: Text('Reset zoom')),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentCard(String? documentUrl) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.pearl.withValues(alpha: 0.9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Container(
          color: Colors.white,
          child: documentUrl == null
              ? _buildMissingDocumentState()
              : SfPdfViewer.network(
                  documentUrl,
                  controller: _pdfViewerController,
                  canShowScrollHead: false,
                  canShowPaginationDialog: false,
                  enableDoubleTapZooming: true,
                  scrollDirection: PdfScrollDirection.vertical,
                  pageLayoutMode: PdfPageLayoutMode.continuous,
                  interactionMode: PdfInteractionMode.pan,
                  onDocumentLoaded: (details) {
                    _pdfViewerController?.zoomLevel = _zoomLevel;
                  },
                ),
        ),
      ),
    );
  }

  Widget _buildNavigationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.white, Color(0xFFF8FAFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.pearl.withValues(alpha: 0.8)),
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
                  label: const Text('Sebelumnya'),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: AppColors.pearl.withValues(alpha: 0.9),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.charcoal,
                  ),
                ),
              ),
            ),
          if (canGoPrevious) const SizedBox(width: 10),
          Expanded(
            child: PressScale(
              child: ElevatedButton.icon(
                onPressed: () => _markComplete(goToNext: canGoNext),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.red,
                  shadowColor: AppColors.red.withValues(alpha: 0.45),
                  elevation: 8,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: Icon(
                  canGoNext ? Icons.arrow_forward_rounded : Icons.check_rounded,
                ),
                label: Text(canGoNext ? 'Lanjut' : 'Selesai'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMissingDocumentState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.picture_as_pdf_rounded,
              size: 56,
              color: AppColors.slate,
            ),
            const SizedBox(height: 12),
            Text(
              'File PDF belum tersedia',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Backend perlu mengirim URL PDF untuk lesson document ini.',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.slate),
            ),
          ],
        ),
      ),
    );
  }
}
