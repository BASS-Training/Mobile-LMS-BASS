import 'package:flutter/material.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/entities/quiz_entity.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/widgets/quiz/quiz_leaderboard_card.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/widgets/quiz/score_item_widget.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';
import 'package:lms_mobile_app/src/shared/widgets/fade_slide_in.dart';
import 'package:lms_mobile_app/src/shared/widgets/press_scale.dart';

/// Widget untuk menampilkan halaman hasil/skor kuis
class QuizResultWidget extends StatelessWidget {
  final String courseTitle;
  final QuizResult result;
  final bool canGoNext;
  final VoidCallback onNextLesson;
  final VoidCallback onBackToCourse;

  /// Papan peringkat (opsional) — hanya bila admin mengaktifkan leaderboard.
  final QuizLeaderboard? leaderboard;

  const QuizResultWidget({
    super.key,
    required this.courseTitle,
    required this.result,
    required this.canGoNext,
    required this.onNextLesson,
    required this.onBackToCourse,
    this.leaderboard,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeSlideIn(
            delayMs: 0,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: result.passed
                      ? [AppColors.red, AppColors.tomato]
                      : [AppColors.cherry, AppColors.coral],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: (result.passed ? AppColors.red : AppColors.cherry)
                        .withValues(alpha: 0.18),
                    blurRadius: 22,
                    offset: const Offset(0, 10),
                  ),
                ],
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
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Score card
          FadeSlideIn(
            delayMs: 70,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.borderSubtle),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hasil Kuis Anda',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.charcoal,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ScoreItemWidget(
                          label: 'Nilai',
                          value: '${result.percentage.toStringAsFixed(0)}%',
                          color: AppColors.brandText,
                        ),
                        ScoreItemWidget(
                          label: 'Benar',
                          value: '${result.score}',
                          color: AppColors.jade,
                        ),
                        ScoreItemWidget(
                          label: 'Total',
                          value: '${result.total}',
                          color: AppColors.tomato,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Papan peringkat (bila leaderboard diaktifkan admin)
          if (leaderboard != null && leaderboard!.entries.isNotEmpty) ...[
            FadeSlideIn(
              delayMs: 90,
              child: QuizLeaderboardCard(leaderboard: leaderboard!),
            ),
            const SizedBox(height: 24),
          ],

          // Navigation buttons
          if (result.passed)
            Column(
              children: [
                // Info box
                FadeSlideIn(
                  delayMs: 120,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.successSurface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.successBorder),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: AppColors.successText,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Kuis telah selesai! Lesson ini sudah ditandai sebagai selesai.',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.successText,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (canGoNext)
                  PressScale(
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: onNextLesson,
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text('Pelajaran Berikutnya'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.red,
                        ),
                      ),
                    ),
                  )
                else
                  PressScale(
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: onBackToCourse,
                        icon: const Icon(Icons.home),
                        label: const Text('Kembali ke Kursus'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.red,
                        ),
                      ),
                    ),
                  ),
              ],
            )
          else
            Column(
              children: [
                // Info box untuk tidak lulus
                FadeSlideIn(
                  delayMs: 120,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.warningSurface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.warningBorder),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info,
                          color: AppColors.warningText,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Nilai Anda belum mencukupi KKM (70%). Silakan coba lagi.',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.warningText,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                PressScale(
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: onBackToCourse,
                      icon: const Icon(Icons.home),
                      label: const Text('Kembali ke Kursus'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.red,
                      ),
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
