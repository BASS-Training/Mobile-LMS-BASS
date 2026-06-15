import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:go_router/go_router.dart';
import 'package:lms_mobile_app/src/core/di/injector.dart';
import 'package:lms_mobile_app/src/features/instructor/domain/entities/instructor_entities.dart';
import 'package:lms_mobile_app/src/features/instructor/presentation/cubit/essay_grading_cubit.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';
import 'package:lms_mobile_app/src/shared/styles/app_shadows.dart';
import 'package:lms_mobile_app/src/shared/widgets/app_empty_state.dart';
import 'package:lms_mobile_app/src/shared/widgets/brand_app_bar.dart';

/// Grade one essay submission, honouring the content's web grading rules
/// (per-question vs overall; with or without scoring).
class InstructorEssayGradingScreen extends StatelessWidget {
  final String submissionId;

  const InstructorEssayGradingScreen({super.key, required this.submissionId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<EssayGradingCubit>(
      create: (_) =>
          ServiceLocator().locator<EssayGradingCubit>(param1: submissionId)
            ..load(),
      child: const _EssayGradingView(),
    );
  }
}

class _EssayGradingView extends StatefulWidget {
  const _EssayGradingView();

  @override
  State<_EssayGradingView> createState() => _EssayGradingViewState();
}

class _EssayGradingViewState extends State<_EssayGradingView> {
  final Map<String, TextEditingController> _score = {};
  final Map<String, TextEditingController> _feedback = {};
  final TextEditingController _overallScore = TextEditingController();
  final TextEditingController _overallFeedback = TextEditingController();
  bool _initialized = false;

  @override
  void dispose() {
    for (final c in _score.values) {
      c.dispose();
    }
    for (final c in _feedback.values) {
      c.dispose();
    }
    _overallScore.dispose();
    _overallFeedback.dispose();
    super.dispose();
  }

  void _initControllers(EssaySubmissionDetail d) {
    if (_initialized) return;
    _initialized = true;
    for (final a in d.answers) {
      _score[a.answerId] =
          TextEditingController(text: a.score?.toString() ?? '');
      _feedback[a.answerId] = TextEditingController(text: a.feedback ?? '');
    }
    if (d.isOverall && d.answers.isNotEmpty) {
      final first = d.answers.first;
      _overallScore.text = first.score?.toString() ?? '';
      _overallFeedback.text = first.feedback ?? '';
    }
  }

  int _maxOverall(EssaySubmissionDetail d) =>
      d.answers.fold(0, (sum, a) => sum + a.maxScore);

