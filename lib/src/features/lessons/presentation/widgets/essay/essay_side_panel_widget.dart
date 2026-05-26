import 'package:flutter/material.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/bloc/essay/essay_state.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';

class EssaySidePanelWidget extends StatelessWidget {
  final EssayState state;

  const EssaySidePanelWidget({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final progress = state.totalQuestions > 0
        ? (state.savedCount / state.totalQuestions) * 100
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.white, Color(0xFFF6F8FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.pearl.withValues(alpha: 0.8)),
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
          const Text(
            'Progress Essay',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress / 100,
              minHeight: 8,
              backgroundColor: AppColors.pearl.withValues(alpha: 0.5),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.tomato),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${progress.toStringAsFixed(0)}% • Soal ${state.currentQuestionIndex + 1} dari ${state.totalQuestions}',
            style: const TextStyle(fontSize: 12, color: AppColors.slate),
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1F0),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              state.isDraftSaved
                  ? 'Draft jawaban sudah disimpan'
                  : 'Draft belum disimpan',
              style: TextStyle(fontSize: 12, color: AppColors.slate),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Karakter: ${state.currentAnswer.length}',
            style: const TextStyle(fontSize: 12, color: AppColors.slate),
          ),
        ],
      ),
    );
  }
}
