import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:captain/features/tactical_board/application/tactical_board_notifier.dart';
import 'package:captain/features/tactical_board/domain/arrow.dart';
import 'package:captain/features/tactical_board/domain/board_tool.dart';
import 'package:captain/features/tactical_board/domain/highlight_circle.dart';
import 'package:captain/features/tactical_board/domain/pitch_orientation.dart';
import 'package:captain/features/tactical_board/domain/zone.dart';
import 'package:captain/features/tactical_board/presentation/widgets/pitch_painter.dart';
import 'package:flutter/material.dart';

/// Paints zones, highlight circles, tactical arrows and the in-progress
/// draft on top of the pitch.
///
/// [flowPhase] (0..1, repeating) drives the "marching" arrow animation;
/// [reveal] maps arrow ids to a 0..1 draw-in progress for freshly created
/// arrows; [focusStep] dims arrows that belong to other playback phases.
class AnnotationsPainter extends CustomPainter {
  AnnotationsPainter({
    required this.layout,
    required this.zones,
    required this.highlights,
    required this.arrows,
    this.draft,
    this.draftColor,
    this.flowPhase = 0,
    this.animateFlow = false,
    this.reveal = const {},
    this.selectedIds = const {},
    this.focusStep,
    this.showStepBadges = false,
    super.repaint,
  });

  final PitchLayout layout;
  final List<Zone> zones;
  final List<HighlightCircle> highlights;
  final List<Arrow> arrows;
  final DraftDrawing? draft;
  final Color? draftColor;
  final double flowPhase;
  final bool animateFlow;
  final Map<String, double> reveal;
  final Set<String> selectedIds;
  final int? focusStep;
  final bool showStepBadges;

  double get _unit => layout.rect.shortestSide;

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

  // ── Zones ──────────────────────────────────────────────────────────────