  Future<void> _submit(EssaySubmissionDetail d) async {
    final cubit = context.read<EssayGradingCubit>();
    bool ok;
    if (d.isOverall) {
      int? score;
      if (d.scoringEnabled) {
        score = int.tryParse(_overallScore.text.trim());
        final max = _maxOverall(d);
        if (score == null || score < 0 || score > max) {
          _toast('Masukkan nilai keseluruhan 0–$max.');
          return;
        }
      }
      ok = await cubit.submitOverall(
        score: score,
        feedback: _overallFeedback.text.trim().isEmpty
            ? null
            : _overallFeedback.text.trim(),
      );
    } else {
      final grades = <Map<String, dynamic>>[];
      for (final a in d.answers) {
        final fb = _feedback[a.answerId]?.text.trim() ?? '';
        int? score;
        if (d.scoringEnabled) {
          final raw = _score[a.answerId]?.text.trim() ?? '';
          if (raw.isNotEmpty) {
            score = int.tryParse(raw);
            if (score == null || score < 0 || score > a.maxScore) {
              _toast('Nilai tiap soal harus 0–${a.maxScore}.');
              return;
            }
          }
        }
        grades.add({
          'answerId': int.tryParse(a.answerId) ?? a.answerId,
          'score': ?score,
          'feedback': fb,
        });
      }
      ok = await cubit.submitIndividual(grades);
    }

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
      appBar: const BrandAppBar(title: 'Nilai Essay'),
      body: BlocConsumer<EssayGradingCubit, EssayGradingState>(
        listenWhen: (p, c) => p.error != c.error && c.error != null,
        listener: (context, state) {
          if (state.error != null) _toast(state.error!);
        },
        builder: (context, state) {
          if (state.status == EssayGradingStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.brandPrimary),
            );
          }
          if (state.status == EssayGradingStatus.error || state.detail == null) {
            return AppEmptyState(
              icon: Icons.error_outline_rounded,
              title: 'Gagal memuat',
              message: state.error ?? 'Jawaban tidak ditemukan.',
              actionLabel: 'Coba lagi',
              onAction: () => context.read<EssayGradingCubit>().load(),
            );
          }

          final d = state.detail!;
          _initControllers(d);

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  children: [
                    _headerCard(d),
                    const SizedBox(height: 16),
                    for (var i = 0; i < d.answers.length; i++) ...[
                      _answerCard(d, d.answers[i], i),
                      const SizedBox(height: 14),
                    ],
                    if (d.isOverall) _overallCard(d),
                  ],
                ),
              ),
              _submitBar(state, d),
            ],
          );
        },
      ),
    );
  }

  Widget _headerCard(EssaySubmissionDetail d) {
    final modeLabel = d.isOverall ? 'Nilai keseluruhan' : 'Nilai per soal';
    final scoreLabel = d.scoringEnabled ? 'Dengan nilai' : 'Feedback saja';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            d.participantName,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            d.contentTitle,
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _chip(modeLabel, AppColors.info),
              _chip(scoreLabel, AppColors.brandPrimary),
              if (d.scoringEnabled && d.maxTotalScore != null)
                _chip(
                  'Total: ${d.totalScore ?? 0}/${d.maxTotalScore}',
                  AppColors.success,
                ),
              _chip(
                d.isFullyGraded ? 'Sudah dinilai' : 'Belum dinilai',
                d.isFullyGraded ? AppColors.success : AppColors.warning,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _answerCard(EssaySubmissionDetail d, EssayAnswerItem a, int index) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Soal ${index + 1}${d.scoringEnabled ? ' · maks ${a.maxScore}' : ''}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.brandPrimary,
            ),
          ),
          if (a.question.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              a.question,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
          ],
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(12),
            ),
            child: a.answer.trim().isEmpty
                ? Text(
                    '(Tidak ada jawaban)',
                    style: TextStyle(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      color: AppColors.textTertiary,
                    ),
                  )
                : Html(
                    data: a.answer,
                    style: {'body': Style(margin: Margins.zero)},
                  ),
          ),
          // Per-soal inputs hanya untuk mode individual.
          if (!d.isOverall) ...[
            const SizedBox(height: 12),
            if (d.scoringEnabled)
              _scoreField(
                controller: _score[a.answerId]!,
                hint: 'Nilai (0–${a.maxScore})',
              ),
            if (d.scoringEnabled) const SizedBox(height: 10),
            _feedbackField(
              controller: _feedback[a.answerId]!,
              hint: 'Feedback untuk soal ini',
            ),
          ],
        ],
      ),
    );
  }

  Widget _overallCard(EssaySubmissionDetail d) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Penilaian keseluruhan',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          if (d.scoringEnabled)
            _scoreField(
              controller: _overallScore,
              hint: 'Nilai total (0–${_maxOverall(d)})',
            ),
          if (d.scoringEnabled) const SizedBox(height: 10),
          _feedbackField(
            controller: _overallFeedback,
            hint: 'Feedback untuk peserta',
          ),
        ],
      ),
    );
  }

  Widget _scoreField({
    required TextEditingController controller,
    required String hint,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: _inputDecoration(hint),
    );
  }

  Widget _feedbackField({
    required TextEditingController controller,
    required String hint,
  }) {
    return TextField(
      controller: controller,
      maxLines: 3,
      minLines: 2,
      decoration: _inputDecoration(hint),
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

  Widget _submitBar(EssayGradingState state, EssaySubmissionDetail d) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: state.submitting ? null : () => _submit(d),
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

  Widget _chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: color,
        ),
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
