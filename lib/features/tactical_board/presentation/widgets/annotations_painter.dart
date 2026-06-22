import 'dart:math' as math;

import 'package:captain/core/theme/app_colors.dart';
import 'package:captain/features/tactical_board/application/tactical_board_notifier.dart';
import 'package:captain/features/tactical_board/domain/arrow.dart';
import 'package:captain/features/tactical_board/domain/board_tool.dart';
import 'package:captain/features/tactical_board/domain/highlight_circle.dart';
import 'package:captain/features/tactical_board/domain/zone.dart';
import 'package:captain/features/tactical_board/presentation/widgets/pitch_painter.dart';
import 'package:flutter/material.dart';

class AnnotationsPainter extends CustomPainter {
  AnnotationsPainter({
    required this.layout,
    required this.zones,
    required this.highlights,
    required this.arrows,
    this.draft,
  });

  final PitchLayout layout;
  final List<Zone> zones;
  final List<HighlightCircle> highlights;
  final List<Arrow> arrows;
  final DraftDrawing? draft;

  @override
  void paint(Canvas canvas, Size size) {
    for (final zone in zones) {
      _drawZone(canvas, zone);
    }

    for (final circle in highlights) {
      _drawHighlight(canvas, circle);
    }

    for (final arrow in arrows) {
      _drawArrow(canvas, arrow);
    }

    if (draft != null) {
      _drawDraft(canvas, draft!);
    }
  }

  void _drawZone(Canvas canvas, Zone zone) {
    final topLeft = layout.positionFor(zone.x, zone.y);
    final bottomRight =
        layout.positionFor(zone.x + zone.width, zone.y + zone.height);
    final rect = Rect.fromPoints(topLeft, bottomRight);
    final center = rect.center;
    final color = Color(zone.colorValue);

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(zone.rotation);
    canvas.translate(-center.dx, -center.dy);
    canvas.drawRect(
      rect,
      Paint()
        ..color = color.withValues(alpha: 0.25)
        ..style = PaintingStyle.fill,
    );
    canvas.drawRect(
      rect,
      Paint()
        ..color = color.withValues(alpha: 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.5, layout.rect.shortestSide * 0.004),
    );
    canvas.restore();
  }

  void _drawHighlight(Canvas canvas, HighlightCircle circle) {
    final center = layout.positionFor(circle.centerX, circle.centerY);
    final radiusX = circle.radiusX * layout.rect.width;
    final radiusY = circle.radiusY * layout.rect.height;
    final rect = Rect.fromCenter(
      center: center,
      width: radiusX * 2,
      height: radiusY * 2,
    );
    final color = Color(circle.colorValue);

    canvas.drawOval(
      rect,
      Paint()
        ..color = color.withValues(alpha: 0.22)
        ..style = PaintingStyle.fill,
    );
    canvas.drawOval(
      rect,
      Paint()
        ..color = color.withValues(alpha: 0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.5, layout.rect.shortestSide * 0.004),
    );
  }

  void _drawArrow(Canvas canvas, Arrow arrow) {
    final start = layout.positionFor(arrow.startX, arrow.startY);
    final end = layout.positionFor(arrow.endX, arrow.endY);
    final center = Offset((start.dx + end.dx) / 2, (start.dy + end.dy) / 2);

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(arrow.rotation);
    canvas.translate(-center.dx, -center.dy);
    _paintArrow(
      canvas,
      startX: arrow.startX,
      startY: arrow.startY,
      endX: arrow.endX,
      endY: arrow.endY,
      type: arrow.type,
      curved: arrow.curved,
      color: Color(arrow.colorValue ?? _defaultColor(arrow.type).toARGB32()),
    );
    canvas.restore();
  }

  void _drawDraft(Canvas canvas, DraftDrawing draft) {
    switch (draft.tool) {
      case BoardTool.passArrow:
      case BoardTool.runArrow:
      case BoardTool.pressArrow:
      case BoardTool.curvedRun:
        _paintArrow(
          canvas,
          startX: draft.startX,
          startY: draft.startY,
          endX: draft.endX,
          endY: draft.endY,
          type: _arrowTypeForTool(draft.tool),
          curved: draft.tool == BoardTool.curvedRun,
          color: _defaultColor(_arrowTypeForTool(draft.tool)),
        );
      case BoardTool.zone:
        _drawDraftRect(canvas, draft, isCircle: false);
      case BoardTool.circle:
        _drawDraftRect(canvas, draft, isCircle: true);
      default:
        break;
    }
  }

