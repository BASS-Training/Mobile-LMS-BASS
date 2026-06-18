import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A lightweight, dependency-free confetti burst painted with [CustomPaint].
///
/// Drop it on top of any content (e.g. inside a [Stack] behind a dialog card)
/// and it animates a one-shot fall of colourful pieces. Self-contained: it
/// generates its own pieces and drives a single [AnimationController].
class ConfettiOverlay extends StatefulWidget {
  final List<Color> colors;
  final int pieceCount;
  final Duration duration;

  const ConfettiOverlay({
    super.key,
    required this.colors,
    this.pieceCount = 80,
    this.duration = const Duration(milliseconds: 2600),
  });

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Piece> _pieces;

  @override
  void initState() {
    super.initState();
    final rnd = math.Random();
    _pieces = List.generate(widget.pieceCount, (_) => _Piece.random(rnd, widget.colors));
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => CustomPaint(
          painter: _ConfettiPainter(_pieces, _controller.value),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _Piece {
  final double x; // 0..1 horizontal start
  final double startY; // -0.2..0.1 (above the top)
  final double fall; // how far down it travels (0.9..1.3)
  final double drift; // horizontal sway amplitude
  final double phase; // sway phase offset
  final double rotations; // total turns over the animation
  final double sizePx;
  final Color color;
  final bool circle;

  const _Piece({
    required this.x,
    required this.startY,
    required this.fall,
    required this.drift,
    required this.phase,
    required this.rotations,
    required this.sizePx,
    required this.color,
    required this.circle,
  });

  factory _Piece.random(math.Random r, List<Color> colors) {
    return _Piece(
      x: r.nextDouble(),
      startY: -0.2 + r.nextDouble() * 0.3,
      fall: 0.9 + r.nextDouble() * 0.5,
      drift: (r.nextDouble() - 0.5) * 0.3,
      phase: r.nextDouble() * math.pi * 2,
      rotations: 1 + r.nextDouble() * 4,
      sizePx: 6 + r.nextDouble() * 7,
      color: colors[r.nextInt(colors.length)],
      circle: r.nextBool(),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  final List<_Piece> pieces;
  final double t; // 0..1

  _ConfettiPainter(this.pieces, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    // Ease-out so pieces decelerate as they fall, and fade near the end.
    final eased = 1 - math.pow(1 - t, 2).toDouble();
    final fade = t < 0.8 ? 1.0 : (1 - (t - 0.8) / 0.2).clamp(0.0, 1.0);
    final paint = Paint()..style = PaintingStyle.fill;

    for (final p in pieces) {
      final y = (p.startY + eased * p.fall) * size.height;
      if (y < -20 || y > size.height + 20) continue;
      final sway = math.sin(eased * math.pi * 3 + p.phase) * p.drift;
      final x = (p.x + sway) * size.width;
      final angle = eased * p.rotations * math.pi * 2;

      paint.color = p.color.withValues(alpha: fade);
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(angle);
      if (p.circle) {
        canvas.drawCircle(Offset.zero, p.sizePx / 2, paint);
      } else {
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset.zero,
            width: p.sizePx,
            height: p.sizePx * 0.55,
          ),
          paint,
        );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter old) => old.t != t;
}
