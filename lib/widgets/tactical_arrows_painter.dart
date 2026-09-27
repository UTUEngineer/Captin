import 'dart:math';
import 'package:flutter/material.dart';

class ArrowData {
  final Offset start;
  final Offset end;
  final String type; // 'pass' | 'run' | 'press'

  ArrowData({required this.start, required this.end, required this.type});

  factory ArrowData.fromJson(Map<String, dynamic> json) {
    return ArrowData(
      start: Offset(
        (json['startX'] as num? ?? 0).toDouble(),
        (json['startY'] as num? ?? 0).toDouble(),
      ),
      end: Offset(
        (json['endX'] as num? ?? 0).toDouble(),
        (json['endY'] as num? ?? 0).toDouble(),
      ),
      type: json['type']?.toString() ?? 'run',
    );
  }
}

class TacticalArrowsPainter extends CustomPainter {
  final List<ArrowData> arrows;

  TacticalArrowsPainter({required this.arrows});

  @override
  void paint(Canvas canvas, Size size) {
    for (var arrow in arrows) {
      final startPx = Offset(
        arrow.start.dx * size.width / 100,
        arrow.start.dy * size.height / 100,
      );
      final endPx = Offset(
        arrow.end.dx * size.width / 100,
        arrow.end.dy * size.height / 100,
      );

      Color color;
      bool isDashed = false;

      if (arrow.type == 'pass') {
        color = const Color(0xFF3B82F6); // Blue for Pass
      } else if (arrow.type == 'press') {
        color = const Color(0xFFEF4444); // Red for Press
        isDashed = true;
      } else {
        color = const Color(0xFFF59E0B); // Yellow for Run
      }

      final paint = Paint()
        ..color = color
        ..strokeWidth = 3.0
        ..style = PaintingStyle.stroke;

      if (isDashed) {
        _drawDashedLine(canvas, startPx, endPx, paint);
      } else {
        canvas.drawLine(startPx, endPx, paint);
      }

      _drawArrowHead(canvas, startPx, endPx, paint);
    }
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const double dashWidth = 6;
    const double dashSpace = 4;
    double distance = (end - start).distance;
    if (distance == 0) return;

    double dx = (end.dx - start.dx) / distance;
    double dy = (end.dy - start.dy) / distance;
    double currentDistance = 0;

    while (currentDistance < distance) {
      final double nextDistance = min(currentDistance + dashWidth, distance);
      canvas.drawLine(
        Offset(start.dx + dx * currentDistance, start.dy + dy * currentDistance),
        Offset(start.dx + dx * nextDistance, start.dy + dy * nextDistance),
        paint,
      );
      currentDistance += dashWidth + dashSpace;
    }
  }

  void _drawArrowHead(Canvas canvas, Offset start, Offset end, Paint paint) {
    final double angle = atan2(end.dy - start.dy, end.dx - start.dx);
    const double arrowSize = 10.0;

    final path = Path()
      ..moveTo(end.dx, end.dy)
      ..lineTo(
        end.dx - arrowSize * cos(angle - pi / 6),
        end.dy - arrowSize * sin(angle - pi / 6),
      )
      ..lineTo(
        end.dx - arrowSize * cos(angle + pi / 6),
        end.dy - arrowSize * sin(angle + pi / 6),
      )
      ..close();

    final fillPaint = Paint()
      ..color = paint.color
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, fillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
