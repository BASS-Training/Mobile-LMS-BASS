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
                fontWeight: FontWeight.w600,
                color: AppColors.charcoal,
              ),
            ),
            if (showPercentage)
              Text(
                '${progress.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.violet,
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
              color: AppColors.pearl,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Stack(
              children: [
                Container(
                  height: 8,
                  width: double.infinity,
                  color: AppColors.pearl,
                ),
                 FractionallySizedBox(
                   widthFactor: percentage,
                   child: Container(
                     height: 8,
                     decoration: BoxDecoration(
                       gradient: LinearGradient(
                         colors: [AppColors.violet, AppColors.azure],
                         begin: Alignment.centerLeft,
                         end: Alignment.centerRight,
                       ),
                       borderRadius: BorderRadius.circular(8),
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

