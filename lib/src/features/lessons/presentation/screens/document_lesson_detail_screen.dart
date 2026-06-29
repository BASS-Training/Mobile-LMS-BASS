import 'dart:async';
import 'package:lms_mobile_app/src/features/lessons/presentation/utils/lesson_actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
import 'package:lms_mobile_app/src/shared/widgets/lesson_navigation_bar.dart';
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

class _DocumentLessonDetailScreenState extends State<DocumentLessonDetailScreen>
    with LessonNavigationMixin {
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
    super.dispose();
  }

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

  @override
  CourseEntity get currentCourse => widget.course;

  @override
  int get currentLessonIndex => widget.lessonIndex;

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
      // pushReplacement (di navigateToLesson) sudah mengganti layar lesson ini,
      // jadi tidak perlu pop dulu. Stack tetap [course, lessonBerikutnya].
      navigateToLesson(nextLesson!, widget.lessonIndex + 1);
      return;
    }

    popToCourse(context);
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
          Navigator.pop(context); // tutup drawer
          navigateToLesson(selectedLesson, index);
        },
      ),
      backgroundColor: AppColors.background,
      appBar: LessonAppBar(
        courseTitle: widget.course.title,
        subtitle: 'DOCUMENT READER',
        action: DiscussionIconButton(
          lessonId: widget.lesson.id,
          lessonTitle: widget.lesson.title,
        ),
        onBack: () {
          popToCourse(context);
        },
        onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: LessonNavigationBar(
            canGoPrevious: canGoPrevious,
            canGoNext: canGoNext,
            onPrevious: canGoPrevious
                ? () =>
                      navigateToLesson(previousLesson!, widget.lessonIndex - 1)
                : null,
            onForward: () => _markComplete(goToNext: canGoNext),
          ),
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
                    : '',
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

  Widget _buildMissingDocumentState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
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
