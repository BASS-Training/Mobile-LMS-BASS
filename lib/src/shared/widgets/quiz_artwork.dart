import 'package:flutter/material.dart';

import 'package:lms_mobile_app/src/shared/widgets/intro_art_palette.dart';

/// Asset-free, coloured flat-vector illustration of a quiz / practice checklist,
/// painted with [CustomPaint].
///
/// Second onboarding slide. A clipboard with ticked checklist rows, a pencil,
/// and a floating "correct" badge — representing the app's interactive quizzes
/// and exercises in the shared [IntroArt] palette.
class QuizArtwork extends StatelessWidget {
  final double height;

  const QuizArtwork({super.key, this.height = 240});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: CustomPaint(
        painter: _QuizPainter(),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _QuizPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w * 0.5;
    final fill = Paint()..style = PaintingStyle.fill;

    // --- Soft glow ---
    final glowRect = Rect.fromCircle(center: Offset(cx, h * 0.50), radius: w * 0.46);
    canvas.drawRect(
      glowRect,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.white.withValues(alpha: 0.22),
            Colors.white.withValues(alpha: 0.0),
          ],
        ).createShader(glowRect),
    );

    // --- Clipboard backing (teal board) ---
    fill.color = IntroArt.tealDeep;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, h * 0.555), width: w * 0.50, height: h * 0.58),
        Radius.circular(w * 0.055),
      ),
      fill,
    );

    // --- Paper sheet ---
    fill.color = IntroArt.paper;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, h * 0.565), width: w * 0.44, height: h * 0.52),
        Radius.circular(w * 0.04),
      ),
      fill,
    );

    // --- Clip at the top ---
    fill.color = IntroArt.gold;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, h * 0.275), width: w * 0.19, height: h * 0.075),
        Radius.circular(w * 0.03),
      ),
      fill,
    );
    fill.color = IntroArt.goldDeep;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, h * 0.255), width: w * 0.085, height: h * 0.045),
        Radius.circular(w * 0.02),
      ),
      fill,
    );

    // --- Checklist rows ---
    _row(canvas, w, h, cx, h * 0.44, IntroArt.teal);
    _row(canvas, w, h, cx, h * 0.565, IntroArt.coral);
    _row(canvas, w, h, cx, h * 0.69, IntroArt.gold);

    // --- Pencil ---
    _pencil(canvas, w, h, Offset(cx + w * 0.245, h * 0.60), -0.62);

    // --- Floating "correct" badge ---
    final badge = Offset(cx + w * 0.275, h * 0.205);
    fill.color = IntroArt.gold;
    canvas.drawCircle(badge, w * 0.072, fill);
    fill.color = IntroArt.goldDeep;
    canvas.drawCircle(badge, w * 0.072, Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.012
      ..color = IntroArt.goldDeep);
    final tick = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = w * 0.016
      ..color = Colors.white;
    canvas.drawPath(
      Path()
        ..moveTo(badge.dx - w * 0.032, badge.dy + w * 0.002)
        ..lineTo(badge.dx - w * 0.006, badge.dy + w * 0.028)
        ..lineTo(badge.dx + w * 0.038, badge.dy - w * 0.028),
      tick,
    );

    // --- Sparkles ---
    _sparkle(canvas, Offset(cx - w * 0.285, h * 0.30), w * 0.032, IntroArt.gold);
    _sparkle(canvas, Offset(cx - w * 0.31, h * 0.55), w * 0.018, IntroArt.cream);
  }

  /// One checklist row: a coloured ticked checkbox plus a "text" bar.
  void _row(Canvas canvas, double w, double h, double cx, double y, Color boxColor) {
    final s = w * 0.078;
    final boxCenter = Offset(cx - w * 0.15, y);

    final box = Paint()
      ..style = PaintingStyle.fill
      ..color = boxColor;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: boxCenter, width: s, height: s),
        Radius.circular(w * 0.018),
      ),
      box,
    );

    final tick = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = w * 0.013
      ..color = Colors.white;
    canvas.drawPath(
      Path()
        ..moveTo(boxCenter.dx - s * 0.26, boxCenter.dy + s * 0.02)
        ..lineTo(boxCenter.dx - s * 0.04, boxCenter.dy + s * 0.24)
        ..lineTo(boxCenter.dx + s * 0.30, boxCenter.dy - s * 0.24),
      tick,
    );

    final bar = Paint()
      ..style = PaintingStyle.fill
      ..color = IntroArt.ink.withValues(alpha: 0.22);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx + w * 0.065, y), width: w * 0.20, height: h * 0.024),
        Radius.circular(h * 0.012),
      ),
      bar,
    );
  }

  /// A pencil drawn around [pivot] and rotated by [angle] radians.
  void _pencil(Canvas canvas, double w, double h, Offset pivot, double angle) {
    canvas.save();
    canvas.translate(pivot.dx, pivot.dy);
    canvas.rotate(angle);

    final pw = w * 0.06;
    final top = -h * 0.17;
    final bottom = h * 0.17;
    final fill = Paint()..style = PaintingStyle.fill;

    // Eraser.
    fill.color = IntroArt.coral;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(-pw / 2, top, pw / 2, top + h * 0.04),
        Radius.circular(pw * 0.4),
      ),
      fill,
    );
    // Metal band.
    fill.color = IntroArt.creamDeep;
    canvas.drawRect(Rect.fromLTRB(-pw / 2, top + h * 0.04, pw / 2, top + h * 0.06), fill);
    // Body.
    fill.color = IntroArt.gold;
    canvas.drawRect(Rect.fromLTRB(-pw / 2, top + h * 0.06, pw / 2, bottom - h * 0.06), fill);
    // Wooden tip.
    fill.color = IntroArt.skin;
    canvas.drawPath(
      Path()
        ..moveTo(-pw / 2, bottom - h * 0.06)
        ..lineTo(pw / 2, bottom - h * 0.06)
        ..lineTo(0, bottom)
        ..close(),
      fill,
    );
    // Graphite point.
    fill.color = IntroArt.ink;
    canvas.drawPath(
      Path()
        ..moveTo(-pw * 0.2, bottom - h * 0.022)
        ..lineTo(pw * 0.2, bottom - h * 0.022)
        ..lineTo(0, bottom)
        ..close(),
      fill,
    );

    canvas.restore();
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
  bool shouldRepaint(covariant _QuizPainter oldDelegate) => false;
}
