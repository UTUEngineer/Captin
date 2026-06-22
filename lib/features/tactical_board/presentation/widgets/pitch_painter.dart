import 'dart:math' as math;

import 'package:captain/core/theme/app_colors.dart';
import 'package:captain/features/tactical_board/domain/pitch_orientation.dart';
import 'package:captain/features/tactical_board/domain/pitch_style.dart';
import 'package:flutter/material.dart';

/// FIFA pitch ratio: length 105m, width 68m.
const double pitchAspectRatio = 105 / 68;

class PitchPainter extends CustomPainter {
  PitchPainter({
    required this.orientation,
    required this.style,
  });

  final PitchOrientation orientation;
  final PitchStyle style;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    _drawSurface(canvas, rect);
    _drawMarkings(canvas, rect);
  }

  void _drawSurface(Canvas canvas, Rect rect) {
    if (style.isStriped) {
      const stripeCount = 12;
      final stripeHeight = rect.height / stripeCount;
      for (var i = 0; i < stripeCount; i++) {
        final color = i.isEven ? AppColors.pitchGreen : AppColors.pitchGreenLight;
        canvas.drawRect(
          Rect.fromLTWH(rect.left, rect.top + i * stripeHeight, rect.width, stripeHeight),
          Paint()..color = color,
        );
      }
    } else {
      canvas.drawRect(rect, Paint()..color = AppColors.pitchGreen);
    }
  }

  void _drawMarkings(Canvas canvas, Rect rect) {
    final linePaint = Paint()
      ..color = AppColors.pitchLine
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.5, rect.shortestSide * 0.003);

    canvas.drawRect(rect.deflate(linePaint.strokeWidth / 2), linePaint);

    final center = rect.center;
    canvas.drawLine(
      Offset(rect.left, center.dy),
      Offset(rect.right, center.dy),
      linePaint,
    );

    final centerCircleRadius = rect.width * 0.12;
    canvas.drawCircle(center, centerCircleRadius, linePaint);
    canvas.drawCircle(center, linePaint.strokeWidth * 1.5, Paint()..color = AppColors.pitchLine);

    _drawPenaltyArea(canvas, rect, isTop: true, linePaint: linePaint);
    _drawPenaltyArea(canvas, rect, isTop: false, linePaint: linePaint);
  }

  void _drawPenaltyArea(
    Canvas canvas,
    Rect rect, {
    required bool isTop,
    required Paint linePaint,
  }) {
    final penaltyDepth = rect.height * 0.16;
    final penaltyWidth = rect.width * 0.6;
    final goalAreaDepth = rect.height * 0.06;
    final goalAreaWidth = rect.width * 0.32;
    final arcRadius = rect.width * 0.12;

    final goalLineY = isTop ? rect.top : rect.bottom;
    final direction = isTop ? 1.0 : -1.0;

    final penaltyLeft = rect.center.dx - penaltyWidth / 2;
    final penaltyRect = Rect.fromLTWH(
      penaltyLeft,
      isTop ? goalLineY : goalLineY - penaltyDepth,
      penaltyWidth,
      penaltyDepth,
    );
    canvas.drawRect(penaltyRect, linePaint);

    final goalLeft = rect.center.dx - goalAreaWidth / 2;
    final goalRect = Rect.fromLTWH(
      goalLeft,
      isTop ? goalLineY : goalLineY - goalAreaDepth,
      goalAreaWidth,
      goalAreaDepth,
    );
    canvas.drawRect(goalRect, linePaint);

    final spotY = goalLineY + direction * penaltyDepth * 0.66;
    canvas.drawCircle(
      Offset(rect.center.dx, spotY),
      linePaint.strokeWidth * 1.5,
      Paint()..color = AppColors.pitchLine,
    );

    final arcCenter = Offset(rect.center.dx, spotY);
    final arcRect = Rect.fromCircle(center: arcCenter, radius: arcRadius);
    final startAngle = isTop ? math.pi * 0.35 : -math.pi * 0.65;
    const sweepAngle = math.pi * 0.3;
    canvas.drawArc(arcRect, startAngle, sweepAngle, false, linePaint);
  }

  @override
  bool shouldRepaint(covariant PitchPainter oldDelegate) {
    return oldDelegate.orientation != orientation || oldDelegate.style != style;
  }
}

class PitchLayout {
  const PitchLayout({
    required this.rect,
    required this.orientation,
    required this.tokenSize,
  });

  final Rect rect;
  final PitchOrientation orientation;
  final double tokenSize;

  static PitchLayout compute({
    required Size constraints,
    required PitchOrientation orientation,
  }) {
    const padding = 16.0;
    final availableWidth = constraints.width - padding * 2;
    final availableHeight = constraints.height - padding * 2;

    late Size pitchSize;
    if (orientation.isVertical) {
      pitchSize = _fitSize(
        maxWidth: availableWidth,
        maxHeight: availableHeight,
        aspect: 1 / pitchAspectRatio,
      );
    } else {
      pitchSize = _fitSize(
        maxWidth: availableWidth,
        maxHeight: availableHeight,
        aspect: pitchAspectRatio,
      );
    }

    final left = (constraints.width - pitchSize.width) / 2;
    final top = (constraints.height - pitchSize.height) / 2;
    final rect = Rect.fromLTWH(left, top, pitchSize.width, pitchSize.height);
    final tokenSize =
        math.max(28.0, math.min(pitchSize.shortestSide * 0.09, 52.0));

    return PitchLayout(
      rect: rect,
      orientation: orientation,
      tokenSize: tokenSize,
    );
  }

  static Size _fitSize({
    required double maxWidth,
    required double maxHeight,
    required double aspect,
  }) {
    var width = maxWidth;
    var height = width / aspect;
    if (height > maxHeight) {
      height = maxHeight;
      width = height * aspect;
    }
    return Size(width, height);
  }

  Offset positionFor(double x, double y) {
    if (orientation.isVertical) {
      return Offset(
        rect.left + x * rect.width,
        rect.top + y * rect.height,
      );
    }

    return Offset(
      rect.left + y * rect.width,
      rect.top + (1 - x) * rect.height,
    );
  }

  ({double x, double y}) relativeFor(Offset globalPosition) {
    final localX = ((globalPosition.dx - rect.left) / rect.width).clamp(0.0, 1.0);
    final localY = ((globalPosition.dy - rect.top) / rect.height).clamp(0.0, 1.0);

    if (orientation.isVertical) {
      return (x: localX, y: localY);
    }

    return (x: 1 - localY, y: localX);
  }

  ({double x, double y}) clampRelative({
    required double x,
    required double y,
  }) {
    final marginX = (tokenSize / 2) / rect.width;
    final marginY = (tokenSize / 2) / rect.height;

    return (
      x: x.clamp(marginX, 1 - marginX),
      y: y.clamp(marginY, 1 - marginY),
    );
  }
}
