import 'package:flutter/material.dart';

/// Soft entrance animation for cards and sections.
class FadeSlideIn extends StatelessWidget {
  final Widget child;
  final int delayMs;
  final double beginOffsetY;
  final Duration duration;

  const FadeSlideIn({
    super.key,
    required this.child,
    this.delayMs = 0,
    this.beginOffsetY = 14,
    this.duration = const Duration(milliseconds: 380),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: duration.inMilliseconds + delayMs),
      curve: Curves.easeOutCubic,
      child: child,
      builder: (context, value, child) {
        final eased = Curves.easeOut.transform(value);
        return Opacity(
          opacity: eased,
          child: Transform.translate(
            offset: Offset(0, beginOffsetY * (1 - eased)),
            child: child,
          ),
        );
      },
    );
  }
}
