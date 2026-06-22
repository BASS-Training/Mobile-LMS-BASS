import 'package:flutter/material.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';

class CourseProgressIndicator extends StatelessWidget {
  final double progress; // 0.0 to 100.0
  final String label;
  final bool showPercentage;

  const CourseProgressIndicator({
    super.key,
    required this.progress,
    required this.label,
    this.showPercentage = true,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (progress / 100).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            if (showPercentage)
              Text(
                '${progress.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.brandText,
                ),
              ),
          ],
        ),
        SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 8,
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Stack(
              children: [
                Container(
                  height: 8,
                  width: double.infinity,
                  color: AppColors.surfaceMuted,
                ),
                FractionallySizedBox(
                  widthFactor: percentage,
                  child: Container(
                    height: 8,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.brandPrimaryLight,
                          AppColors.brandPrimary,
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

