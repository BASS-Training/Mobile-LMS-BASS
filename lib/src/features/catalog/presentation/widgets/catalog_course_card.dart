import 'package:flutter/material.dart';

import '../../../courses/presentation/widgets/course_illustration_cover.dart';
import '../../../../shared/styles/app_colors.dart';
import '../../../../shared/styles/app_shadows.dart';
import '../../domain/entities/catalog_course_entity.dart';

class CatalogCourseCard extends StatelessWidget {
  final CatalogCourseEntity course;
  final VoidCallback onTap;

  const CatalogCourseCard({
    super.key,
    required this.course,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.borderSubtle),
            boxShadow: AppShadows.sm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 5, child: _cover()),
              Expanded(flex: 6, child: _body()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cover() {
    final thumbnail = course.thumbnailUrl;
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (thumbnail != null && thumbnail.isNotEmpty)
            Image.network(
              thumbnail,
              fit: BoxFit.cover,
              loadingBuilder: (_, child, progress) => progress == null
                  ? child
                  : CourseIllustrationCover(seed: course.id),
              errorBuilder: (_, _, _) =>
                  CourseIllustrationCover(seed: course.id),
            )
          else
            CourseIllustrationCover(seed: course.id),
          Positioned(
            top: 10,
            left: 10,
            child: _Badge(
              label: '${course.lessonCount} materi',
              color: AppColors.textPrimary,
              backgroundColor: Colors.white,
            ),
          ),
          if (course.isFree || course.isEnrolled)
            Positioned(
              right: 10,
              bottom: 10,
              child: _Badge(
                label: course.isEnrolled ? 'Sudah diikuti' : course.priceLabel,
                color: course.isEnrolled
                    ? AppColors.successText
                    : AppColors.brandText,
                backgroundColor: course.isEnrolled
                    ? AppColors.successSurface
                    : AppColors.brandSurface,
              ),
            ),
        ],
      ),
    );
  }

  Widget _body() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            course.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w800,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            course.instructor,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 11.5),
          ),
          const Spacer(),
          Row(
            children: [
              Icon(
                Icons.payments_outlined,
                size: 14,
                color: course.isFree
                    ? AppColors.brandText
                    : AppColors.textTertiary,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  course.priceLabel,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: course.isFree
                        ? AppColors.brandText
                        : AppColors.textSecondary,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_rounded,
                size: 16,
                color: AppColors.brandText,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  final Color backgroundColor;

  const _Badge({
    required this.label,
    required this.color,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
        boxShadow: AppShadows.xs,
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
