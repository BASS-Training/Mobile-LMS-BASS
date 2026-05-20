import 'package:flutter/material.dart';
import 'package:lms_mobile_app/src/features/lessons/data/models/quiz_model.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/widgets/quiz/info_card_widget.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/widgets/quiz/instruction_card_widget.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';

/// Widget untuk menampilkan halaman intro/persiapan kuis
class QuizIntroWidget extends StatelessWidget {
  final String courseTitle;
  final String lessonTitle;
  final int lessonIndex;
  final Quiz quiz;
  final VoidCallback onStartQuiz;

  const QuizIntroWidget({
    super.key,
    required this.courseTitle,
    required this.lessonTitle,
    required this.lessonIndex,
    required this.quiz,
    required this.onStartQuiz,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header dengan gradient
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.red, AppColors.tomato],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lesson ${lessonIndex + 1}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  lessonTitle,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'QUIZ',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Instruksi Kuis
          const InstructionCardWidget(),
          const SizedBox(height: 24),

          // Quiz Info Cards
          Row(
            children: [
              Expanded(
                child: InfoCardWidget(
                  icon: Icons.list,
                  label: 'Pertanyaan',
                  value: '${quiz.totalQuestions}',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InfoCardWidget(
                  icon: Icons.timer,
                  label: 'Waktu',
                  value: '${quiz.timeLimit} min',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InfoCardWidget(
                  icon: Icons.grade,
                  label: 'Nilai Lulus',
                  value: '${quiz.passingScore}%',
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Tombol Mulai Kuis
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: onStartQuiz,
              icon: const Icon(Icons.play_arrow, size: 24),
              label: const Text(
                'Mulai Kuis',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
