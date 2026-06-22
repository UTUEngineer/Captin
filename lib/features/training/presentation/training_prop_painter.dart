import 'dart:math' as math;

import 'package:captain/features/training/domain/training_prop.dart';
import 'package:captain/features/training/domain/training_prop_type.dart';
import 'package:captain/features/tactical_board/presentation/widgets/pitch_painter.dart';
import 'package:flutter/material.dart';

class TrainingPropPainter extends CustomPainter {
  TrainingPropPainter({
    required this.layout,
    required this.props,
  });

  final PitchLayout layout;
  final List<TrainingProp> props;

  @override
  void paint(Canvas canvas, Size size) {
    for (final prop in props) {
      _paintProp(canvas, prop);
    }
  }

  void _paintProp(Canvas canvas, TrainingProp prop) {
    final center = layout.positionFor(prop.x, prop.y);
    final baseSize = layout.tokenSize * 0.55;
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(prop.rotation * math.pi / 180);

    switch (prop.type) {
      case TrainingPropType.cone:
        _paintCone(canvas, baseSize, prop.color);
      case TrainingPropType.ball:
        _paintBall(canvas, baseSize);
      case TrainingPropType.smallGoal:
        _paintGoal(canvas, baseSize * 1.4, baseSize * 0.8, prop.color);
      case TrainingPropType.fullGoal:
        _paintGoal(canvas, baseSize * 2.4, baseSize * 1.2, prop.color);
      case TrainingPropType.mannequin:
        _paintMannequin(canvas, baseSize, prop.color);
      case TrainingPropType.pole:
        _paintPole(canvas, baseSize, prop.color);
      case TrainingPropType.ladder:
        _paintLadder(canvas, baseSize, prop.color);
      case TrainingPropType.hurdle:
        _paintHurdle(canvas, baseSize, prop.color);
      case TrainingPropType.disc:
        _paintDisc(canvas, baseSize * 0.7, prop.color);
    }

    canvas.restore();
  }

  void _paintCone(Canvas canvas, double size, Color color) {
    final path = Path()
      ..moveTo(0, -size * 0.6)
      ..lineTo(size * 0.45, size * 0.5)
      ..lineTo(-size * 0.45, size * 0.5)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  void _paintBall(Canvas canvas, double size) {
    canvas.drawCircle(
      Offset.zero,
      size * 0.35,
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(
      Offset.zero,
      size * 0.35,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    final pentagon = Paint()..color = Colors.black.withValues(alpha: 0.85);
    canvas.drawCircle(Offset.zero, size * 0.12, pentagon);
  }

  void _paintGoal(Canvas canvas, double width, double height, Color color) {
    final rect = Rect.fromCenter(
      center: Offset.zero,
      width: width,
      height: height,
    );
    canvas.drawRect(
      rect,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  void _paintMannequin(Canvas canvas, double size, Color color) {
    final paint = Paint()..color = color;
    canvas.drawCircle(Offset(0, -size * 0.35), size * 0.12, paint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(0, size * 0.05),
          width: size * 0.22,
          height: size * 0.55,
        ),
        const Radius.circular(6),
      ),
      paint,
    );
  }

  void _paintPole(Canvas canvas, double size, Color color) {
    canvas.drawLine(
      Offset(0, size * 0.45),
      Offset(0, -size * 0.45),
      Paint()
        ..color = color
        ..strokeWidth = 2,
    );
    canvas.drawCircle(
      Offset(0, -size * 0.45),
      size * 0.08,
      Paint()..color = color,
    );
  }

  void _paintLadder(Canvas canvas, double size, Color color) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2;
    canvas.drawLine(
      Offset(-size * 0.35, -size * 0.4),
      Offset(-size * 0.35, size * 0.4),
      paint,
    );
    canvas.drawLine(
      Offset(size * 0.35, -size * 0.4),
      Offset(size * 0.35, size * 0.4),
      paint,
    );
    for (var i = 0; i < 4; i++) {
      final y = -size * 0.25 + i * size * 0.16;
      canvas.drawLine(
        Offset(-size * 0.35, y),
        Offset(size * 0.35, y),
        paint,
      );
    }
  }

  void _paintHurdle(Canvas canvas, double size, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final path = Path()
      ..moveTo(-size * 0.4, size * 0.3)
      ..lineTo(-size * 0.4, 0)
      ..quadraticBezierTo(0, -size * 0.45, size * 0.4, 0)
      ..lineTo(size * 0.4, size * 0.3);
    canvas.drawPath(path, paint);
  }

  void _paintDisc(Canvas canvas, double size, Color color) {
    canvas.drawCircle(
      Offset.zero,
      size,
      Paint()..color = color.withValues(alpha: 0.85),
    );
  }

  @override
  bool shouldRepaint(covariant TrainingPropPainter oldDelegate) {
    return oldDelegate.props != props || oldDelegate.layout != layout;
  }
}
