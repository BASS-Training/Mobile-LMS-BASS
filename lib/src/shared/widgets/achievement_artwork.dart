import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:lms_mobile_app/src/shared/widgets/intro_art_palette.dart';

/// Asset-free, coloured flat-vector illustration of achievement & progress,
/// painted with [CustomPaint].
///
/// Third onboarding slide. A golden award medal with ribbons above a rising bar
/// chart and an upward trend arrow — representing progress tracking and
/// certificates in the shared [IntroArt] palette.
class AchievementArtwork extends StatelessWidget {
  final double height;

  const AchievementArtwork({super.key, this.height = 240});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: CustomPaint(
        painter: _AchievementPainter(),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _AchievementPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w * 0.5;
    final fill = Paint()..style = PaintingStyle.fill;

    // --- Soft glow ---
    final glowRect = Rect.fromCircle(center: Offset(cx, h * 0.42), radius: w * 0.46);
    canvas.drawRect(
      glowRect,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.white.withValues(alpha: 0.24),
            Colors.white.withValues(alpha: 0.0),
          ],
        ).createShader(glowRect),
    );

    // --- Baseline ---
    final baseY = h * 0.84;
    canvas.drawLine(
      Offset(cx - w * 0.30, baseY),
      Offset(cx + w * 0.30, baseY),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = w * 0.012
        ..color = IntroArt.cream.withValues(alpha: 0.6),
    );

    // --- Rising bars (progress) ---
    _bar(canvas, w, cx - w * 0.19, baseY, h * 0.16, IntroArt.teal);
    _bar(canvas, w, cx - w * 0.005, baseY, h * 0.24, IntroArt.coral);
    _bar(canvas, w, cx + w * 0.18, baseY, h * 0.32, IntroArt.gold);

    // --- Upward trend arrow ---
    final trend = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = w * 0.014
      ..color = IntroArt.cream;
    final p1 = Offset(cx - w * 0.22, baseY - h * 0.13);
    final p2 = Offset(cx + w * 0.22, baseY - h * 0.30);
    canvas.drawLine(p1, p2, trend);
    canvas.drawLine(p2, Offset(p2.dx - w * 0.052, p2.dy + w * 0.012), trend);
    canvas.drawLine(p2, Offset(p2.dx - w * 0.012, p2.dy + w * 0.056), trend);

    // --- Ribbon tails (behind the medal) ---
    final medal = Offset(cx, h * 0.30);
    final mr = w * 0.135;
    fill.color = IntroArt.coral;
    canvas.drawPath(_ribbon(medal, mr, left: true), fill);
    fill.color = IntroArt.coralDeep;
    canvas.drawPath(_ribbon(medal, mr, left: false), fill);

    // --- Medal disc ---
    fill.color = IntroArt.gold;
    canvas.drawCircle(medal, mr, fill);
    // Rim.
    canvas.drawCircle(
      medal,
      mr * 0.86,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = mr * 0.12
        ..color = IntroArt.goldDeep,
    );
    // Inner face.
    fill.color = IntroArt.cream;
    canvas.drawCircle(medal, mr * 0.66, fill);

    // --- Star at the centre ---
    fill.color = IntroArt.goldDeep;
    canvas.drawPath(_star(medal, mr * 0.52, mr * 0.22), fill);

    // --- Sparkles ---
    _sparkle(canvas, Offset(cx + w * 0.30, h * 0.13), w * 0.032, IntroArt.gold);
    _sparkle(canvas, Offset(cx - w * 0.28, h * 0.16), w * 0.020, IntroArt.cream);
  }

  /// One progress bar grounded at [baseY] with the given [barHeight].
  void _bar(Canvas canvas, double w, double cx, double baseY, double barHeight, Color color) {
    final bw = w * 0.115;
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(cx - bw / 2, baseY - barHeight, bw, barHeight),
        topLeft: Radius.circular(w * 0.028),
        topRight: Radius.circular(w * 0.028),
      ),
      Paint()
        ..style = PaintingStyle.fill
        ..color = color,
    );
  }

  /// A ribbon tail hanging from the bottom of the medal.
  Path _ribbon(Offset medal, double mr, {required bool left}) {
    final d = left ? -1.0 : 1.0;
    return Path()
      ..moveTo(medal.dx + d * mr * 0.18, medal.dy + mr * 0.78)
      ..lineTo(medal.dx + d * mr * 0.80, medal.dy + mr * 0.55)
      ..lineTo(medal.dx + d * mr * 0.96, medal.dy + mr * 1.62)
      ..lineTo(medal.dx + d * mr * 0.55, medal.dy + mr * 1.42)
      ..lineTo(medal.dx + d * mr * 0.30, medal.dy + mr * 1.66)
      ..close();
  }

  /// Five-point star centred at [c].
  Path _star(Offset c, double r, double inner) {
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final outerA = -math.pi / 2 + i * 2 * math.pi / 5;
      final ox = c.dx + r * math.cos(outerA);
      final oy = c.dy + r * math.sin(outerA);
      if (i == 0) {
        path.moveTo(ox, oy);
      } else {
        path.lineTo(ox, oy);
      }
      final innerA = outerA + math.pi / 5;
      path.lineTo(c.dx + inner * math.cos(innerA), c.dy + inner * math.sin(innerA));
    }
    return path..close();
  }

  /// Four-point sparkle/star.
  void _sparkle(Canvas canvas, Offset o, double r, Color color) {
    final p = Paint()
      ..style = PaintingStyle.fill
      ..color = color;
    final path = Path()
      ..moveTo(o.dx, o.dy - r)
      ..quadraticBezierTo(o.dx + r * 0.2, o.dy - r * 0.2, o.dx + r, o.dy)
      ..quadraticBezierTo(o.dx + r * 0.2, o.dy + r * 0.2, o.dx, o.dy + r)
      ..quadraticBezierTo(o.dx - r * 0.2, o.dy + r * 0.2, o.dx - r, o.dy)
      ..quadraticBezierTo(o.dx - r * 0.2, o.dy - r * 0.2, o.dx, o.dy - r)
      ..close();
    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(covariant _AchievementPainter oldDelegate) => false;
}
