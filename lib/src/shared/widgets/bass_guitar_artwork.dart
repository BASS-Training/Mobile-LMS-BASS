import 'package:flutter/material.dart';

/// Reusable, asset-free bass-guitar illustration painted with [CustomPaint].
///
/// Used across the onboarding and auth screens so the brand motif stays
/// consistent without bundling image assets. Colour is parameterised so it can
/// sit on either a dark brand panel (white) or a light surface.
class BassGuitarArtwork extends StatelessWidget {
  final double height;
  final Color color;

  const BassGuitarArtwork({super.key, this.height = 168, this.color = Colors.white});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: CustomPaint(
        painter: BassGuitarPainter(color: color),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class BassGuitarPainter extends CustomPainter {
  final Color color;

  const BassGuitarPainter({this.color = Colors.white});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w * 0.5;

    final paint = Paint()..style = PaintingStyle.fill;

    // Body (figure-8 shape with larger lower bout)
    paint.color = color.withValues(alpha: 0.92);
    final bodyPath = Path();
    bodyPath.moveTo(cx - w * 0.10, h * 0.47);
    bodyPath.lineTo(cx + w * 0.10, h * 0.47);
    bodyPath.cubicTo(
      cx + w * 0.30, h * 0.47,
      cx + w * 0.28, h * 0.58,
      cx + w * 0.14, h * 0.63,
    );
    bodyPath.cubicTo(
      cx + w * 0.32, h * 0.65,
      cx + w * 0.36, h * 0.78,
      cx + w * 0.35, h * 0.88,
    );
    bodyPath.cubicTo(
      cx + w * 0.34, h * 0.97,
      cx + w * 0.20, h * 0.99,
      cx, h * 0.99,
    );
    bodyPath.cubicTo(
      cx - w * 0.20, h * 0.99,
      cx - w * 0.34, h * 0.97,
      cx - w * 0.35, h * 0.88,
    );
    bodyPath.cubicTo(
      cx - w * 0.36, h * 0.78,
      cx - w * 0.32, h * 0.65,
      cx - w * 0.14, h * 0.63,
    );
    bodyPath.cubicTo(
      cx - w * 0.28, h * 0.58,
      cx - w * 0.30, h * 0.47,
      cx - w * 0.10, h * 0.47,
    );
    bodyPath.close();
    canvas.drawPath(bodyPath, paint);

    // Neck (tapers from body to headstock)
    paint.color = color.withValues(alpha: 0.82);
    final neckPath = Path();
    neckPath.moveTo(cx - w * 0.058, h * 0.48);
    neckPath.lineTo(cx + w * 0.058, h * 0.48);
    neckPath.lineTo(cx + w * 0.046, h * 0.12);
    neckPath.lineTo(cx - w * 0.046, h * 0.12);
    neckPath.close();
    canvas.drawPath(neckPath, paint);

    // Headstock
    paint.color = color.withValues(alpha: 0.92);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx, h * 0.07),
          width: w * 0.28,
          height: h * 0.10,
        ),
        const Radius.circular(5),
      ),
      paint,
    );

    // Frets
    final fretPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = color.withValues(alpha: 0.28)
      ..strokeWidth = 1.0;
    for (int i = 1; i <= 5; i++) {
      final y = h * 0.12 + (h * 0.36 / 6) * i;
      canvas.drawLine(
        Offset(cx - w * 0.052, y),
        Offset(cx + w * 0.052, y),
        fretPaint,
      );
    }

    // Strings (4 — thicker strings have more opacity and weight)
    for (int i = 0; i < 4; i++) {
      final xPos = cx + (i - 1.5) * w * 0.020;
      canvas.drawLine(
        Offset(xPos, h * 0.09),
        Offset(xPos, h * 0.87),
        Paint()
          ..style = PaintingStyle.stroke
          ..color = color.withValues(alpha: 0.35 + i * 0.06)
          ..strokeWidth = 0.9 + i * 0.15,
      );
    }

    // Pickup
    paint.color = color.withValues(alpha: 0.20);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx, h * 0.70),
          width: w * 0.22,
          height: h * 0.055,
        ),
        const Radius.circular(3),
      ),
      paint,
    );

    // Bridge
    paint.color = color.withValues(alpha: 0.32);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx, h * 0.87),
          width: w * 0.18,
          height: h * 0.032,
        ),
        const Radius.circular(3),
      ),
      paint,
    );

    // Tuning pegs (2 on each side of headstock)
    paint
      ..color = color.withValues(alpha: 0.60)
      ..style = PaintingStyle.fill;
    for (final pos in [
      Offset(cx - w * 0.11, h * 0.035),
      Offset(cx - w * 0.11, h * 0.075),
      Offset(cx + w * 0.11, h * 0.035),
      Offset(cx + w * 0.11, h * 0.075),
    ]) {
      canvas.drawCircle(pos, 3.5, paint);
    }
  }

  @override
  bool shouldRepaint(covariant BassGuitarPainter oldDelegate) =>
      oldDelegate.color != color;
}
