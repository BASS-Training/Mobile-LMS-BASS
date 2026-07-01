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
import 'package:lms_mobile_app/src/features/lessons/presentation/widgets/attendance/attendance_status_banner.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';
import 'package:lms_mobile_app/src/shared/widgets/lesson_app_bar.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/widgets/discussion/discussion_button.dart';
import 'package:lms_mobile_app/src/shared/widgets/lesson_navigation_bar.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Jenis dokumen yang dideteksi dari ekstensi URL. Penting: viewer Syncfusion
/// hanya bisa PDF, jadi dokumen Office (Word/Excel/PPT) HARUS dirender lewat
/// Office online viewer di WebView — kalau tidak, area-nya kosong (bug lama:
/// .docx disuapkan ke SfPdfViewer sehingga blank tanpa error).
enum _DocKind { pdf, office, other }

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

  late final String? _docUrl;
  late final _DocKind _docKind;

  // WebView state (hanya dipakai untuk dokumen Office).
  WebViewController? _webController;
  bool _webLoading = true;
  bool _webError = false;

  @override
  void initState() {
    super.initState();
    _scaffoldKey = GlobalKey<ScaffoldState>();
    _pdfViewerController = PdfViewerController();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    _docUrl = _resolveDocumentUrl();
    _docKind = _docUrl == null ? _DocKind.other : _detectKind(_docUrl);

    if (_docKind == _DocKind.office && _docUrl != null) {
      _webController = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(Colors.white)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageFinished: (_) {
              if (mounted) setState(() => _webLoading = false);
            },
            onWebResourceError: (_) {
              if (mounted) {
                setState(() {
                  _webLoading = false;
                  _webError = true;
                });
              }
            },
          ),
        )
        ..loadRequest(Uri.parse(_officeViewerUrl(_docUrl)));
    }
  }

  @override
  void dispose() {
    _pdfViewerController?.dispose();
    super.dispose();
  }

  /// Ambil URL dokumen dari `documentUrl`, atau dari `content` jika berupa URL.
  String? _resolveDocumentUrl() {
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

  /// Deteksi jenis dokumen dari ekstensi path (abaikan query string).
  _DocKind _detectKind(String url) {
    final path = (Uri.tryParse(url)?.path ?? url).toLowerCase();
    if (path.endsWith('.pdf')) return _DocKind.pdf;
    if (path.endsWith('.doc') ||
        path.endsWith('.docx') ||
        path.endsWith('.ppt') ||
        path.endsWith('.pptx') ||
        path.endsWith('.xls') ||
        path.endsWith('.xlsx')) {
      return _DocKind.office;
    }
    return _DocKind.other;
  }

  /// Office Online viewer — me-render Word/Excel/PPT inline (sama seperti web).
  /// Syaratnya file harus ber-URL publik (backend sudah mengirim URL publik).
  String _officeViewerUrl(String fileUrl) =>
      'https://view.officeapps.live.com/op/embed.aspx?src=${Uri.encodeComponent(fileUrl)}';

  Future<void> _openExternally() async {
    final url = _docUrl;
    if (url == null) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak dapat membuka dokumen.')),
      );
    }
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
            forwardBlocked: canGoNext && widget.lesson.attendancePending,
            blockedReason: AttendanceInfo.blockedReason(widget.lesson),
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
            if (widget.lesson.attendanceRequired)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: AttendanceStatusBanner(lesson: widget.lesson),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: _buildDocumentToolbar(),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildDocumentCard(),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentToolbar() {
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
                _docUrl == null
                    ? 'Dokumen belum tersedia untuk lesson ini.'
                    : '',
                style: TextStyle(fontSize: 11.5, color: AppColors.slate),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        // PDF: tombol zoom (dikontrol Syncfusion). Selain itu: tombol buka di
        // aplikasi/peramban eksternal supaya pengguna bisa unduh/baca penuh.
        if (_docUrl != null)
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(12),
            ),
            child: _docKind == _DocKind.pdf
                ? PopupMenuButton<String>(
                    icon: const Icon(
                      Icons.zoom_in_rounded,
                      color: AppColors.red,
                    ),
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
                  )
                : IconButton(
                    icon: const Icon(
                      Icons.open_in_new_rounded,
                      color: AppColors.red,
                    ),
                    tooltip: 'Buka / unduh dokumen',
                    onPressed: _openExternally,
                  ),
          ),
      ],
    );
  }

  Widget _buildDocumentCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
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
          color: AppColors.surface,
          child: _buildViewerForKind(),
        ),
      ),
    );
  }

  Widget _buildViewerForKind() {
    if (_docUrl == null) return _buildMissingDocumentState();

    switch (_docKind) {
      case _DocKind.pdf:
        return SfPdfViewer.network(
          _docUrl,
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
        );
      case _DocKind.office:
        return _buildOfficeViewer();
      case _DocKind.other:
        return _buildUnsupportedState();
    }
  }

  Widget _buildOfficeViewer() {
    if (_webError || _webController == null) {
      return _buildOpenExternallyState(
        title: 'Pratinjau dokumen gagal dimuat',
        message:
            'Periksa koneksi internet, lalu coba lagi atau buka dokumen di '
            'aplikasi lain.',
      );
    }

    return Stack(
      children: [
        WebViewWidget(controller: _webController!),
        if (_webLoading)
          const Center(
            child: CircularProgressIndicator(color: AppColors.red),
          ),
      ],
    );
  }

  Widget _buildUnsupportedState() {
    return _buildOpenExternallyState(
      title: 'Format dokumen ini belum bisa dipratinjau',
      message: 'Buka dokumen di aplikasi lain untuk membacanya.',
    );
  }

  Widget _buildOpenExternallyState({
    required String title,
    required String message,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.description_rounded,
              size: 56,
              color: AppColors.slate,
            ),
            const SizedBox(height: 12),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.slate),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _openExternally,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.red,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
              ),
              icon: const Icon(Icons.open_in_new_rounded),
              label: const Text('Buka / Unduh Dokumen'),
            ),
          ],
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
              'Dokumen belum tersedia',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Backend perlu mengirim URL dokumen untuk lesson ini.',
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
