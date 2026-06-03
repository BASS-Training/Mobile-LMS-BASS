import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Centralized elevation tokens.
///
/// Soft, low-opacity shadows give the UI a clean, modern depth instead of the
/// harsh dark drop-shadows used previously. Reuse these everywhere a surface
/// needs lift so the whole app shares one consistent visual language.
class AppShadows {
  const AppShadows._();

  /// Subtle lift for list tiles and small chips.
  static List<BoxShadow> get xs => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  /// Default elevation for cards and panels.
  static List<BoxShadow> get sm => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];

  /// Stronger elevation for hero cards and floating surfaces.
  static List<BoxShadow> get md => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.07),
      blurRadius: 24,
      offset: const Offset(0, 10),
    ),
  ];

  /// Colored glow used to make brand-colored surfaces feel elevated.
  static List<BoxShadow> brand(Color color, {double opacity = 0.28}) => [
    BoxShadow(
      color: color.withValues(alpha: opacity),
      blurRadius: 22,
      offset: const Offset(0, 12),
    ),
  ];

  /// Glow tuned for the primary brand color.
  static List<BoxShadow> get brandPrimary => brand(AppColors.brandPrimary);
}
