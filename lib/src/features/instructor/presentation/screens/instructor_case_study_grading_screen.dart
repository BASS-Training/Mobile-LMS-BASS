import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:go_router/go_router.dart';
import 'package:lms_mobile_app/src/core/di/injector.dart';
import 'package:lms_mobile_app/src/features/instructor/data/instructor_repository.dart';
import 'package:lms_mobile_app/src/features/instructor/presentation/cubit/case_study_grading_cubit.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/entities/case_study_entity.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/widgets/case_study/case_study_table_widget.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';
import 'package:lms_mobile_app/src/shared/styles/app_shadows.dart';
import 'package:lms_mobile_app/src/shared/widgets/app_empty_state.dart';
import 'package:lms_mobile_app/src/shared/widgets/brand_app_bar.dart';

/// Review one case-study submission (read-only filled template) and grade it.
class InstructorCaseStudyGradingScreen extends StatelessWidget {
  final String submissionId;

  const InstructorCaseStudyGradingScreen({super.key, required this.submissionId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CaseStudyGradingCubit>(
      create: (_) =>
          ServiceLocator().locator<CaseStudyGradingCubit>(param1: submissionId)
            ..load(),
      child: const _CaseStudyGradingView(),
    );
  }
}

class _CaseStudyGradingView extends StatefulWidget {
  const _CaseStudyGradingView();

  @override
  State<_CaseStudyGradingView> createState() => _CaseStudyGradingViewState();
}

class _CaseStudyGradingViewState extends State<_CaseStudyGradingView> {
  final TextEditingController _score = TextEditingController();
  final TextEditingController _feedback = TextEditingController();
  bool _initialized = false;

  @override
  void dispose() {
    _score.dispose();
    _feedback.dispose();
    super.dispose();
  }

  void _init(CaseStudyReview review) {
    if (_initialized) return;
    _initialized = true;
    _score.text = review.caseStudy.submission?.score?.toString() ?? '';
    _feedback.text = review.caseStudy.submission?.feedback ?? '';
  }

  Future<void> _submit(CaseStudyReview review) async {
    final cubit = context.read<CaseStudyGradingCubit>();
    int? score;
    if (review.scoringEnabled) {
      score = int.tryParse(_score.text.trim());
      if (score == null || score < 0 || score > 100) {
        _toast('Masukkan nilai 0–100.');
        return;
      }
    }
    final ok = await cubit.submit(
      score: score,
      feedback: _feedback.text.trim().isEmpty ? null : _feedback.text.trim(),
    );
    if (!mounted) return;
    if (ok) {
      _toast('Penilaian tersimpan ✓');
      context.pop();
    }
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const BrandAppBar(title: 'Nilai Studi Kasus'),
      body: BlocConsumer<CaseStudyGradingCubit, CaseStudyGradingState>(
        listenWhen: (p, c) => p.error != c.error && c.error != null,
        listener: (context, state) {
          if (state.error != null) _toast(state.error!);
        },
        builder: (context, state) {
          if (state.status == CaseGradingStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.brandPrimary),
            );
          }
          if (state.status == CaseGradingStatus.error || state.review == null) {
            return AppEmptyState(
              icon: Icons.error_outline_rounded,
              title: 'Gagal memuat',
              message: state.error ?? 'Jawaban tidak ditemukan.',
              actionLabel: 'Coba lagi',
              onAction: () => context.read<CaseStudyGradingCubit>().load(),
            );
          }

          final review = state.review!;
          _init(review);
          final answers = review.caseStudy.submission?.answers ?? const {};

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  children: [
                    _headerCard(review),
                    const SizedBox(height: 16),
                    if (review.caseStudy.sections.isEmpty)
                      const Text('Template studi kasus belum disusun.')
                    else
                      ...review.caseStudy.sections.map(
                        (s) => _section(s, answers),
                      ),
                    const SizedBox(height: 8),
                    _gradeCard(review),
                  ],
                ),
              ),
              _submitBar(state, review),
            ],
          );
        },
      ),
    );
  }

  Widget _headerCard(CaseStudyReview review) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            review.participantName,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            review.caseStudy.title,
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _section(CaseStudySectionEntity section, Map<String, dynamic> answers) {
    final isSub = section.level == 2;
    final sectionAnswers = answers[section.id];
    final blockAnswers = sectionAnswers is Map
        ? Map<String, dynamic>.from(sectionAnswers)
        : <String, dynamic>{};

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            section.title.isEmpty ? '(Tanpa judul)' : section.title,
            style: TextStyle(
              fontSize: isSub ? 14 : 15.5,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          if (section.instruction.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              section.instruction,
              style: TextStyle(
                fontSize: 12.5,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
          const SizedBox(height: 10),
          ...section.blocks.map((b) => _block(b, blockAnswers)),
        ],
      ),
    );
  }

  Widget _block(CaseStudyBlockEntity block, Map<String, dynamic> blockAnswers) {
    if (block.isTable && block.table != null) {
      final raw = blockAnswers[block.id];
      final cellMap = raw is Map
          ? raw.map((k, v) => MapEntry(k.toString(), v?.toString() ?? ''))
          : <String, String>{};
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: CaseStudyTableWidget(
          table: block.table!,
          readOnly: true,
          valueProvider: (cell) => cellMap[cell.key] ?? '',
        ),
      );
    }

    // Text block
    final answer = blockAnswers[block.id]?.toString() ?? '';
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
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(12),
            ),
            child: answer.trim().isEmpty
                ? Text(
                    '(Tidak diisi)',
                    style: TextStyle(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      color: AppColors.textTertiary,
                    ),
                  )
                : Html(
                    data: answer,
                    style: {'body': Style(margin: Margins.zero)},
                  ),
          ),
        ],
      ),
    );
  }

  Widget _gradeCard(CaseStudyReview review) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Penilaian',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          if (review.scoringEnabled) ...[
            TextField(
              controller: _score,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: _inputDecoration('Nilai (0–100)'),
            ),
            const SizedBox(height: 10),
          ],
          TextField(
            controller: _feedback,
            maxLines: 4,
            minLines: 3,
            decoration: _inputDecoration('Feedback untuk peserta'),
          ),
        ],
      ),
    );
  }

  Widget _submitBar(CaseStudyGradingState state, CaseStudyReview review) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: state.submitting ? null : () => _submit(review),
            icon: state.submitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.check_rounded),
            label: Text(state.submitting ? 'Menyimpan…' : 'Simpan Penilaian'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brandPrimary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      isDense: true,
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.borderDefault),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.borderDefault),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.brandPrimary, width: 1.6),
      ),
    );
  }

  BoxDecoration _cardDecoration() => BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(18),
    border: Border.all(color: AppColors.borderSubtle),
    boxShadow: AppShadows.xs,
  );
}
