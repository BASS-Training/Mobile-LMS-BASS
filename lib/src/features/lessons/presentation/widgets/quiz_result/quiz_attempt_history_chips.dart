import 'package:flutter/material.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/entities/lesson_attempt_entity.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';

class QuizAttemptHistoryChips extends StatelessWidget {
  final List<LessonAttempt> attempts;
  final String selectedAttemptId;
  final ValueChanged<LessonAttempt> onSelected;

  const QuizAttemptHistoryChips({
    super.key,
    required this.attempts,
    required this.selectedAttemptId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF2F7),
        borderRadius: BorderRadius.circular(999),
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: attempts.length,
        separatorBuilder: (context, _) => const SizedBox(width: 6),
        itemBuilder: (context, index) {
          final attempt = attempts[index];
          final isSelected = attempt.id == selectedAttemptId;
          return GestureDetector(
            onTap: () => onSelected(attempt),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(999),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : const [],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isSelected)
                    const Padding(
                      padding: EdgeInsets.only(right: 6),
                      child: Icon(Icons.check, size: 14, color: AppColors.red),
                    ),
                  Text(
                    attempt.attemptLabel,
                    style: TextStyle(
                      color: isSelected ? AppColors.red : AppColors.slate,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
