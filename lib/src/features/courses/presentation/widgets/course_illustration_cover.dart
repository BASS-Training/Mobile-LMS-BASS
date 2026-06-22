import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// One default-cover design: a brand-recolored (unDraw-style) illustration over
/// a soft warm wash, matching the onboarding look. Each illustration is paired
/// with a wash chosen to complement its red/navy palette.
class _CoverArt {
  final String asset;
  final List<Color> wash;

  const _CoverArt(this.asset, this.wash);
}

const List<_CoverArt> _covers = [
  _CoverArt(
    'assets/illustrations/course_books.svg',
    [Color(0xFFFFE3DA), Color(0xFFFFC9BC)],
  ),
  _CoverArt(
    'assets/illustrations/course_graduation.svg',
    [Color(0xFFFFEDD5), Color(0xFFFFD8B7)],
  ),
  _CoverArt(
    'assets/illustrations/course_video.svg',
    [Color(0xFFFFE0E0), Color(0xFFFFC7CA)],
  ),
];

/// Deterministically map a course to one of the cover designs from its id, so
/// the same course always shows the same illustration while the catalog as a
/// whole gets a pleasant, varied mix.
int _coverIndex(String seed) {
  if (seed.isEmpty) return 0;
  var hash = 7;
  for (final unit in seed.codeUnits) {
    hash = (hash * 131 + unit) & 0x7fffffff;
  }
  return hash % _covers.length;
}

/// The soft warm wash chosen for a course — for callers that want to lay the
/// illustration out themselves (e.g. the detail header) but keep the same bg.
List<Color> courseCoverWash(String seed) => _covers[_coverIndex(seed)].wash;

/// The illustration asset chosen for a course.
String courseCoverAsset(String seed) => _covers[_coverIndex(seed)].asset;

/// The default course cover used when no thumbnail is uploaded (and as the
/// loading/error fallback for real thumbnails).
class CourseIllustrationCover extends StatelessWidget {
  final String seed;
  final EdgeInsets padding;

  const CourseIllustrationCover({
    super.key,
    required this.seed,
    this.padding = const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
  });

  @override
  Widget build(BuildContext context) {
    final art = _covers[_coverIndex(seed)];
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: art.wash,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: padding,
        child: SvgPicture.asset(art.asset, fit: BoxFit.contain),
      ),
    );
  }
}
