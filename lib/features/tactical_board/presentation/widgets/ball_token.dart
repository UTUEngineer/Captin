import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Shaded football used on the 2D board.
class BallToken extends StatelessWidget {
  const BallToken({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _BallPainter()),
    );
  }
}

class _BallPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final r = size.shortestSide / 2;
    final c = Offset(size.width / 2, size.height / 2);

    // Ground shadow.
    canvas.drawOval(
      Rect.fromCenter(center: c + Offset(r * 0.2, r * 0.85), width: r * 1.9, height: r * 0.7),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.35)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.25),
    );

    final ball = Rect.fromCircle(center: c, radius: r);
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.35, -0.4),
          radius: 0.95,
          colors: const [Color(0xFFFFFFFF), Color(0xFFE5E7EB), Color(0xFF9CA3AF)],
          stops: const [0.0, 0.6, 1.0],
        ).createShader(ball),
    );

    // Pentagon patches.
    final patch = Paint()..color = const Color(0xFF111827);
    void pentagon(Offset center, double radius, double rotation) {
      final path = Path();
      for (var i = 0; i < 5; i++) {
        final a = rotation + i * 2 * math.pi / 5 - math.pi / 2;
        final p = center + Offset(math.cos(a), math.sin(a)) * radius;
        if (i == 0) {
          path.moveTo(p.dx, p.dy);
        } else {
          path.lineTo(p.dx, p.dy);
        }
      }
      canvas.drawPath(path..close(), patch);
    }

    canvas.save();
    canvas.clipPath(Path()..addOval(ball));
    pentagon(c, r * 0.32, 0);
    for (var i = 0; i < 5; i++) {
      final a = i * 2 * math.pi / 5 - math.pi / 2;
      pentagon(c + Offset(math.cos(a), math.sin(a)) * r * 0.95, r * 0.3, math.pi / 5);
    }
    canvas.restore();

    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1, r * 0.08)
        ..color = Colors.black.withValues(alpha: 0.5),
    );
  }

  @override
  bool shouldRepaint(covariant _BallPainter oldDelegate) => false;
}
