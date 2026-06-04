import 'package:flutter/material.dart';

import 'package:lms_mobile_app/src/shared/widgets/intro_art_palette.dart';

/// Asset-free, coloured flat-vector illustration of a person studying, painted
/// with [CustomPaint].
///
/// First onboarding slide. A seated learner reading an open book, framed by a
/// soft glow, a small stack of colourful books and idea/sparkle accents — in the
/// same friendly flat style as the rest of the set ([IntroArt] palette).
class LearningArtwork extends StatelessWidget {
  final double height;

  const LearningArtwork({super.key, this.height = 240});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: CustomPaint(
        painter: _LearningPainter(),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _LearningPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w * 0.5;
    final fill = Paint()..style = PaintingStyle.fill;

    // --- Soft glow behind the subject ---
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

    // --- Floating stack of colourful books (top-left) ---
    _miniBook(canvas, w, Offset(cx - w * 0.30, h * 0.24), IntroArt.teal, 0.10);
    _miniBook(canvas, w, Offset(cx - w * 0.295, h * 0.205), IntroArt.gold, -0.06);
    _miniBook(canvas, w, Offset(cx - w * 0.30, h * 0.17), IntroArt.coral, 0.04);

    // --- Cushion the learner sits on ---
    fill.color = IntroArt.teal;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, h * 0.80), width: w * 0.64, height: h * 0.14),
      fill,
    );
    fill.color = IntroArt.tealDeep;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, h * 0.835), width: w * 0.50, height: h * 0.07),
      fill,
    );

    // --- Crossed legs (trousers) ---
    fill.color = IntroArt.ink;
    final lap = Path()
      ..moveTo(cx, h * 0.66)
      ..cubicTo(cx + w * 0.12, h * 0.66, cx + w * 0.30, h * 0.74, cx + w * 0.30, h * 0.80)
      ..cubicTo(cx + w * 0.30, h * 0.85, cx + w * 0.16, h * 0.855, cx, h * 0.855)
      ..cubicTo(cx - w * 0.16, h * 0.855, cx - w * 0.30, h * 0.85, cx - w * 0.30, h * 0.80)
      ..cubicTo(cx - w * 0.30, h * 0.74, cx - w * 0.12, h * 0.66, cx, h * 0.66)
      ..close();
    canvas.drawPath(lap, fill);

    // --- Torso (shirt) ---
    fill.color = IntroArt.coral;
    final torso = Path()
      ..moveTo(cx - w * 0.105, h * 0.45)
      ..lineTo(cx + w * 0.105, h * 0.45)
      ..cubicTo(cx + w * 0.165, h * 0.55, cx + w * 0.175, h * 0.63, cx + w * 0.15, h * 0.70)
      ..cubicTo(cx + w * 0.07, h * 0.73, cx - w * 0.07, h * 0.73, cx - w * 0.15, h * 0.70)
      ..cubicTo(cx - w * 0.175, h * 0.63, cx - w * 0.165, h * 0.55, cx - w * 0.105, h * 0.45)
      ..close();
    canvas.drawPath(torso, fill);
    // Collar accent.
    fill.color = IntroArt.coralDeep;
    final collar = Path()
      ..moveTo(cx - w * 0.06, h * 0.45)
      ..lineTo(cx + w * 0.06, h * 0.45)
      ..lineTo(cx, h * 0.50)
      ..close();
    canvas.drawPath(collar, fill);

    // --- Arms (sleeves) reaching to the book ---
    final sleeve = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = w * 0.058
      ..color = IntroArt.coral;
    canvas.drawLine(Offset(cx - w * 0.115, h * 0.49), Offset(cx - w * 0.155, h * 0.625), sleeve);
    canvas.drawLine(Offset(cx + w * 0.115, h * 0.49), Offset(cx + w * 0.155, h * 0.625), sleeve);

    // --- Neck + head ---
    fill.color = IntroArt.skinDeep;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, h * 0.42), width: w * 0.07, height: h * 0.06),
        const Radius.circular(6),
      ),
      fill,
    );
    final headCenter = Offset(cx, h * 0.315);
    final headR = w * 0.097;
    fill.color = IntroArt.skin;
    canvas.drawCircle(headCenter, headR, fill);

    // Face (looking down at the book).
    final faceStroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..color = IntroArt.ink;
    faceStroke.strokeWidth = w * 0.011;
    canvas.drawArc(
      Rect.fromCenter(center: Offset(cx - w * 0.032, h * 0.335), width: w * 0.03, height: h * 0.02),
      0.15, 2.6, false, faceStroke,
    );
    canvas.drawArc(
      Rect.fromCenter(center: Offset(cx + w * 0.032, h * 0.335), width: w * 0.03, height: h * 0.02),
      0.4, 2.6, false, faceStroke,
    );
    // Cheek blush.
    fill.color = IntroArt.coral.withValues(alpha: 0.45);
    canvas.drawCircle(Offset(cx - w * 0.052, h * 0.35), w * 0.013, fill);
    canvas.drawCircle(Offset(cx + w * 0.052, h * 0.35), w * 0.013, fill);

    // --- Hair (crown + bun) ---
    fill.color = IntroArt.hair;
    final hair = Path()
      ..moveTo(cx - headR * 1.04, h * 0.315)
      ..cubicTo(cx - headR * 1.08, h * 0.215, cx + headR * 1.08, h * 0.215, cx + headR * 1.04, h * 0.315)
      ..cubicTo(cx + headR * 0.62, h * 0.255, cx - headR * 0.62, h * 0.255, cx - headR * 1.04, h * 0.315)
      ..close();
    canvas.drawPath(hair, fill);
    canvas.drawCircle(Offset(cx, h * 0.205), w * 0.034, fill);

    // --- Open book on the lap ---
    // Cover (golden, slightly larger than the pages).
    fill.color = IntroArt.goldDeep;
    canvas.drawPath(_page(cx, h, w, left: true, top: 0.612, lift: 0.55, outer: 0.255, bottom: 0.69), fill);
    fill.color = IntroArt.gold;
    canvas.drawPath(_page(cx, h, w, left: false, top: 0.612, lift: 0.55, outer: 0.255, bottom: 0.69), fill);
    // Pages (cream, on top of the cover).
    fill.color = IntroArt.paper;
    canvas.drawPath(_page(cx, h, w, left: true, top: 0.60, lift: 0.558, outer: 0.225, bottom: 0.668), fill);
    fill.color = IntroArt.cream;
    canvas.drawPath(_page(cx, h, w, left: false, top: 0.60, lift: 0.558, outer: 0.225, bottom: 0.668), fill);

    // Page text lines.
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = w * 0.008
      ..color = IntroArt.ink.withValues(alpha: 0.32);
    for (int i = 0; i < 3; i++) {
      final dy = h * (0.605 + i * 0.017);
      canvas.drawLine(Offset(cx - w * 0.04, dy), Offset(cx - w * 0.175, dy - h * 0.012), line);
      canvas.drawLine(Offset(cx + w * 0.04, dy), Offset(cx + w * 0.175, dy - h * 0.012), line);
    }

    // --- Hands holding the book ---
    fill.color = IntroArt.skin;
    canvas.drawCircle(Offset(cx - w * 0.165, h * 0.625), w * 0.026, fill);
    canvas.drawCircle(Offset(cx + w * 0.165, h * 0.625), w * 0.026, fill);

    // --- Accents ---
    _bulb(canvas, w, h, Offset(cx + w * 0.275, h * 0.16), w * 0.036);
    _sparkle(canvas, Offset(cx - w * 0.265, h * 0.40), w * 0.034, IntroArt.gold);
    _sparkle(canvas, Offset(cx + w * 0.33, h * 0.34), w * 0.020, IntroArt.cream);
    _sparkle(canvas, Offset(cx - w * 0.33, h * 0.55), w * 0.017, IntroArt.gold);
  }

  /// One page/cover half of the open book.
  Path _page(double cx, double h, double w,
      {required bool left,
      required double top,
      required double lift,
      required double outer,
      required double bottom}) {
    final d = left ? -1.0 : 1.0;
    return Path()
      ..moveTo(cx, h * top)
      ..quadraticBezierTo(cx + d * w * 0.12, h * lift, cx + d * w * outer, h * (top - 0.027))
      ..lineTo(cx + d * w * (outer - 0.03), h * bottom)
      ..quadraticBezierTo(cx + d * w * 0.10, h * (bottom - 0.03), cx, h * (bottom - 0.014))
      ..close();
  }

  /// A small closed book in a floating stack.
  void _miniBook(Canvas canvas, double w, Offset c, Color color, double tilt) {
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(tilt);
    final bw = w * 0.16;
    final bh = w * 0.045;
    final fill = Paint()
      ..style = PaintingStyle.fill
      ..color = color;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: bw, height: bh),
        Radius.circular(bh * 0.3),
      ),
      fill,
    );
    // Page edge.
    fill.color = IntroArt.cream;
    canvas.drawRect(Rect.fromLTWH(bw * 0.30, -bh * 0.32, bw * 0.16, bh * 0.64), fill);
    canvas.restore();
  }

  /// Lightbulb idea accent.
  void _bulb(Canvas canvas, double w, double h, Offset o, double r) {
    final fill = Paint()..style = PaintingStyle.fill;
    fill.color = IntroArt.gold;
    canvas.drawCircle(o, r, fill);
    fill.color = IntroArt.goldDeep;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(o.dx, o.dy + r * 1.15), width: r * 0.9, height: r * 0.7),
        const Radius.circular(2),
      ),
      fill,
    );
    final ray = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.009
      ..strokeCap = StrokeCap.round
      ..color = IntroArt.gold;
    canvas.drawLine(Offset(o.dx - r * 1.9, o.dy), Offset(o.dx - r * 1.35, o.dy), ray);
    canvas.drawLine(Offset(o.dx + r * 1.35, o.dy), Offset(o.dx + r * 1.9, o.dy), ray);
    canvas.drawLine(Offset(o.dx, o.dy - r * 1.9), Offset(o.dx, o.dy - r * 1.35), ray);
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
  bool shouldRepaint(covariant _LearningPainter oldDelegate) => false;
}
