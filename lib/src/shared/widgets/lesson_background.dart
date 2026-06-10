import 'package:flutter/material.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';

/// Decorative background used by text, essay, and image lesson screens.
///
/// Renders a soft blue-grey gradient with two blurred radial-gradient orbs
/// positioned at the top-right and center-left. Wrap the screen body inside
/// this widget instead of duplicating the same Stack + Positioned setup.
class LessonBackground extends StatelessWidget {
  final Widget child;
  final Color orbColor;

  const LessonBackground({
    super.key,
    required this.child,
    this.orbColor = AppColors.brandPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.surface, AppColors.background],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        IgnorePointer(
          child: Stack(
            children: [
              Positioned(
                top: -70,
                right: -40,
                child: _orb(180, orbColor, 0.18),
              ),
              Positioned(
                top: 150,
                left: -60,
                child: _orb(150, orbColor, 0.14),
              ),
            ],
          ),
        ),
        child,
      ],
    );
  }

  static Widget _orb(double size, Color color, double alpha) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withValues(alpha: alpha), Colors.transparent],
        ),
      ),
    );
  }
}
