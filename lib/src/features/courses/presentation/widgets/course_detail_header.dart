import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/widgets/course_illustration_cover.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';
import 'package:lms_mobile_app/src/shared/styles/app_shadows.dart';
import '../../domain/entities/course_entity.dart';
import '../bloc/course/course_bloc.dart';
import '../bloc/course/course_event.dart';

/// Apakah string durasi layak ditampilkan. Mengembalikan `false` untuk durasi
/// kosong, "-", atau yang seluruh angkanya nol (mis. "0 min") agar chip durasi
/// tidak menampilkan "0 min" yang janggal.
bool _hasMeaningfulDuration(String duration) {
  final s = duration.trim().toLowerCase();
  if (s.isEmpty || s == '-') return false;
  final numbers = RegExp(r'\d+').allMatches(s).map((m) => int.parse(m[0]!));
  if (numbers.isEmpty) return s != '0';
  return numbers.any((n) => n > 0);
}

/// Hero header for the course detail screen: a brand-gradient panel with the
/// course emoji, title and a compact meta row (lessons · duration), plus back
/// and save actions.
class CourseDetailHeader extends StatefulWidget {
  final CourseEntity course;

  const CourseDetailHeader({super.key, required this.course});

  @override
  State<CourseDetailHeader> createState() => _CourseDetailHeaderState();
}

class _CourseDetailHeaderState extends State<CourseDetailHeader> {
  late bool _isSaved = widget.course.isSaved;

  @override
  void didUpdateWidget(covariant CourseDetailHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Selaraskan dengan data terbaru dari BLoC (mis. setelah refresh server).
    if (widget.course.isSaved != oldWidget.course.isSaved) {
      _isSaved = widget.course.isSaved;
    }
  }

  void _onToggleSave() {
    // Optimistik: ubah ikon seketika untuk respons instan.
    setState(() => _isSaved = !_isSaved);

    context.read<CourseBloc>().add(
      ToggleSaveCourseEvent(courseId: widget.course.id),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            _isSaved
                ? 'Kursus disimpan ke koleksi'
                : 'Kursus dihapus dari koleksi',
          ),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final course = widget.course;
    final thumb = course.thumbnailUrl;
    final hasThumb = thumb != null && thumb.isNotEmpty;
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
      child: Stack(
        children: [
          // Background: the uploaded cover photo, or the soft warm wash that
          // matches this course's default illustration.
          Positioned.fill(
            child: hasThumb
                ? Image.network(
                    thumb,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) => progress == null
                        ? child
                        : CourseIllustrationCover(seed: course.id),
                    errorBuilder: (_, _, _) =>
                        CourseIllustrationCover(seed: course.id),
                  )
                : DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: courseCoverWash(course.id),
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
          ),
          // Dark scrim over photos so the white title/actions stay legible.
          if (hasThumb)
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.35),
                      Colors.black.withValues(alpha: 0.55),
                    ],
                  ),
                ),
              ),
            ),
          _buildContent(context, course, hasThumb),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, CourseEntity course, bool hasThumb) {
    // On the light illustration cover, use dark text + white solid actions; on a
    // (dark-scrimmed) photo, keep the original white-on-image treatment.
    final onLight = !hasThumb;
    final titleColor = onLight ? AppColors.textPrimary : Colors.white;

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 26),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _CircleAction(
                  icon: Icons.arrow_back_rounded,
                  light: onLight,
                  onTap: () => Navigator.pop(context),
                ),
                _CircleAction(
                  icon: _isSaved
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_outline_rounded,
                  light: onLight,
                  onTap: _onToggleSave,
                ),
              ],
            ),
            // Default cover shows the course illustration here; a real photo
            // already fills the background, so we just keep the spacing.
            if (onLight) ...[
              const SizedBox(height: 6),
              SizedBox(
                height: 108,
                child: SvgPicture.asset(
                  courseCoverAsset(course.id),
                  fit: BoxFit.contain,
                ),
              ),
            ] else
              const SizedBox(height: 56),
            const SizedBox(height: 16),
            Text(
              course.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: titleColor,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _MetaChip(
                  icon: Icons.play_lesson_rounded,
                  label: '${course.totalLessons} lesson',
                  light: onLight,
                ),
                // Tampilkan chip durasi hanya bila bermakna (sembunyikan "0 min").
                if (_hasMeaningfulDuration(course.duration)) ...[
                  const SizedBox(width: 10),
                  _MetaChip(
                    icon: Icons.schedule_rounded,
                    label: course.duration,
                    light: onLight,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool light;

  const _CircleAction({
    required this.icon,
    required this.onTap,
    this.light = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: light ? Colors.white : Colors.white.withValues(alpha: 0.18),
          shape: BoxShape.circle,
          border: light
              ? null
              : Border.all(color: Colors.white.withValues(alpha: 0.22)),
          boxShadow: light ? AppShadows.xs : null,
        ),
        child: Icon(
          icon,
          color: light ? AppColors.textPrimary : Colors.white,
          size: 22,
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool light;

  const _MetaChip({
    required this.icon,
    required this.label,
    this.light = false,
  });

  @override
  Widget build(BuildContext context) {
    final fg = light ? AppColors.textPrimary : Colors.white;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: light ? Colors.white : Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
        border: light
            ? null
            : Border.all(color: Colors.white.withValues(alpha: 0.2)),
        boxShadow: light ? AppShadows.xs : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: fg, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}
