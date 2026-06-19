import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/widgets/course_accent.dart';
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
    // Match the course's own colour identity (same as its card) so navigating
    // from a card into the detail screen feels visually continuous.
    final accent = CourseAccent.of(course.id);
    final thumb = course.thumbnailUrl;
    final hasThumb = thumb != null && thumb.isNotEmpty;
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
      child: Stack(
        children: [
          // Background: the uploaded cover image, or the brand-accent gradient.
          Positioned.fill(
            child: hasThumb
                ? Image.network(
                    thumb,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) =>
                        progress == null ? child : _gradientBg(accent),
                    errorBuilder: (_, _, _) => _gradientBg(accent),
                  )
                : _gradientBg(accent),
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
          _buildContent(context, course, accent, hasThumb),
        ],
      ),
    );
  }

  Widget _gradientBg(CourseAccent accent) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: accent.gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    CourseEntity course,
    CourseAccent accent,
    bool hasThumb,
  ) {
    return SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _CircleAction(
                    icon: Icons.arrow_back_rounded,
                    onTap: () => Navigator.pop(context),
                  ),
                  _CircleAction(
                    icon: _isSaved
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_outline_rounded,
                    onTap: _onToggleSave,
                  ),
                ],
              ),
              // Emoji medallion only on the default cover; over a real photo it
              // would just clutter the image.
              if (!hasThumb) ...[
                const SizedBox(height: 12),
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.25),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child:
                        Text(course.icon, style: const TextStyle(fontSize: 46)),
                  ),
                ),
              ] else
                const SizedBox(height: 56),
              const SizedBox(height: 18),
              Text(
                course.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
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
                  ),
                  // Tampilkan chip durasi hanya bila bermakna (sembunyikan "0 min").
                  if (_hasMeaningfulDuration(course.duration)) ...[
                    const SizedBox(width: 10),
                    _MetaChip(
                      icon: Icons.schedule_rounded,
                      label: course.duration,
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

  const _CircleAction({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
