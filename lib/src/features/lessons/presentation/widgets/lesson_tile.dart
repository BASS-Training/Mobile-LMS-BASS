import 'package:flutter/material.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/entities/lesson_entity.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';
import 'package:lms_mobile_app/src/shared/widgets/press_scale.dart';

class LessonTile extends StatelessWidget {
  final LessonEntity lesson;
  final int index;
  final VoidCallback onTap;
  final Function(bool)? onCompletionChanged;

  const LessonTile({
    super.key,
    required this.lesson,
    required this.index,
    required this.onTap,
    this.onCompletionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PressScale(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 8),
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: lesson.isCompleted
                  ? AppColors.emerald
                  : AppColors.borderDefault,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Lesson number or checkbox
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: lesson.isCompleted
                        ? [
                            AppColors.emerald,
                            AppColors.emerald.withValues(alpha: 0.7),
                          ]
                        : [AppColors.red, AppColors.tomato],
                  ),
                ),
                child: Center(
                  child: lesson.isCompleted
                      ? Icon(Icons.check, color: Colors.white, size: 20)
                      : Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
              SizedBox(width: 12),
              // Lesson info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lesson.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.charcoal,
                        decoration: lesson.isCompleted
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          size: 12,
                          color: AppColors.silver,
                        ),
                        SizedBox(width: 4),
                        Text(
                          lesson.duration,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.silver,
                          ),
                        ),
                        if (lesson.isCompleted)
                          Row(
                            children: [
                              SizedBox(width: 8),
                              Icon(
                                Icons.check_circle,
                                size: 12,
                                color: AppColors.emerald,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Completed',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.emerald,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              // Checkbox
              GestureDetector(
                onTap: () {
                  onCompletionChanged?.call(!lesson.isCompleted);
                },
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: lesson.isCompleted
                          ? AppColors.emerald
                          : AppColors.pearl,
                      width: 2,
                    ),
                    color: lesson.isCompleted
                        ? AppColors.emerald
                        : Colors.transparent,
                  ),
                  child: lesson.isCompleted
                      ? Icon(Icons.check, color: Colors.white, size: 14)
                      : SizedBox(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
