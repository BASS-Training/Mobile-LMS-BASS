import 'package:flutter/material.dart';
import 'package:lms_mobile_app/src/features/courses/domain/entities/course_entity.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';
import 'package:lms_mobile_app/src/shared/styles/app_shadows.dart';

/// Course card used in both the horizontal "recommended" rail and the grid.
///
/// Layout: a compact brand-gradient cover with the course emoji, a save
/// toggle and a lesson badge, followed by the title, instructor and a small
/// progress bar so learners can see where they left off at a glance.
class CourseCard extends StatelessWidget {
  final CourseEntity course;
  final VoidCallback onTap;
  final VoidCallback? onSavePressed;
  final bool isSaved;

  const CourseCard({
    super.key,
    required this.course,
    required this.onTap,
    this.onSavePressed,
    this.isSaved = false,
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
            borderRadius: BorderRadius.circular(22),
            color: AppColors.surface,
            border: Border.all(color: AppColors.borderSubtle),
            boxShadow: AppShadows.sm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 5, child: _buildCover()),
              Expanded(flex: 6, child: _buildBody()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCover() {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: AppColors.brandGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
          ),
        ),
        Positioned(
          right: -16,
          top: -14,
          child: Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.12),
            ),
          ),
        ),
        // Lesson count badge
        Positioned(
          left: 12,
          top: 12,
          child: _Pill(
            label: course.totalLessons > 0
                ? '${course.totalLessons} lesson'
                : 'Course',
          ),
        ),
        // Save toggle
        if (onSavePressed != null)
          Positioned(
            right: 10,
            top: 10,
            child: GestureDetector(
              onTap: onSavePressed,
              child: Container(
                padding: const EdgeInsets.all(7),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isSaved ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                  color: AppColors.brandPrimary,
                  size: 18,
                ),
              ),
            ),
          ),
        // Course emoji
        Positioned(
          left: 14,
          bottom: 12,
          child: Text(course.icon, style: const TextStyle(fontSize: 38)),
        ),
        // Locked / catalog badge for courses the user does not own yet.
        if (!course.isOwned)
          Positioned(
            right: 12,
            bottom: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.lock_rounded, size: 12, color: AppColors.brandPrimary),
                  SizedBox(width: 4),
                  Text(
                    'Beli',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.brandPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  /// Returns a human-friendly duration, or null when the data is empty/zero
  /// (so we never render an ugly "0 min").
  String? get _durationLabel {
    final d = course.duration.trim();
    if (d.isEmpty) return null;
    if (d.startsWith('0') || d == '0 min' || d == '0min') return null;
    return d;
  }

  Widget _buildBody() {
    final progress = course.progressPercentage / 100.0;
    final hasProgress = course.isOwned && course.totalLessons > 0;
    final duration = _durationLabel;

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                course.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14.5,
                  height: 1.2,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.person_rounded,
                    size: 13,
                    color: AppColors.textTertiary,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      course.instructor,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (!course.isOwned)
            _CatalogHint(duration: duration)
          else if (hasProgress)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    minHeight: 5,
                    backgroundColor: AppColors.surfaceMuted,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.brandPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${course.completedLessons}/${course.totalLessons} lesson selesai',
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            )
          else
            Row(
              children: [
                Icon(
                  duration != null
                      ? Icons.schedule_rounded
                      : Icons.menu_book_rounded,
                  size: 13,
                  color: AppColors.textTertiary,
                ),
                const SizedBox(width: 4),
                Text(
                  duration ?? '${course.totalLessons} lesson',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;

  const _Pill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}

/// Footer shown on catalog (unowned) cards instead of a progress bar.
class _CatalogHint extends StatelessWidget {
  final String? duration;

  const _CatalogHint({required this.duration});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.shopping_bag_rounded,
          size: 13,
          color: AppColors.brandPrimary,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            duration != null ? 'Beli · $duration' : 'Beli untuk akses',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.brandPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
