import 'package:flutter/material.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';

/// Widget untuk navigasi nomor soal
/// Menampilkan grid/list nomor soal yang bisa diklik untuk jump ke soal tertentu
class QuestionNavigatorWidget extends StatelessWidget {
  final int totalQuestions;
  final int currentQuestionIndex;
  final Map<int, int?> answers; // index -> selectedOptionIndex
  final Function(int) onQuestionSelected;

  const QuestionNavigatorWidget({
    super.key,
    required this.totalQuestions,
    required this.currentQuestionIndex,
    required this.answers,
    required this.onQuestionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Navigasi Soal',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.text,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemCount: totalQuestions,
          itemBuilder: (context, index) {
            final isCurrentQuestion = index == currentQuestionIndex;
            final isAnswered = answers[index] != null;

            return GestureDetector(
              onTap: () => onQuestionSelected(index),
              child: Container(
                decoration: BoxDecoration(
                  color: isCurrentQuestion
                      ? AppColors.primary
                      : (isAnswered ? Colors.green[100] : Colors.grey[200]),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isCurrentQuestion
                        ? AppColors.primary
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isAnswered && !isCurrentQuestion)
                        Icon(Icons.check, color: Colors.green, size: 16)
                      else
                        Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isCurrentQuestion
                                ? Colors.white
                                : AppColors.text,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        _buildLegend(),
      ],
    );
  }

  /// Legend untuk penjelasan warna
  Widget _buildLegend() {
    return Row(
      children: [
        _buildLegendItem(color: AppColors.primary, label: 'Aktif'),
        const SizedBox(width: 16),
        _buildLegendItem(color: Colors.green[100]!, label: 'Terjawab'),
        const SizedBox(width: 16),
        _buildLegendItem(color: Colors.grey[200]!, label: 'Belum'),
      ],
    );
  }

  Widget _buildLegendItem({required Color color, required String label}) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textLight),
        ),
      ],
    );
  }
}
