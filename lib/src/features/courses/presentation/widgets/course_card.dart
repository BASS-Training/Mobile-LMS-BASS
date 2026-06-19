import 'package:flutter/material.dart';
import 'package:lms_mobile_app/src/features/courses/domain/entities/course_entity.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/widgets/course_accent.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/widgets/course_illustration_cover.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';
import 'package:lms_mobile_app/src/shared/styles/app_shadows.dart';

/// Course card used in both the horizontal "recommended" rail and the grid.
///
/// Layout: a cover (the uploaded thumbnail, or a brand-recolored illustration
/// on a soft warm wash) topped with a lesson chip and save toggle, followed by
/// the title, instructor and a small progress bar so learners can see where
/// they left off at a glance.
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
    // Each course carries its own colour identity so a list of cards reads as a
    // varied, premium set rather than a wall of identical red thumbnails.
    final accent = CourseAccent.of(course.id);
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
              Expanded(flex: 5, child: _buildCover(accent)),
              Expanded(flex: 6, child: _buildBody(accent)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCover(CourseAccent accent) {
    final thumb = course.thumbnailUrl;
    final hasThumb = thumb != null && thumb.isNotEmpty;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Base: the uploaded thumbnail when available, otherwise a default
          // illustration cover.
          if (hasThumb)
            Image.network(
              thumb,
              fit: BoxFit.cover,
              // While loading or on error, fall back to the illustration cover
              // so the card never shows a broken-image box.
              loadingBuilder: (context, child, progress) =>
                  progress == null ? child : _defaultCover(),
              errorBuilder: (_, _, _) => _defaultCover(),
            )
          else
            _defaultCover(),
          // A soft top scrim only over photos, for depth + chip legibility.
          if (hasThumb)
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x33000000), Colors.transparent],
                ),
              ),
            ),
          // Lesson count chip (white so it reads on both the wash and photos).
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
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: AppShadows.xs,
                  ),
                  child: Icon(
                    isSaved
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_outline_rounded,
                    color: accent.solid,
                    size: 18,
                  ),
                ),
              ),
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
                  boxShadow: AppShadows.xs,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lock_rounded, size: 12, color: accent.solid),
                    const SizedBox(width: 4),
                    Text(
                      'Beli',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: accent.solid,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Default cover when no thumbnail is set: a brand-recolored illustration on
  /// a soft warm wash (onboarding style). Also the loading/error fallback for
  /// real thumbnails.
  Widget _defaultCover() => CourseIllustrationCover(seed: course.id);

  /// Returns a human-friendly duration, or null when the data is empty/zero
  /// (so we never render an ugly "0 min").
  String? get _durationLabel {
    final d = course.duration.trim();
    if (d.isEmpty) return null;
    if (d.startsWith('0') || d == '0 min' || d == '0min') return null;
    return d;
  }

  Widget _buildBody(CourseAccent accent) {
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
                style: TextStyle(
                  fontSize: 14.5,
                  height: 1.2,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
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
                      style: TextStyle(
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
            _CatalogHint(duration: duration, accent: accent)
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
                    valueColor: AlwaysStoppedAnimation<Color>(accent.solid),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${course.completedLessons}/${course.totalLessons} lesson selesai',
                  style: TextStyle(
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
                  style: TextStyle(
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        boxShadow: AppShadows.xs,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

/// Footer shown on catalog (unowned) cards instead of a progress bar.
class _CatalogHint extends StatelessWidget {
  final String? duration;
  final CourseAccent accent;

  const _CatalogHint({required this.duration, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.shopping_bag_rounded, size: 13, color: accent.solid),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            duration != null ? 'Beli · $duration' : 'Beli untuk akses',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: accent.solid,
            ),
          ),
        ),
      ],
    );
  }
}
