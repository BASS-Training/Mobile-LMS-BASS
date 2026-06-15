import 'package:flutter/material.dart';

/// A cohesive colour identity for a single course.
///
/// Previously every course cover reused the brand-red gradient, so the home
/// rail and the catalog grid looked like a wall of identical red cards. Giving
/// each course its own deterministic colour (from a curated, contrast-safe
/// palette) makes the dashboard feel varied and premium while keeping red as
/// just one voice in the set rather than the whole choir.
class CourseAccent {
  /// Cover gradient (top-left → bottom-right). All chosen to carry white text.
  final List<Color> gradient;

  /// The representative solid colour — used for progress bars, small accents
  /// and the catalog "Beli" hint so a card reads as one colour family.
  final Color solid;

  /// A very light tint of [solid] for soft surfaces (chips, empty states).
  final Color soft;

  const CourseAccent({
    required this.gradient,
    required this.solid,
    required this.soft,
  });

  /// Curated palette — friendly, all-ages, each strong enough for white text.
  /// Index 0 is the brand red so the academy identity still appears in the mix.
  static const List<CourseAccent> _palette = [
    CourseAccent(
      gradient: [Color(0xFFE7140C), Color(0xFF9E0000)],
      solid: Color(0xFFDC0000),
      soft: Color(0xFFFFF1EF),
    ),
    CourseAccent(
      gradient: [Color(0xFF6C5CE7), Color(0xFF4B3FBE)],
      solid: Color(0xFF5B4DD6),
      soft: Color(0xFFF1EFFC),
    ),
    CourseAccent(
      gradient: [Color(0xFF12B5A5), Color(0xFF0B8C80)],
      solid: Color(0xFF0FA192),
      soft: Color(0xFFE7F8F5),
    ),
    CourseAccent(
      gradient: [Color(0xFF3B82F6), Color(0xFF2563EB)],
      solid: Color(0xFF2F74EE),
      soft: Color(0xFFEAF2FE),
    ),
    CourseAccent(
      gradient: [Color(0xFFF59E0B), Color(0xFFD97706)],
      solid: Color(0xFFE08808),
      soft: Color(0xFFFEF4E3),
    ),
    CourseAccent(
      gradient: [Color(0xFFF43F5E), Color(0xFFE11D48)],
      solid: Color(0xFFEC2C52),
      soft: Color(0xFFFEECEF),
    ),
    CourseAccent(
      gradient: [Color(0xFFA855F7), Color(0xFF7E22CE)],
      solid: Color(0xFF9333EA),
      soft: Color(0xFFF6ECFE),
    ),
    CourseAccent(
      gradient: [Color(0xFF06B6D4), Color(0xFF0891B2)],
      solid: Color(0xFF089FBE),
      soft: Color(0xFFE6F7FB),
    ),
  ];

  /// Deterministically maps a course to one palette entry by its identifier, so
  /// the same course always shows the same colour across the app.
  static CourseAccent of(String seed) {
    if (seed.isEmpty) return _palette[0];
    var hash = 0;
    for (final unit in seed.codeUnits) {
      hash = (hash * 31 + unit) & 0x7fffffff;
    }
    return _palette[hash % _palette.length];
  }
}
