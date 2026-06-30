import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/bloc/essay/essay_bloc.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/bloc/essay/essay_event.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/bloc/essay/essay_state.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/widgets/quiz/question_navigator_widget.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';

class EssayPanelWidget extends StatelessWidget {
  final EssayState state;
  final TextEditingController _answerController;

  const EssayPanelWidget({
    super.key,
    required this.state,
    required TextEditingController answerController,
  }) : _answerController = answerController;

  @override
  Widget build(BuildContext context) {
    if (state.questions.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.brandSurface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${state.currentQuestionIndex + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    state.currentQuestion,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.charcoal,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Text(
              state.currentQuestion,
              style: TextStyle(
                fontSize: 15,
                height: 1.6,
                color: AppColors.charcoal,
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (state.isSubmitted) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.successSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.successBorder),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.verified_rounded, color: AppColors.successText),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Jawaban berhasil dikumpulkan',
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.35,
                            fontWeight: FontWeight.w800,
                            color: AppColors.successText,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Tidak bisa dikirim ulang. Menunggu penilaian — nilai '
                          'bisa kamu lihat nanti di menu "Nilai & Hasil".',
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.4,
                            color: AppColors.successText.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          Text(
            'Jawaban Anda',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: state.isCurrentQuestionValid
                  ? AppColors.successSurface
                  : AppColors.warningSurface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: state.isCurrentQuestionValid
                    ? AppColors.successBorder
                    : AppColors.warningBorder,
              ),
            ),
            child: Text(
              state.isCurrentQuestionValid
                  ? 'Jawaban nomor ini valid (>= 10 kata).'
                  : 'Minimal 10 kata untuk menandai nomor ini selesai.',
              style: TextStyle(
                fontSize: 12,
                color: state.isCurrentQuestionValid
                    ? AppColors.successText
                    : AppColors.warningText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            enabled: !state.isSubmitted,
            controller: _answerController,
            minLines: 10,
            maxLines: 14,
            onChanged: (value) =>
                context.read<EssayBloc>().add(AnswerChanged(value)),
            decoration: InputDecoration(
              hintText: 'Tulis jawaban essay Anda di sini...',
              alignLabelWithHint: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.pearl),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.pearl),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.brandPrimary),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '${state.currentWordCount} kata (min 10) | ${state.currentAnswer.length} karakter',
                style: TextStyle(fontSize: 11, color: AppColors.slate),
              ),
              const Spacer(),
              Text(
                state.isDraftSaved ? 'Draft tersimpan' : 'Belum disimpan',
                style: TextStyle(
                  fontSize: 11,
                  color: state.isDraftSaved
                      ? AppColors.emerald
                      : AppColors.silver,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          QuestionNavigatorWidget(
            totalQuestions: state.totalQuestions,
            currentQuestionIndex: state.currentQuestionIndex,
            completedQuestionIndexes: state.savedQuestionIndexes,
            onQuestionSelected: (index) =>
                context.read<EssayBloc>().add(ChangeQuestion(index)),
            completedLabel: 'Sudah Disimpan',
            pendingLabel: 'Belum Disimpan',
          ),
        ],
      ),
    );
  }
}
