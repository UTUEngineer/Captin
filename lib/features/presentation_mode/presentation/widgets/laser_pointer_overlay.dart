import 'package:captain/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class LaserTrailPoint {
  const LaserTrailPoint({
    required this.position,
    required this.createdAt,
  });

  final Offset position;
  final DateTime createdAt;
}

class LaserPointerOverlay extends StatelessWidget {
  const LaserPointerOverlay({
    super.key,
    required this.points,
  });

  final List<LaserTrailPoint> points;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _LaserPointerPainter(points: points),
        size: Size.infinite,
      ),
    );
  }
}

class _LaserPointerPainter extends CustomPainter {
  _LaserPointerPainter({required this.points});

  final List<LaserTrailPoint> points;
  static const _fadeDuration = Duration(milliseconds: 1600);

  @override
  void paint(Canvas canvas, Size size) {
    final now = DateTime.now();
    if (points.length < 2) return;

    for (var i = 1; i < points.length; i++) {
      final start = points[i - 1];
      final end = points[i];
      final ageMs = now.difference(end.createdAt).inMilliseconds;
      if (ageMs > _fadeDuration.inMilliseconds) continue;

      final opacity = (1 - ageMs / _fadeDuration.inMilliseconds).clamp(0.0, 1.0);
      final paint = Paint()
        ..color = AppColors.accentOrange.withValues(alpha: opacity * 0.9)
        ..strokeWidth = 4 * opacity + 1
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(start.position, end.position, paint);
    }

    final last = points.last;
    final lastAge = now.difference(last.createdAt).inMilliseconds;
    if (lastAge <= _fadeDuration.inMilliseconds) {
      final opacity =
          (1 - lastAge / _fadeDuration.inMilliseconds).clamp(0.0, 1.0);
      canvas.drawCircle(
        last.position,
        6 * opacity + 2,
        Paint()..color = AppColors.accentRed.withValues(alpha: opacity),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _LaserPointerPainter oldDelegate) {
    return oldDelegate.points != points;
  }
}
