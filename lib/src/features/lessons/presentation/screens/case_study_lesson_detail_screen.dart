import 'package:flutter/material.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/utils/lesson_actions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:lms_mobile_app/src/features/courses/domain/entities/course_entity.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/entities/case_study_entity.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/entities/lesson_entity.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/bloc/case_study/case_study_bloc.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/bloc/case_study/case_study_event.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/bloc/case_study/case_study_state.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/screens/case_study_pdf_viewer_screen.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/utils/lesson_navigation_mixin.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/widgets/case_study/case_study_table_widget.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';
import 'package:lms_mobile_app/src/shared/styles/app_shadows.dart';
import 'package:lms_mobile_app/src/shared/widgets/lesson_app_bar.dart';
import 'package:lms_mobile_app/src/shared/widgets/lesson_navigation_bar.dart';
import 'package:lms_mobile_app/src/shared/widgets/press_scale.dart';

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
    extends State<CaseStudyLessonDetailScreen>
    with LessonNavigationMixin {
  final Map<String, TextEditingController> _controllers = {};

  @override
  CourseEntity get currentCourse => widget.course;

  @override
  int get currentLessonIndex => widget.lessonIndex;

  // ── Warna "kertas" dokumen ──────────────────────────────────────────────
  // Template studi kasus dirender server (DomPDF) sebagai dokumen kertas putih
  // dengan warna penyusun (header tabel dsb). Agar pratinjau di HP SAMA dengan
  // PDF yang akan diunduh dan tetap terbaca, area dokumen selalu memakai kanvas
  // putih + tinta gelap, bahkan saat dark mode (pola umum: Word/Docs/PDF viewer
  // menjaga halaman tetap terang). Chrome (appbar, tombol) tetap ikut tema.
  static const Color _paper = Color(0xFFFFFFFF);
  static const Color _paperMuted = Color(0xFFF4F6F8);
  static const Color _paperBorder = Color(0xFFE1E4E9);
  static const Color _ink = Color(0xFF1A1C1E);
  static const Color _inkSoft = Color(0xFF5C636E);
  static const Color _inkFaint = Color(0xFF9AA0A6);

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
    popToCourse(context);
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

  String _cellAnswer(CaseStudyEntity data, String sid, String bid, String rc) {
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

  /// Seperti essay: semua slot jawaban (teks & sel input tabel) wajib terisi
  /// sebelum boleh dikumpulkan — tanpa minimal kata, cukup tidak kosong.
  bool _allSlotsFilled(CaseStudyEntity data) {
    for (final section in data.sections) {
      for (final block in section.blocks) {
        if (block.isText) {
          final ctrl = _controllers['T::${section.id}::${block.id}'];
          if ((ctrl?.text ?? '').trim().isEmpty) return false;
        } else if (block.isTable && block.table != null) {
          for (final row in block.table!.cells) {
            for (final cell in row) {
              if (cell.covered || !cell.isInput) continue;
              final ctrl =
                  _controllers['C::${section.id}::${block.id}::${cell.key}'];
              if ((ctrl?.text ?? '').trim().isEmpty) return false;
            }
          }
        }
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _backToCourse();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: LessonAppBar(
          courseTitle: widget.course.title,
          subtitle: 'STUDI KASUS',
          onBack: _backToCourse,
        ),
        // Setelah dikumpulkan (read-only), tampilkan navigasi antar-lesson
        // seperti lesson lain agar peserta bisa langsung lanjut/sebelumnya.
        bottomNavigationBar: BlocBuilder<CaseStudyBloc, CaseStudyState>(
          builder: (context, state) {
            final submitted = state.data?.submission?.isSubmitted ?? false;
            if (!submitted) return const SizedBox.shrink();
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: LessonNavigationBar(
                  canGoPrevious: canGoPrevious,
                  canGoNext: canGoNext,
                  onPrevious: canGoPrevious
                      ? () => navigateToLesson(
                          previousLesson!,
                          widget.lessonIndex - 1,
                        )
                      : null,
                  onForward: () {
                    if (canGoNext && nextLesson != null) {
                      navigateToLesson(nextLesson!, widget.lessonIndex + 1);
                    } else {
                      _backToCourse();
                    }
                  },
                ),
              ),
            );
          },
        ),
        body: BlocConsumer<CaseStudyBloc, CaseStudyState>(
          listener: (context, state) {
            if (state.errorMessage != null) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
              context.read<CaseStudyBloc>().add(const ClearCaseStudyMessage());
            } else if (state.infoMessage != null) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.infoMessage!)));
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
                      Icon(
                        Icons.error_outline_rounded,
                        size: 48,
                        color: AppColors.brandText,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        state.errorMessage ?? 'Gagal memuat studi kasus',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => context.read<CaseStudyBloc>().add(
                          LoadCaseStudy(widget.lesson.id),
                        ),
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
        // Header hero
        _buildHeader(data),
        if (data.submission != null && data.submission!.isSubmitted) ...[
          const SizedBox(height: 12),
          _statusCard(data),
        ],
        const SizedBox(height: 14),

        // Catatan kecil: jelaskan kenapa area dokumen tetap putih di dark mode.
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Row(
            children: [
              Icon(
                Icons.description_outlined,
                size: 14,
                color: AppColors.textTertiary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Tampil seperti dokumen yang akan diunduh (PDF).',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Kanvas "kertas" — selalu putih agar konsisten dengan PDF & terbaca.
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
          decoration: BoxDecoration(
            color: _paper,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _paperBorder),
            boxShadow: AppShadows.sm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: data.sections.isEmpty
                ? const [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        'Template studi kasus belum disusun.',
                        style: TextStyle(color: _inkSoft),
                      ),
                    ),
                  ]
                : data.sections
                      .map((s) => _buildSection(data, s, readOnly))
                      .toList(),
          ),
        ),

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

  Widget _buildHeader(CaseStudyEntity data) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderSubtle),
        boxShadow: AppShadows.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.brandSurface,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.assignment_rounded,
              color: AppColors.brandText,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'STUDI KASUS',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: AppColors.brandText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data.title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    height: 1.2,
                  ),
                ),
                if (data.description.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    data.description,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.45,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusCard(CaseStudyEntity data) {
    final sub = data.submission!;
    final accent = sub.isGraded ? AppColors.info : AppColors.success;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                sub.isGraded
                    ? Icons.verified_rounded
                    : Icons.check_circle_rounded,
                color: accent,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                sub.isGraded ? 'Sudah dinilai' : 'Sudah dikumpulkan',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: accent,
                ),
              ),
            ],
          ),
          if (sub.isGraded && data.scoringEnabled && sub.score != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Nilai: ${sub.score}',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          if (sub.feedback != null && sub.feedback!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                'Feedback: ${sub.feedback}',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.45,
                ),
              ),
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
    final title = section.title.isEmpty
        ? (isSub ? 'Subbab' : 'Bab')
        : section.title;
    return Container(
      margin: EdgeInsets.only(top: 18, left: isSub ? 12 : 0),
      padding: EdgeInsets.only(left: isSub ? 14 : 0),
      decoration: isSub
          ? const BoxDecoration(
              border: Border(
                left: BorderSide(color: AppColors.brandPrimaryLight, width: 3),
              ),
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isSub)
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: _ink,
              ),
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    color: AppColors.brandPrimary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: _ink,
                    ),
                  ),
                ),
              ],
            ),
          if (section.instruction.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                section.instruction,
                style: const TextStyle(
                  fontSize: 13,
                  color: _inkSoft,
                  height: 1.45,
                ),
              ),
            ),
          const SizedBox(height: 10),
          ...section.blocks.map((b) => _buildBlock(data, section, b, readOnly)),
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
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  block.label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
                    color: _ink,
                  ),
                ),
              ),
            if (readOnly)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: _paperMuted,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _paperBorder),
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
                cursorColor: AppColors.brandPrimary,
                style: const TextStyle(
                  fontSize: 14,
                  color: _ink,
                  height: 1.45,
                ),
                decoration: InputDecoration(
                  hintText: 'Tuliskan jawaban Anda...',
                  hintStyle: const TextStyle(color: _inkFaint),
                  contentPadding: const EdgeInsets.all(14),
                  filled: true,
                  fillColor: _paper,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: _paperBorder),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: _paperBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.brandPrimary,
                      width: 1.5,
                    ),
                  ),
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
                : const Icon(Icons.save_outlined, size: 18),
            label: const Text('Simpan Draft'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.brandPrimary,
              side: const BorderSide(color: AppColors.brandPrimary, width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              textStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: state.submitting
                ? null
                : () {
                    if (!_allSlotsFilled(data)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Lengkapi semua slot jawaban dulu sebelum mengumpulkan.',
                          ),
                        ),
                      );
                      return;
                    }
                    _confirmSubmit(context, data);
                  },
            icon: state.submitting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.send_rounded, size: 18),
            label: const Text('Kumpulkan'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brandPrimary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              textStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
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
    return PressScale(
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton.icon(
          onPressed: state.downloading
              ? null
              : () => context.read<CaseStudyBloc>().add(
                  DownloadCaseStudyPdf(widget.lesson.id),
                ),
          icon: state.downloading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.picture_as_pdf_rounded, size: 20),
          label: const Text('Lihat / Unduh PDF'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.brandPrimary,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
