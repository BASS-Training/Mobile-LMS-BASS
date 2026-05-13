import 'package:flutter/material.dart';
import 'package:lms_mobile_app/src/features/lessons/data/models/quiz_model.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/widgets/quiz/score_item_widget.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';

/// Widget untuk menampilkan halaman hasil/skor kuis
class QuizResultWidget extends StatelessWidget {
  final String courseTitle;
  final QuizResult result;
  final bool canGoNext;
  final VoidCallback onNextLesson;
  final VoidCallback onBackToCourse;

  const QuizResultWidget({
    super.key,
    required this.courseTitle,
    required this.result,
    required this.canGoNext,
    required this.onNextLesson,
    required this.onBackToCourse,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Result header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: result.passed
                    ? [Colors.green[600]!, Colors.green[400]!]
                    : [Colors.orange[600]!, Colors.orange[400]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  result.passed ? Icons.check_circle : Icons.info,
                  color: Colors.white,
                  size: 64,
                ),
                const SizedBox(height: 16),
                Text(
                  result.passed ? 'Selamat!' : 'Tidak Lulus',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  result.passed
                      ? 'Anda telah lulus kuis ini'
                      : 'Silakan coba lagi',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Score card
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Hasil Kuis Anda',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ScoreItemWidget(
                        label: 'Nilai',
                        value: '${result.percentage.toStringAsFixed(0)}%',
                        color: AppColors.violet,
                      ),
                      ScoreItemWidget(
                        label: 'Benar',
                        value: '${result.score}',
                        color: Colors.green,
                      ),
                      ScoreItemWidget(
                        label: 'Total',
                        value: '${result.total}',
                        color: Colors.blue,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Navigation buttons
          if (result.passed)
            Column(
              children: [
                // Info box
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green[600],
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Kuis telah selesai! Lesson ini sudah ditandai sebagai selesai.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.green[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (canGoNext)
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: onNextLesson,
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Pelajaran Berikutnya'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.violet,
                      ),
                    ),
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: onBackToCourse,
                      icon: const Icon(Icons.home),
                      label: const Text('Kembali ke Kursus'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.violet,
                      ),
                    ),
                  ),
              ],
            )
          else
            Column(
              children: [
                // Info box untuk tidak lulus
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info, color: Colors.orange[600], size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Nilai Anda belum mencukupi KKM (70%). Silakan coba lagi.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.orange[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: onBackToCourse,
                    icon: const Icon(Icons.home),
                    label: const Text('Kembali ke Kursus'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.violet,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

