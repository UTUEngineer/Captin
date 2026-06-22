import 'dart:math' as math;

import 'package:captain/features/training/domain/drill_path.dart';
import 'package:captain/features/training/domain/drill_path_style.dart';
import 'package:captain/features/tactical_board/presentation/widgets/pitch_painter.dart';
import 'package:flutter/material.dart';

class DrillPathPainter extends CustomPainter {
  DrillPathPainter({
    required this.layout,
    required this.paths,
    this.draftStart,
    this.draftEnd,
    this.draftStyle = DrillPathStyle.run,
  });

  final PitchLayout layout;
  final List<DrillPath> paths;
  final Offset? draftStart;
  final Offset? draftEnd;
  final DrillPathStyle draftStyle;

  @override
  void paint(Canvas canvas, Size size) {
    for (final path in paths) {
      _paintPath(canvas, path);
    }

    if (draftStart != null && draftEnd != null) {
      _paintLine(
        canvas,
        draftStart!,
        draftEnd!,
        const [],
        draftStyle,
        const Color(0xFF2E7D32),
        dashed: draftStyle == DrillPathStyle.pass,
      );
    }
  }

  void _paintPath(Canvas canvas, DrillPath path) {
    final start = layout.positionFor(path.startX, path.startY);
    final end = layout.positionFor(path.endX, path.endY);
    final controls = path.controlPoints
        .map((point) => layout.positionFor(point.x, point.y))
        .toList();

    _paintLine(
      canvas,
      start,
      end,
      controls,
      path.style,
      path.color,
      dashed: path.style == DrillPathStyle.pass,
      wavy: path.style == DrillPathStyle.shot,
    );
  }

  void _paintLine(
    Canvas canvas,
    Offset start,
    Offset end,
    List<Offset> controls,
    DrillPathStyle style,
    Color color, {
    bool dashed = false,
    bool wavy = false,
  }) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final path = Path()..moveTo(start.dx, start.dy);

    if (controls.isNotEmpty) {
      final control = controls.first;
      path.cubicTo(
        start.dx + (control.dx - start.dx) * 0.5,
        start.dy + (control.dy - start.dy) * 0.5,
        control.dx,
        control.dy,
        end.dx,
        end.dy,
      );
    } else if (wavy) {
      final mid = Offset((start.dx + end.dx) / 2, (start.dy + end.dy) / 2);
      final normal = Offset(
        -(end.dy - start.dy),
        end.dx - start.dx,
      );
      final length = math.sqrt(normal.dx * normal.dx + normal.dy * normal.dy);
      final unit = length == 0
          ? const Offset(0, 1)
          : Offset(normal.dx / length, normal.dy / length);
      path.quadraticBezierTo(
        mid.dx + unit.dx * 12,
        mid.dy + unit.dy * 12,
        end.dx,
        end.dy,
      );
    } else {
      path.lineTo(end.dx, end.dy);
    }

    if (dashed) {
      _drawDashedPath(canvas, path, paint);
    } else {
      canvas.drawPath(path, paint);
    }

    _drawArrowHead(canvas, end, start, color);
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = distance + 8;
        final extract = metric.extractPath(
          distance,
          next.clamp(0, metric.length),
        );
        canvas.drawPath(extract, paint);
        distance = next + 6;
      }
    }
  }

  void _drawArrowHead(Canvas canvas, Offset tip, Offset from, Color color) {
    final angle = math.atan2(tip.dy - from.dy, tip.dx - from.dx);
    const size = 10.0;
    final path = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(
        tip.dx - size * math.cos(angle - 0.45),
        tip.dy - size * math.sin(angle - 0.45),
      )
      ..lineTo(
        tip.dx - size * math.cos(angle + 0.45),
        tip.dy - size * math.sin(angle + 0.45),
      )
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant DrillPathPainter oldDelegate) {
    return oldDelegate.paths != paths ||
        oldDelegate.layout != layout ||
        oldDelegate.draftStart != draftStart ||
        oldDelegate.draftEnd != draftEnd;
  }
}
