import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/entities/case_study_entity.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/entities/lesson_attempt_entity.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/bloc/case_study/case_study_bloc.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/bloc/case_study/case_study_event.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/bloc/case_study/case_study_state.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/screens/case_study_pdf_viewer_screen.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/widgets/case_study/case_study_table_widget.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';
import 'package:lms_mobile_app/src/shared/utils/app_date_formatter.dart';
import 'package:lms_mobile_app/src/shared/widgets/brand_app_bar.dart';

/// Halaman hasil khusus untuk studi kasus: menampilkan nilai, feedback,
/// dan jawaban peserta (read-only). Berbeda dari halaman hasil essay.
class CaseStudyResultDetailScreen extends StatefulWidget {
  final LessonAttempt attempt;

  const CaseStudyResultDetailScreen({super.key, required this.attempt});

  @override
  State<CaseStudyResultDetailScreen> createState() =>
      _CaseStudyResultDetailScreenState();
}

class _CaseStudyResultDetailScreenState
    extends State<CaseStudyResultDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CaseStudyBloc>().add(LoadCaseStudy(widget.attempt.lessonId));
  }

  Map<String, dynamic> _answers(CaseStudyEntity data) =>
      data.submission?.answers ?? const {};

  String _textAnswer(CaseStudyEntity data, String sid, String bid) {
    final block = _answers(data)[sid];
    if (block is Map && block[bid] is String) return block[bid] as String;
    return '';
  }

  String _cellAnswer(CaseStudyEntity data, String sid, String bid, String rc) {
    final block = _answers(data)[sid];
    if (block is Map && block[bid] is Map) {
      return (block[bid] as Map)[rc]?.toString() ?? '';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final attempt = widget.attempt;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const BrandAppBar(title: 'Hasil Studi Kasus'),
      body: BlocConsumer<CaseStudyBloc, CaseStudyState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
            context.read<CaseStudyBloc>().add(const ClearCaseStudyMessage());
          }
          if (state.pdfBytes != null) {
            final bytes = state.pdfBytes!;
            context.read<CaseStudyBloc>().add(const ClearCaseStudyMessage());
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => CaseStudyPdfViewerScreen(
                  bytes: bytes,
                  fileName: 'studi-kasus-${attempt.lessonId}.pdf',
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          final data = state.data;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              _buildScoreCard(context, state, data),
              const SizedBox(height: 16),
              if (state.status == CaseStudyStatus.loading ||
                  state.status == CaseStudyStatus.initial)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (data != null && data.sections.isNotEmpty) ...[
                const Text(
                  'Jawaban Anda',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.charcoal,
                  ),
                ),
                const SizedBox(height: 8),
                ...data.sections.map((s) => _buildSection(data, s)),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildScoreCard(
    BuildContext context,
    CaseStudyState state,
    CaseStudyEntity? data,
  ) {
    final attempt = widget.attempt;
    final sub = data?.submission;
    final graded = (sub?.isGraded ?? attempt.graded);
    final score = sub?.score?.toDouble() ?? attempt.score;
    final feedback = (sub?.feedback?.trim().isNotEmpty ?? false)
        ? sub!.feedback!.trim()
        : (attempt.feedback?.trim() ?? '');
    final scoringEnabled = data?.scoringEnabled ?? true;
    final allowDownload = data?.allowAnswerDownload ?? false;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.pearl.withValues(alpha: 0.8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            attempt.lessonTitle,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Studi Kasus • ${formatAppDateTime(attempt.submittedAt)}',
            style: const TextStyle(fontSize: 12, color: AppColors.slate),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: (graded ? Colors.green : AppColors.red).withValues(
                alpha: 0.12,
              ),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              graded ? 'Sudah Dinilai' : 'Menunggu Penilaian',
              style: TextStyle(
                color: graded ? Colors.green : AppColors.red,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (graded && scoringEnabled && score != null) ...[
            const SizedBox(height: 16),
            const Text(
              'Nilai',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.slate,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${score.toStringAsFixed(0)} / 100',
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w900,
                color: AppColors.red,
              ),
            ),
          ],
          const SizedBox(height: 16),
          const Text(
            'Feedback Instruktur',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.slate,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.pearl),
            ),
            child: Text(
              feedback.isNotEmpty
                  ? feedback
                  : (graded ? 'Tidak ada feedback.' : 'Belum dinilai.'),
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: AppColors.charcoal,
              ),
            ),
          ),
          if (allowDownload) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: state.downloading
                    ? null
                    : () => context.read<CaseStudyBloc>().add(
                        DownloadCaseStudyPdf(attempt.lessonId),
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
                    : const Icon(Icons.picture_as_pdf),
                label: const Text('Lihat / Unduh PDF'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSection(CaseStudyEntity data, CaseStudySectionEntity section) {
    final isSub = section.level == 2;
    return Padding(
      padding: EdgeInsets.only(top: 14, left: isSub ? 12 : 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            section.title.isEmpty ? (isSub ? 'Subbab' : 'Bab') : section.title,
            style: TextStyle(
              fontSize: isSub ? 14 : 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF111827),
            ),
          ),
          if (section.instruction.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                section.instruction,
                style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
              ),
            ),
          const SizedBox(height: 8),
          ...section.blocks.map((b) => _buildBlock(data, section, b)),
        ],
      ),
    );
  }

  Widget _buildBlock(
    CaseStudyEntity data,
    CaseStudySectionEntity section,
    CaseStudyBlockEntity block,
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
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Html(data: _textAnswer(data, sid, bid)),
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
          readOnly: true,
          valueProvider: (cell) => _cellAnswer(data, sid, bid, cell.key),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