  void _drawDraftRect(Canvas canvas, DraftDrawing draft, {required bool isCircle}) {
    final left = math.min(draft.startX, draft.endX);
    final top = math.min(draft.startY, draft.endY);
    final width = (draft.endX - draft.startX).abs();
    final height = (draft.endY - draft.startY).abs();
    final topLeft = layout.positionFor(left, top);
    final bottomRight = layout.positionFor(left + width, top + height);
    final rect = Rect.fromPoints(topLeft, bottomRight);
    final color = Color(0xFFE53935);

    if (isCircle) {
      canvas.drawOval(
        rect,
        Paint()
          ..color = color.withValues(alpha: 0.22)
          ..style = PaintingStyle.fill,
      );
      canvas.drawOval(
        rect,
        Paint()
          ..color = color.withValues(alpha: 0.85)
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(1.5, layout.rect.shortestSide * 0.004),
      );
    } else {
      canvas.drawRect(
        rect,
        Paint()
          ..color = color.withValues(alpha: 0.25)
          ..style = PaintingStyle.fill,
      );
      canvas.drawRect(
        rect,
        Paint()
          ..color = color.withValues(alpha: 0.85)
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(1.5, layout.rect.shortestSide * 0.004),
      );
    }
  }

  void _paintArrow(
    Canvas canvas, {
    required double startX,
    required double startY,
    required double endX,
    required double endY,
    required ArrowType type,
    required bool curved,
    required Color color,
  }) {
    final start = layout.positionFor(startX, startY);
    final end = layout.positionFor(endX, endY);
    final strokeWidth = switch (type) {
      ArrowType.press => math.max(4.0, layout.rect.shortestSide * 0.012),
      ArrowType.pass => math.max(2.0, layout.rect.shortestSide * 0.005),
      _ => math.max(2.5, layout.rect.shortestSide * 0.006),
    };

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    if (type == ArrowType.run || type == ArrowType.curvedRun) {
      paint.strokeCap = StrokeCap.round;
      _drawDashed(canvas, start, end, paint, curved: curved);
    } else if (curved) {
      final control = Offset(
        (start.dx + end.dx) / 2,
        start.dy - (end.dy - start.dy).abs() * 0.35,
      );
      final path = Path()
        ..moveTo(start.dx, start.dy)
        ..quadraticBezierTo(control.dx, control.dy, end.dx, end.dy);
      canvas.drawPath(path, paint);
      _drawArrowHead(canvas, end, control, paint);
    } else {
      canvas.drawLine(start, end, paint);
      _drawArrowHead(canvas, end, start, paint);
    }
  }

  void _drawDashed(
    Canvas canvas,
    Offset start,
    Offset end,
    Paint paint, {
    required bool curved,
  }) {
    if (curved) {
      final control = Offset(
        (start.dx + end.dx) / 2,
        start.dy - (end.dy - start.dy).abs() * 0.35,
      );
      final path = Path()
        ..moveTo(start.dx, start.dy)
        ..quadraticBezierTo(control.dx, control.dy, end.dx, end.dy);
      _drawDashedPath(canvas, path, paint);
      _drawArrowHead(canvas, end, control, paint);
      return;
    }

    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..lineTo(end.dx, end.dy);
    _drawDashedPath(canvas, path, paint);
    _drawArrowHead(canvas, end, start, paint);
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    final metrics = path.computeMetrics();
    const dashLength = 10.0;
    const gapLength = 7.0;

    for (final metric in metrics) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = math.min(distance + dashLength, metric.length);
        final extract = metric.extractPath(distance, next);
        canvas.drawPath(extract, paint);
        distance += dashLength + gapLength;
      }
    }
  }

  void _drawArrowHead(Canvas canvas, Offset tip, Offset from, Paint paint) {
    final angle = math.atan2(tip.dy - from.dy, tip.dx - from.dx);
    const headLength = 12.0;
    const headAngle = math.pi / 7;

    final p1 = Offset(
      tip.dx - headLength * math.cos(angle - headAngle),
      tip.dy - headLength * math.sin(angle - headAngle),
    );
    final p2 = Offset(
      tip.dx - headLength * math.cos(angle + headAngle),
      tip.dy - headLength * math.sin(angle + headAngle),
    );

    final path = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy)
      ..close();
    canvas.drawPath(
      path,
      Paint()
        ..color = paint.color
        ..style = PaintingStyle.fill,
    );
  }

  ArrowType _arrowTypeForTool(BoardTool tool) {
    return switch (tool) {
      BoardTool.passArrow => ArrowType.pass,
      BoardTool.runArrow => ArrowType.run,
      BoardTool.pressArrow => ArrowType.press,
      BoardTool.curvedRun => ArrowType.curvedRun,
      _ => ArrowType.pass,
    };
  }

  Color _defaultColor(ArrowType type) {
    return switch (type) {
      ArrowType.pass => AppColors.textPrimary,
      ArrowType.run => AppColors.textPrimary,
      ArrowType.press => AppColors.accentRed,
      ArrowType.curvedRun => AppColors.accentOrange,
    };
  }

  @override
  bool shouldRepaint(covariant AnnotationsPainter oldDelegate) {
    return oldDelegate.zones != zones ||
        oldDelegate.highlights != highlights ||
        oldDelegate.arrows != arrows ||
        oldDelegate.draft != draft ||
        oldDelegate.layout.rect != layout.rect;
  }
}