  Path _zonePath(Zone zone) {
    if (zone.shape == ZoneShape.polygon && zone.points.length >= 6) {
      final path = Path();
      for (var i = 0; i < zone.points.length; i += 2) {
        final p = layout.positionFor(zone.points[i], zone.points[i + 1]);
        if (i == 0) {
          path.moveTo(p.dx, p.dy);
        } else {
          path.lineTo(p.dx, p.dy);
        }
      }
      return path..close();
    }
    final topLeft = layout.positionFor(zone.x, zone.y);
    final bottomRight =
        layout.positionFor(zone.x + zone.width, zone.y + zone.height);
    return Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromPoints(topLeft, bottomRight),
          Radius.circular(_unit * 0.012),
        ),
      );
  }

  void _drawZone(Canvas canvas, Zone zone) {
    final path = _zonePath(zone);
    final bounds = path.getBounds();
    final center = bounds.center;
    final color = Color(zone.colorValue);
    final selected = selectedIds.contains(zone.id);

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(zone.rotation);
    canvas.translate(-center.dx, -center.dy);

    canvas.drawPath(
      path,
      Paint()
        ..shader = ui.Gradient.linear(
          bounds.topLeft,
          bounds.bottomRight,
          [color.withValues(alpha: 0.32), color.withValues(alpha: 0.16)],
        ),
    );

    if (zone.pattern == ZonePattern.hatched) {
      canvas.save();
      canvas.clipPath(path);
      final hatch = Paint()
        ..color = color.withValues(alpha: 0.35)
        ..strokeWidth = math.max(1, _unit * 0.003);
      final step = _unit * 0.025;
      for (var x = bounds.left - bounds.height;
          x < bounds.right;
          x += step) {
        canvas.drawLine(
          Offset(x, bounds.bottom),
          Offset(x + bounds.height, bounds.top),
          hatch,
        );
      }
      canvas.restore();
    }

    final stroke = Paint()
      ..color = color.withValues(alpha: selected ? 1 : 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.5, _unit * (selected ? 0.006 : 0.004));
    if (selected || animateFlow) {
      _drawDashedPath(
        canvas,
        path,
        stroke,
        dash: _unit * 0.02,
        gap: _unit * 0.012,
        phase: animateFlow ? flowPhase : 0,
      );
    } else {
      canvas.drawPath(path, stroke);
    }

    final label = zone.label;
    if (label != null && label.trim().isNotEmpty) {
      _drawPill(canvas, label.trim(), bounds.topCenter + Offset(0, _unit * 0.03),
          color);
    }
    canvas.restore();
  }

  void _drawHighlight(Canvas canvas, HighlightCircle circle) {
    final center = layout.positionFor(circle.centerX, circle.centerY);
    final rx = layout.orientation.isVertical
        ? circle.radiusX * layout.rect.width
        : circle.radiusY * layout.rect.width;
    final ry = layout.orientation.isVertical
        ? circle.radiusY * layout.rect.height
        : circle.radiusX * layout.rect.height;
    final rect = Rect.fromCenter(center: center, width: rx * 2, height: ry * 2);
    final color = Color(circle.colorValue);
    final selected = selectedIds.contains(circle.id);

    canvas.drawOval(
      rect,
      Paint()
        ..shader = ui.Gradient.radial(
          center,
          math.max(rx, ry),
          [color.withValues(alpha: 0.05), color.withValues(alpha: 0.3)],
        ),
    );
    final stroke = Paint()
      ..color = color.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.5, _unit * (selected ? 0.006 : 0.004));
    if (animateFlow) {
      _drawDashedPath(
        canvas,
        Path()..addOval(rect),
        stroke,
        dash: _unit * 0.018,
        gap: _unit * 0.012,
        phase: flowPhase,
      );
    } else {
      canvas.drawOval(rect, stroke);
    }
  }

  // ── Arrows ─────────────────────────────────────────────────────────────

  void _drawArrow(Canvas canvas, Arrow arrow) {
    final start = layout.positionFor(arrow.startX, arrow.startY);
    final end = layout.positionFor(arrow.endX, arrow.endY);
    final center = Offset((start.dx + end.dx) / 2, (start.dy + end.dy) / 2);
    final dimmed = focusStep != null && arrow.step != focusStep;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(arrow.rotation);
    canvas.translate(-center.dx, -center.dy);
    if (dimmed) {
      canvas.saveLayer(
        null,
        Paint()..color = const Color(0x55000000),
      );
    }
    paintArrow(
      canvas,
      startX: arrow.startX,
      startY: arrow.startY,
      endX: arrow.endX,
      endY: arrow.endY,
      type: arrow.type,
      bend: arrow.curved ? arrow.bend : 0,
      color: Color(arrow.colorValue ?? defaultArrowColor(arrow.type).toARGB32()),
      progress: reveal[arrow.id] ?? 1,
      selected: selectedIds.contains(arrow.id),
    );
    if (dimmed) canvas.restore();
    if (showStepBadges) {
      _drawStepBadge(canvas, start, arrow.step,
          Color(arrow.colorValue ?? defaultArrowColor(arrow.type).toARGB32()));
    }
    canvas.restore();
  }

  void _drawDraft(Canvas canvas, DraftDrawing draft) {
    final tool = draft.tool;
    final type = tool.arrowType;
    if (type != null) {
      paintArrow(
        canvas,
        startX: draft.startX,
        startY: draft.startY,
        endX: draft.endX,
        endY: draft.endY,
        type: type,
        bend: tool == BoardTool.curvedRun ? 0.35 : 0,
        color: draftColor ?? defaultArrowColor(type),
        progress: 1,
        selected: false,
      );
      return;
    }
    final color = draftColor ?? const Color(0xFFE53935);
    if (tool == BoardTool.freeZone) {
      if (draft.path.length < 2) return;
      final path = Path();
      for (var i = 0; i < draft.path.length; i++) {
        final p = layout.positionFor(draft.path[i].dx, draft.path[i].dy);
        if (i == 0) {
          path.moveTo(p.dx, p.dy);
        } else {
          path.lineTo(p.dx, p.dy);
        }
      }
      canvas.drawPath(
        Path.from(path)..close(),
        Paint()..color = color.withValues(alpha: 0.2),
      );
      canvas.drawPath(
        path,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(2, _unit * 0.005)
          ..strokeJoin = StrokeJoin.round
          ..strokeCap = StrokeCap.round,
      );
      return;
    }
    _drawDraftRect(canvas, draft, isCircle: tool == BoardTool.circle, color: color);
  }

  void _drawDraftRect(
    Canvas canvas,
    DraftDrawing draft, {
    required bool isCircle,
    required Color color,
  }) {
    final rect = Rect.fromPoints(
      layout.positionFor(draft.startX, draft.startY),
      layout.positionFor(draft.endX, draft.endY),
    );
    final fill = Paint()..color = color.withValues(alpha: 0.22);
    final stroke = Paint()
      ..color = color.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.5, _unit * 0.004);
    if (isCircle) {
      canvas.drawOval(rect, fill);
      canvas.drawOval(rect, stroke);
    } else {
      canvas.drawRect(rect, fill);
      canvas.drawRect(rect, stroke);
    }
  }

  /// Paints a single arrow of [type]. Public so other painters (exports,
  /// presentation) can reuse the exact same look.
  void paintArrow(
    Canvas canvas, {
    required double startX,
    required double startY,
    required double endX,
    required double endY,
    required ArrowType type,
    required double bend,
    required Color color,
    required double progress,
    required bool selected,
  }) {
    final start = layout.positionFor(startX, startY);
    final end = layout.positionFor(endX, endY);
    if ((end - start).distance < 2) return;

    final controlRel = arrowControlPoint(
      Offset(startX, startY),
      Offset(endX, endY),
      bend,
    );
    final control = layout.positionFor(controlRel.dx, controlRel.dy);

    var path = Path()
      ..moveTo(start.dx, start.dy)
      ..quadraticBezierTo(control.dx, control.dy, end.dx, end.dy);

    if (type == ArrowType.dribble) {
      path = _wavyPath(path, amplitude: _unit * 0.009, wavelength: _unit * 0.03);
    }

    // Draw-in animation for new arrows.
    final metric = path.computeMetrics().first;
    final visibleLength = metric.length * progress.clamp(0.0, 1.0);
    final visible = metric.extractPath(0, visibleLength);
    final tangent = metric.getTangentForOffset(visibleLength) ??
        metric.getTangentForOffset(metric.length)!;

    final width = switch (type) {
      ArrowType.press => math.max(4.0, _unit * 0.011),
      ArrowType.shot => math.max(3.5, _unit * 0.009),
      ArrowType.line => math.max(2.0, _unit * 0.0045),
      _ => math.max(2.4, _unit * 0.006),
    };

    final shadow = Paint()
      ..color = Colors.black.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = width + 2.5
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    if (selected) {
      canvas.drawPath(
        visible,
        Paint()
          ..color = color.withValues(alpha: 0.35)
          ..style = PaintingStyle.stroke
          ..strokeWidth = width * 3.2
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
    }

    final dashed = type == ArrowType.run || type == ArrowType.curvedRun;
    if (dashed) {
      _drawDashedPath(canvas, visible, shadow,
          dash: _unit * 0.024, gap: _unit * 0.016, phase: _phase);
      _drawDashedPath(canvas, visible, paint,
          dash: _unit * 0.024, gap: _unit * 0.016, phase: _phase);
    } else if (type == ArrowType.shot) {
      canvas.drawPath(visible, shadow);
      canvas.drawPath(visible, paint);
      canvas.drawPath(
        visible,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.85)
          ..style = PaintingStyle.stroke
          ..strokeWidth = width * 0.3
          ..strokeCap = StrokeCap.round,
      );
    } else {
      canvas.drawPath(visible, shadow);
      canvas.drawPath(visible, paint);
    }

    // Moving pulses travelling along the arrow (pass/shot/press/dribble).
    if (animateFlow && !dashed && type != ArrowType.line && progress >= 1) {
      final pulse = Paint()..color = Colors.white.withValues(alpha: 0.9);
      for (var i = 0; i < 2; i++) {
        final t = (flowPhase + i / 2) % 1.0;
        final pos = metric.getTangentForOffset(metric.length * t)?.position;
        if (pos == null) continue;
        final fade = math.sin(t * math.pi);
        canvas.drawCircle(
          pos,
          width * 0.75,
          pulse..color = Colors.white.withValues(alpha: 0.85 * fade),
        );
      }
    }

    if (progress <= 0.05) return;
    final tip = tangent.position;
    final angle = math.atan2(tangent.vector.dy, tangent.vector.dx);

    switch (type) {
      case ArrowType.line:
        final dot = Paint()..color = color;
        canvas.drawCircle(start, width * 1.2, dot);
        canvas.drawCircle(tip, width * 1.2, dot);
      case ArrowType.press:
        _drawChevron(canvas, tip, angle, color, width, offset: 0);
        _drawChevron(canvas, tip, angle, color, width, offset: width * 2.6);
      case ArrowType.shot:
        _drawArrowHead(canvas, tip, angle, color, size: width * 4.2);
      default:
        _drawArrowHead(canvas, tip, angle, color, size: math.max(11, width * 3.6));
    }
  }

  double get _phase => animateFlow ? flowPhase : 0;

  Path _wavyPath(Path base, {required double amplitude, required double wavelength}) {
    final metric = base.computeMetrics().first;
    final out = Path();
    final total = metric.length;
    final samples = math.max(12, (total / 3).round());
    for (var i = 0; i <= samples; i++) {
      final d = total * i / samples;
      final t = metric.getTangentForOffset(d)!;
      final normal = Offset(-t.vector.dy, t.vector.dx);
      // taper the wave near the arrow head so the head stays clean
      final taper = math.min(1.0, (total - d) / (wavelength * 1.2));
      final offset = normal * (math.sin(d / wavelength * 2 * math.pi) *
          amplitude *
          taper);
      final p = t.position + offset;
      if (i == 0) {
        out.moveTo(p.dx, p.dy);
      } else {
        out.lineTo(p.dx, p.dy);
      }
    }
    return out;
  }

  void _drawDashedPath(
    Canvas canvas,
    Path path,
    Paint paint, {
    required double dash,
    required double gap,
    double phase = 0,
  }) {
    final cycle = dash + gap;
    for (final metric in path.computeMetrics()) {
      // Negative start so dashes appear to flow from start to end.
      var distance = -cycle + (phase * cycle);
      while (distance < metric.length) {
        final from = math.max(0.0, distance);
        final to = math.min(distance + dash, metric.length);
        if (to > from) {
          canvas.drawPath(metric.extractPath(from, to), paint);
        }
        distance += cycle;
      }
    }
  }

  void _drawArrowHead(
    Canvas canvas,
    Offset tip,
    double angle,
    Color color, {
    required double size,
  }) {
    const headAngle = math.pi / 7;
    final p1 = Offset(
      tip.dx - size * math.cos(angle - headAngle),
      tip.dy - size * math.sin(angle - headAngle),
    );
    final p2 = Offset(
      tip.dx - size * math.cos(angle + headAngle),
      tip.dy - size * math.sin(angle + headAngle),
    );
    final back = Offset(
      tip.dx - size * 0.72 * math.cos(angle),
      tip.dy - size * 0.72 * math.sin(angle),
    );
    final path = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(p1.dx, p1.dy)
      ..lineTo(back.dx, back.dy)
      ..lineTo(p2.dx, p2.dy)
      ..close();
    canvas.drawShadow(path, Colors.black, 2, false);
    canvas.drawPath(path, Paint()..color = color);
  }

  void _drawChevron(
    Canvas canvas,
    Offset tip,
    double angle,
    Color color,
    double width, {
    required double offset,
  }) {
    final t = Offset(
      tip.dx - offset * math.cos(angle),
      tip.dy - offset * math.sin(angle),
    );
    final size = width * 2.2;
    const a = math.pi / 4;
    final p1 = Offset(t.dx - size * math.cos(angle - a), t.dy - size * math.sin(angle - a));
    final p2 = Offset(t.dx - size * math.cos(angle + a), t.dy - size * math.sin(angle + a));
    canvas.drawPath(
      Path()
        ..moveTo(p1.dx, p1.dy)
        ..lineTo(t.dx, t.dy)
        ..lineTo(p2.dx, p2.dy),
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = width * 0.8
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  void _drawStepBadge(Canvas canvas, Offset at, int step, Color color) {
    final r = math.max(8.0, _unit * 0.018);
    final center = at + Offset(-r * 1.1, -r * 1.1);
    canvas.drawCircle(center, r, Paint()..color = const Color(0xE60B1220));
    canvas.drawCircle(
      center,
      r,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    final tp = TextPainter(
      text: TextSpan(
        text: '$step',
        style: TextStyle(
          color: Colors.white,
          fontSize: r * 1.1,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  void _drawPill(Canvas canvas, String text, Offset topCenter, Color color) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: Colors.white,
          fontSize: math.max(10, _unit * 0.026),
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
      ellipsis: '…',
    )..layout(maxWidth: _unit * 0.5);
    final rect = Rect.fromCenter(
      center: topCenter,
      width: tp.width + 14,
      height: tp.height + 6,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(999)),
      Paint()..color = color.withValues(alpha: 0.9),
    );
    tp.paint(canvas, rect.center - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant AnnotationsPainter oldDelegate) {
    return oldDelegate.zones != zones ||
        oldDelegate.highlights != highlights ||
        oldDelegate.arrows != arrows ||
        oldDelegate.draft != draft ||
        oldDelegate.flowPhase != flowPhase ||
        oldDelegate.animateFlow != animateFlow ||
        oldDelegate.reveal != reveal ||
        oldDelegate.selectedIds != selectedIds ||
        oldDelegate.focusStep != focusStep ||
        oldDelegate.showStepBadges != showStepBadges ||
        oldDelegate.draftColor != draftColor ||
        oldDelegate.layout.rect != layout.rect;
  }
}
