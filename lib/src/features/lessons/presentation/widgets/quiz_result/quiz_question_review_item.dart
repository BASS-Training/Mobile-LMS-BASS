import 'package:flutter/material.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/entities/lesson_attempt_entity.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';

class QuizQuestionReviewItem extends StatelessWidget {
  final LessonAttemptQuestionSnapshot question;

  const QuizQuestionReviewItem({super.key, required this.question});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Soal ${question.questionIndex + 1}',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.brandText,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '${question.options.length} opsi',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.slate,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            question.questionText,
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              fontWeight: FontWeight.w700,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 12),
          ...question.options.asMap().entries.map((entry) {
            final optionIndex = entry.key;
            final optionText = entry.value;
            final style = _resolveOptionStyle(
              optionIndex: optionIndex,
              selectedIndex: question.selectedOptionIndex,
              correctIndex: question.correctOptionIndex,
            );

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: style.backgroundColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: style.borderColor),
                boxShadow: [
                  BoxShadow(
                    color: style.shadowColor,
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: style.badgeColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        String.fromCharCode(65 + optionIndex),
                        style: TextStyle(
                          color: style.badgeTextColor,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      optionText,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.45,
                        color: AppColors.charcoal,
                      ),
                    ),
                  ),
                  if (style.label.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: style.labelBackgroundColor,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(style.icon, size: 12, color: style.labelColor),
                          const SizedBox(width: 4),
                          Text(
                            style.label,
                            style: TextStyle(
                              color: style.labelColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  _ReviewOptionStyle _resolveOptionStyle({
    required int optionIndex,
    required int? selectedIndex,
    required int? correctIndex,
  }) {
    final isSelected = selectedIndex == optionIndex;
    final isCorrect = correctIndex == optionIndex;
    final isSelectedAndCorrect = isSelected && isCorrect;
    final isSelectedAndWrong = isSelected && !isCorrect;

    if (isSelectedAndCorrect) {
      return const _ReviewOptionStyle(
        backgroundColor: Color.fromRGBO(46, 204, 113, 0.14),
        borderColor: Colors.green,
        shadowColor: Color.fromRGBO(46, 204, 113, 0.14),
        badgeColor: Colors.green,
        badgeTextColor: Colors.white,
        labelBackgroundColor: Color.fromRGBO(46, 204, 113, 0.12),
        labelColor: Colors.green,
        icon: Icons.check_circle,
        label: 'Jawaban Anda Benar',
      );
    }

    if (isSelectedAndWrong) {
      return const _ReviewOptionStyle(
        backgroundColor: Color.fromRGBO(231, 76, 60, 0.12),
        borderColor: Colors.red,
        shadowColor: Color.fromRGBO(231, 76, 60, 0.12),
        badgeColor: Colors.red,
        badgeTextColor: Colors.white,
        labelBackgroundColor: Color.fromRGBO(231, 76, 60, 0.12),
        labelColor: Colors.red,
        icon: Icons.close,
        label: 'Jawaban Anda Salah',
      );
    }

    if (isCorrect) {
      return const _ReviewOptionStyle(
        backgroundColor: Color.fromRGBO(46, 204, 113, 0.14),
        borderColor: Colors.green,
        shadowColor: Color.fromRGBO(46, 204, 113, 0.14),
        badgeColor: Colors.green,
        badgeTextColor: Colors.white,
        labelBackgroundColor: Color.fromRGBO(46, 204, 113, 0.12),
        labelColor: Colors.green,
        icon: Icons.lightbulb,
        label: 'Kunci Jawaban',
      );
    }

    return _ReviewOptionStyle(
      backgroundColor: AppColors.surfaceMuted,
      borderColor: Colors.transparent,
      shadowColor: const Color.fromRGBO(0, 0, 0, 0.03),
      badgeColor: AppColors.pearl,
      badgeTextColor: AppColors.charcoal,
      labelBackgroundColor: Colors.transparent,
      labelColor: Colors.transparent,
      icon: Icons.circle,
      label: '',
    );
  }
}

class _ReviewOptionStyle {
  final Color backgroundColor;
  final Color borderColor;
  final Color shadowColor;
  final Color badgeColor;
  final Color badgeTextColor;
  final Color labelBackgroundColor;
  final Color labelColor;
  final IconData icon;
  final String label;

  const _ReviewOptionStyle({
    required this.backgroundColor,
    required this.borderColor,
    required this.shadowColor,
    required this.badgeColor,
    required this.badgeTextColor,
    required this.labelBackgroundColor,
    required this.labelColor,
    required this.icon,
    required this.label,
  });
}
