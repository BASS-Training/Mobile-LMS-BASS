import 'package:flutter/material.dart';

/// Text that counts up from 0 to [value] when it first appears (and re-animates
/// from the previous value whenever [value] changes). Used for dashboard
/// metrics so numbers feel alive instead of just popping in.
class AnimatedCount extends StatelessWidget {
  final int value;
  final TextStyle? style;
  final Duration duration;

  /// Formats the animating integer into the displayed string (e.g. add a `%`
  /// suffix or a `/total` denominator).
  final String Function(int)? formatter;

  const AnimatedCount({
    super.key,
    required this.value,
    this.style,
    this.duration = const Duration(milliseconds: 900),
    this.formatter,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: value),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, current, _) {
        return Text(
          formatter?.call(current) ?? '$current',
          style: style,
        );
      },
    );
  }
}
