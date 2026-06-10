import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:lms_mobile_app/src/features/courses/domain/entities/course_entity.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/bloc/course/course_bloc.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/bloc/course/course_event.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/entities/case_study_entity.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/entities/lesson_entity.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/bloc/case_study/case_study_bloc.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/bloc/case_study/case_study_event.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/bloc/case_study/case_study_state.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/screens/case_study_pdf_viewer_screen.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/widgets/case_study/case_study_table_widget.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';

class CaseStudyLessonDetailScreen extends StatefulWidget {
  final LessonEntity lesson;
  final CourseEntity course;
  final int lessonIndex;

  const CaseStudyLessonDetailScreen({
    super.key,
    required this.lesson,
    required this.course,
    required this.lessonIndex,
  });

  @override
  State<CaseStudyLessonDetailScreen> createState() =>
      _CaseStudyLessonDetailScreenState();
}

class _CaseStudyLessonDetailScreenState
    extends State<CaseStudyLessonDetailScreen> {
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    context.read<CaseStudyBloc>().add(LoadCaseStudy(widget.lesson.id));
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _backToCourse() {
    Navigator.pop(context);
    context.read<CourseBloc>().add(const RefreshCoursesEvent());
  }

  // ---- HTML <-> plain helpers (web menyimpan jawaban teks sebagai HTML) ----
  String _htmlToPlain(String html) {
    var s = html;
    s = s.replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n');
    s = s.replaceAll(RegExp(r'</p>', caseSensitive: false), '\n');
    s = s.replaceAll(RegExp(r'<[^>]+>'), '');
    s = s
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>');
    return s.trim();
  }

  String _plainToHtml(String plain) {
    final escaped = plain
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;');
    return escaped.replaceAll('\n', '<br>');
  }

  TextEditingController _controller(String key, String initial) {
    return _controllers.putIfAbsent(
      key,
      () => TextEditingController(text: initial),
    );
  }

  Map<String, dynamic> _existingAnswers(CaseStudyEntity data) {
    return data.submission?.answers ?? const {};
  }

  String _textAnswer(CaseStudyEntity data, String sid, String bid) {
    final block = _existingAnswers(data)[sid];
    if (block is Map && block[bid] is String) return block[bid] as String;
    return '';
  }

  String _cellAnswer(
    CaseStudyEntity data,
    String sid,
    String bid,
    String rc,
  ) {
    final block = _existingAnswers(data)[sid];
    if (block is Map && block[bid] is Map) {
      final v = (block[bid] as Map)[rc];
      return v?.toString() ?? '';
    }
    return '';
  }

  /// Susun map jawaban dari controller untuk dikirim ke server.
  Map<String, dynamic> _buildAnswers(CaseStudyEntity data) {
    final answers = <String, dynamic>{};
    for (final section in data.sections) {
      final sid = section.id;
      for (final block in section.blocks) {
        final bid = block.id;
        if (block.isText) {
          final ctrl = _controllers['T::$sid::$bid'];
          final text = ctrl?.text ?? '';
          (answers[sid] ??= <String, dynamic>{})[bid] = _plainToHtml(text);
        } else if (block.isTable && block.table != null) {
          final cellMap = <String, String>{};
          for (final row in block.table!.cells) {
            for (final cell in row) {
              if (cell.covered || !cell.isInput) continue;
              final ctrl = _controllers['C::$sid::$bid::${cell.key}'];
              cellMap[cell.key] = ctrl?.text ?? '';
            }
          }
          (answers[sid] ??= <String, dynamic>{})[bid] = cellMap;
        }
      }
    }
    return answers;
  }

  bool _isReadOnly(CaseStudyEntity data) =>
      data.submission?.isSubmitted ?? false;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _backToCourse();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Studi Kasus'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _backToCourse,
          ),
        ),
        body: BlocConsumer<CaseStudyBloc, CaseStudyState>(
          listener: (context, state) {
            if (state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.errorMessage!)),
              );
              context.read<CaseStudyBloc>().add(const ClearCaseStudyMessage());
            } else if (state.infoMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.infoMessage!)),
              );
              context.read<CaseStudyBloc>().add(const ClearCaseStudyMessage());
            }
            if (state.pdfBytes != null) {
              final bytes = state.pdfBytes!;
              context.read<CaseStudyBloc>().add(const ClearCaseStudyMessage());
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CaseStudyPdfViewerScreen(
                    bytes: bytes,
                    fileName: 'studi-kasus-${widget.lesson.id}.pdf',
                  ),
                ),
              );
            }
          },
          builder: (context, state) {
            if (state.status == CaseStudyStatus.loading ||
                state.status == CaseStudyStatus.initial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.status == CaseStudyStatus.error || state.data == null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 48, color: Colors.redAccent),
                      const SizedBox(height: 12),
                      Text(
                        state.errorMessage ?? 'Gagal memuat studi kasus',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => context
                            .read<CaseStudyBloc>()
                            .add(LoadCaseStudy(widget.lesson.id)),
                        child: const Text('Coba lagi'),
                      ),
                    ],
                  ),
                ),
              );
            }
            return _buildContent(context, state, state.data!);
          },
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    CaseStudyState state,
    CaseStudyEntity data,
  ) {
    final readOnly = _isReadOnly(data);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        // Header
        Text(
          data.title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        if (data.description.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(data.description,
              style: const TextStyle(color: Color(0xFF6B7280))),
        ],
        const SizedBox(height: 8),
        if (data.submission != null && data.submission!.isSubmitted)
          _statusCard(data),
        const SizedBox(height: 12),

        // Sections
        if (data.sections.isEmpty)
          const Text('Template studi kasus belum disusun.')
        else
          ...data.sections.map((s) => _buildSection(data, s, readOnly)),

        const SizedBox(height: 24),

        // Actions
        if (!readOnly) _buildEditActions(context, state, data),
        if (readOnly &&
            data.allowAnswerDownload &&
            (data.submission?.isSubmitted ?? false))
          _buildDownloadButton(context, state),
      ],
    );
  }

  Widget _statusCard(CaseStudyEntity data) {
    final sub = data.submission!;
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: sub.isGraded ? const Color(0xFFEFF6FF) : const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: sub.isGraded
              ? const Color(0xFFBFDBFE)
              : const Color(0xFFA7F3D0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            sub.isGraded ? '✓ Sudah dinilai' : '✓ Sudah dikumpulkan',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          if (sub.isGraded && data.scoringEnabled && sub.score != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text('Nilai: ${sub.score}'),
            ),
          if (sub.feedback != null && sub.feedback!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text('Feedback: ${sub.feedback}'),
            ),
        ],
      ),
    );
  }

  Widget _buildSection(
    CaseStudyEntity data,
    CaseStudySectionEntity section,
    bool readOnly,
  ) {
    final isSub = section.level == 2;
    return Container(
      margin: EdgeInsets.only(top: 16, left: isSub ? 12 : 0),
      padding: EdgeInsets.only(left: isSub ? 10 : 0),
      decoration: isSub
          ? const Border(
                  left: BorderSide(color: Color(0xFFFCD34D), width: 2))
              .toBoxDecoration()
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            section.title.isEmpty
                ? (isSub ? 'Subbab' : 'Bab')
                : section.title,
            style: TextStyle(
              fontSize: isSub ? 15 : 17,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF111827),
            ),
          ),
          if (section.instruction.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                section.instruction,
                style: const TextStyle(
                    fontSize: 13, color: Color(0xFF6B7280)),
              ),
            ),
          const SizedBox(height: 8),
          ...section.blocks
              .map((b) => _buildBlock(data, section, b, readOnly)),
        ],
      ),
    );
  }

  Widget _buildBlock(
    CaseStudyEntity data,
    CaseStudySectionEntity section,
    CaseStudyBlockEntity block,
    bool readOnly,
  ) {
    final sid = section.id;
    final bid = block.id;

    if (block.isText) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (block.label.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  block.label,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            if (readOnly)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Html(data: _textAnswer(data, sid, bid)),
              )
            else
              TextField(
                controller: _controller(
                  'T::$sid::$bid',
                  _htmlToPlain(_textAnswer(data, sid, bid)),
                ),
                maxLines: null,
                minLines: 3,
                decoration: InputDecoration(
                  hintText: 'Tuliskan jawaban Anda...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
          ],
        ),
      );
    }

    if (block.isTable && block.table != null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: CaseStudyTableWidget(
          table: block.table!,
          readOnly: readOnly,
          controllerProvider: readOnly
              ? null
              : (cell) => _controller(
                    'C::$sid::$bid::${cell.key}',
                    _cellAnswer(data, sid, bid, cell.key),
                  ),
          valueProvider: (cell) => _cellAnswer(data, sid, bid, cell.key),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildEditActions(
    BuildContext context,
    CaseStudyState state,
    CaseStudyEntity data,
  ) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: state.draftSaving
                ? null
                : () => context.read<CaseStudyBloc>().add(
                      SaveDraftCaseStudy(
                        lessonId: widget.lesson.id,
                        answers: _buildAnswers(data),
                      ),
                    ),
            icon: state.draftSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_outlined),
            label: const Text('Simpan Draft'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: state.submitting
                ? null
                : () => _confirmSubmit(context, data),
            icon: state.submitting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.send),
            label: const Text('Kumpulkan'),
          ),
        ),
      ],
    );
  }

  Future<void> _confirmSubmit(
    BuildContext context,
    CaseStudyEntity data,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Kumpulkan jawaban?'),
        content: const Text(
          'Setelah dikumpulkan, jawaban akan dikunci. Lanjutkan?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Kumpulkan'),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      context.read<CaseStudyBloc>().add(
            SubmitCaseStudy(
              lessonId: widget.lesson.id,
              answers: _buildAnswers(data),
            ),
          );
    }
  }

  Widget _buildDownloadButton(BuildContext context, CaseStudyState state) {
    return ElevatedButton.icon(
      onPressed: state.downloading
          ? null
          : () => context
              .read<CaseStudyBloc>()
              .add(DownloadCaseStudyPdf(widget.lesson.id)),
      icon: state.downloading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Icon(Icons.picture_as_pdf),
      label: const Text('Lihat / Unduh PDF'),
    );
  }
}

extension _BorderToDecoration on Border {
  BoxDecoration toBoxDecoration() => BoxDecoration(border: this);
}
