import 'package:flutter/material.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';
import '../../domain/entities/course_entity.dart';

class CourseInfoCards extends StatelessWidget {
  final CourseEntity course;

  const CourseInfoCards({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildCard(
          icon: Icons.person,
          iconColor: AppColors.violet,
          label: 'Instructor',
          value: course.instructor,
        ),
        const SizedBox(width: 12),
        _buildCard(
          icon: Icons.timer,
          iconColor: AppColors.azure,
          label: 'Duration',
          value: course.duration,
        ),
      ],
    );
  }

  Widget _buildCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: AppColors.slate),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.charcoal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
