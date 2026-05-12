import 'package:flutter/material.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';

class EssayQuestionNavigatorWidget extends StatelessWidget {
  final int totalQuestions;
  final int currentQuestionIndex;
  final Set<int> completedQuestionIndexes;
  final ValueChanged<int> onQuestionSelected;

  const EssayQuestionNavigatorWidget({
    super.key,
    required this.totalQuestions,
    required this.currentQuestionIndex,
    required this.completedQuestionIndexes,
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
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(totalQuestions, (index) {
            final isCurrent = index == currentQuestionIndex;
            final isCompleted = completedQuestionIndexes.contains(index);

            final backgroundColor = isCurrent
                ? AppColors.primary
                : (isCompleted ? Colors.green.shade100 : AppColors.background);

            final textColor = isCurrent
                ? Colors.white
                : (isCompleted ? Colors.green.shade800 : AppColors.textLight);

            return InkWell(
              onTap: () => onQuestionSelected(index),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isCurrent ? AppColors.primary : AppColors.border,
                  ),
                ),
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _LegendItem(
              color: AppColors.background,
              borderColor: AppColors.border,
              label: 'Belum valid',
            ),
            const SizedBox(width: 12),
            _LegendItem(
              color: Colors.green.shade100,
              borderColor: Colors.green.shade300,
              label: 'Valid (>=10 kata)',
            ),
            const SizedBox(width: 12),
            _LegendItem(
              color: AppColors.primary,
              borderColor: AppColors.primary,
              label: 'Sedang dilihat',
            ),
          ],
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final Color borderColor;
  final String label;

  const _LegendItem({
    required this.color,
    required this.borderColor,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: borderColor),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppColors.textLight),
        ),
      ],
    );
  }
}
