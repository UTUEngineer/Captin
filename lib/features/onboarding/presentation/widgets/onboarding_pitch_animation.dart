import 'dart:math' as math;

import 'package:captain/core/theme/app_colors.dart';
import 'package:captain/features/tactical_board/domain/formation.dart';
import 'package:captain/features/tactical_board/domain/formation_presets.dart';
import 'package:flutter/material.dart';

class OnboardingPitchAnimation extends StatefulWidget {
  const OnboardingPitchAnimation({super.key});

  @override
  State<OnboardingPitchAnimation> createState() =>
      _OnboardingPitchAnimationState();
}

class _OnboardingPitchAnimationState extends State<OnboardingPitchAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<Offset> _startPositions;
  late final List<Offset> _targetPositions;
  late final List<FormationSlot> _slots;

  @override
  void initState() {
    super.initState();
    _slots = formationSlotsFor(FormationType.f433);
    _targetPositions =
        _slots.map((slot) => Offset(slot.x, slot.y)).toList(growable: false);
    _startPositions = List<Offset>.generate(
      _targetPositions.length,
      (index) {
        final angle = index / _targetPositions.length * math.pi * 2;
        return Offset(
          0.5 + math.cos(angle) * 0.28,
          0.5 + math.sin(angle) * 0.28,
        );
      },
      growable: false,
    );
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 0.72,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.pitchGreenLight.withValues(alpha: 0.15),
              blurRadius: 32,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: _ProTacticalPitchPainter(
                progress: Curves.easeInOutCubic.transform(_controller.value),
                startPositions: _startPositions,
                targetPositions: _targetPositions,
                slots: _slots,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ProTacticalPitchPainter extends CustomPainter {
  _ProTacticalPitchPainter({
    required this.progress,
    required this.startPositions,
    required this.targetPositions,
    required this.slots,
  });

  final double progress;
  final List<Offset> startPositions;
  final List<Offset> targetPositions;
  final List<FormationSlot> slots;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final fullRect = Offset.zero & size;

    // -------------------------------------------------------------------------
    // 1. Alternating Grass Mowing Stripes (Premier League Style)
    // -------------------------------------------------------------------------
    const stripeCount = 12;
    final stripeHeight = h / stripeCount;
    final baseColor1 = const Color(0xFF134224);
    final baseColor2 = const Color(0xFF0F361C);

    for (var i = 0; i < stripeCount; i++) {
      final stripeRect = Rect.fromLTWH(0, i * stripeHeight, w, stripeHeight);
      final stripePaint = Paint()
        ..color = (i % 2 == 0) ? baseColor1 : baseColor2;
      canvas.drawRect(stripeRect, stripePaint);
    }

    // Stadium Floodlight Vignette Radial Overlay
    final vignettePaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 0.85,
        colors: [
          Colors.white.withValues(alpha: 0.08),
          Colors.black.withValues(alpha: 0.35),
        ],
        stops: const [0.3, 1.0],
      ).createShader(fullRect);
    canvas.drawRect(fullRect, vignettePaint);

    // -------------------------------------------------------------------------
    // 2. Pitch Boundary and Precision Field Markings
    // -------------------------------------------------------------------------
    const margin = 14.0;
    final pitchRect = Rect.fromLTWH(
      margin,
      margin,
      w - (margin * 2),
      h - (margin * 2),
    );

    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.88)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Outer Pitch Boundary
    canvas.drawRect(pitchRect, linePaint);

    // Halfway Line
    final midY = pitchRect.top + (pitchRect.height / 2);
    canvas.drawLine(
      Offset(pitchRect.left, midY),
      Offset(pitchRect.right, midY),
      linePaint,
    );

    // Center Circle & Center Spot
    final center = Offset(w / 2, midY);
    final centerCircleRadius = pitchRect.width * 0.17;
    canvas.drawCircle(center, centerCircleRadius, linePaint);

    final spotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 3.5, spotPaint);

    // -------------------------------------------------------------------------
    // 3. Penalty Boxes, Goal Areas, and Arcs (Top and Bottom)
    // -------------------------------------------------------------------------
    final penaltyBoxWidth = pitchRect.width * 0.54;
    final penaltyBoxHeight = pitchRect.height * 0.16;
    final penaltyBoxLeft = pitchRect.left + (pitchRect.width - penaltyBoxWidth) / 2;

    final goalAreaWidth = pitchRect.width * 0.28;
    final goalAreaHeight = pitchRect.height * 0.06;
    final goalAreaLeft = pitchRect.left + (pitchRect.width - goalAreaWidth) / 2;

    // Top Penalty Area (Away)
    final topPenaltyRect = Rect.fromLTWH(
      penaltyBoxLeft,
      pitchRect.top,
      penaltyBoxWidth,
      penaltyBoxHeight,
    );
    canvas.drawRect(topPenaltyRect, linePaint);

    // Top Goal Area (6-yard)
    final topGoalAreaRect = Rect.fromLTWH(
      goalAreaLeft,
      pitchRect.top,
      goalAreaWidth,
      goalAreaHeight,
    );
    canvas.drawRect(topGoalAreaRect, linePaint);

    // Top Penalty Spot & Arc
    final topSpotY = pitchRect.top + penaltyBoxHeight * 0.72;
    canvas.drawCircle(Offset(w / 2, topSpotY), 3.0, spotPaint);
    canvas.drawArc(
      Rect.fromCircle(
        center: Offset(w / 2, topSpotY),
        radius: centerCircleRadius * 0.75,
      ),
      0.15 * math.pi,
      0.70 * math.pi,
      false,
      linePaint,
    );

    // Bottom Penalty Area (Home)
    final bottomPenaltyRect = Rect.fromLTWH(
      penaltyBoxLeft,
      pitchRect.bottom - penaltyBoxHeight,
      penaltyBoxWidth,
      penaltyBoxHeight,
    );
    canvas.drawRect(bottomPenaltyRect, linePaint);

    // Bottom Goal Area (6-yard)
    final bottomGoalAreaRect = Rect.fromLTWH(
      goalAreaLeft,
      pitchRect.bottom - goalAreaHeight,
      goalAreaWidth,
      goalAreaHeight,
    );
    canvas.drawRect(bottomGoalAreaRect, linePaint);

    // Bottom Penalty Spot & Arc
    final bottomSpotY = pitchRect.bottom - penaltyBoxHeight * 0.72;
    canvas.drawCircle(Offset(w / 2, bottomSpotY), 3.0, spotPaint);
    canvas.drawArc(
      Rect.fromCircle(
        center: Offset(w / 2, bottomSpotY),
        radius: centerCircleRadius * 0.75,
      ),
      1.15 * math.pi,
      0.70 * math.pi,
      false,
      linePaint,
    );

    // Corner Arcs (4 corners)
    const cornerRadius = 10.0;
    canvas.drawArc(
      Rect.fromCircle(center: pitchRect.topLeft, radius: cornerRadius),
      0,
      math.pi / 2,
      false,
      linePaint,
    );
    canvas.drawArc(
      Rect.fromCircle(center: pitchRect.topRight, radius: cornerRadius),
      math.pi / 2,
      math.pi / 2,
      false,
      linePaint,
    );
    canvas.drawArc(
      Rect.fromCircle(center: pitchRect.bottomLeft, radius: cornerRadius),
      -math.pi / 2,
      math.pi / 2,
      false,
      linePaint,
    );
    canvas.drawArc(
      Rect.fromCircle(center: pitchRect.bottomRight, radius: cornerRadius),
      math.pi,
      math.pi / 2,
      false,
      linePaint,
    );

    // -------------------------------------------------------------------------
    // 4. Tactical Connections / Passing Lines
    // -------------------------------------------------------------------------
    final currentPositions = <Offset>[];
    for (var i = 0; i < targetPositions.length; i++) {
      final s = startPositions[i];
      final t = targetPositions[i];
      currentPositions.add(
        Offset(
          (s.dx + (t.dx - s.dx) * progress) * w,
          (s.dy + (t.dy - s.dy) * progress) * h,
        ),
      );
    }

    // Connect Midfield & Attackers with dynamic dashed tactical lines
    if (currentPositions.length >= 11) {
      final passingLinesPaint = Paint()
        ..color = AppColors.primary.withValues(alpha: 0.35 * progress)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;

      // DM/CM triangle (slots 5, 6, 7)
      final p6 = currentPositions[5];
      final p7 = currentPositions[6];
      final p8 = currentPositions[7];
      final pathTriangle = Path()
        ..moveTo(p6.dx, p6.dy)
        ..lineTo(p7.dx, p7.dy)
        ..lineTo(p8.dx, p8.dy)
        ..close();
      canvas.drawPath(pathTriangle, passingLinesPaint);

      // Connect to Strikers (slots 8, 9, 10)
      final p9 = currentPositions[8];
      final p10 = currentPositions[9];
      final p11 = currentPositions[10];
      canvas.drawLine(p7, p10, passingLinesPaint);
      canvas.drawLine(p6, p9, passingLinesPaint);
      canvas.drawLine(p8, p11, passingLinesPaint);
    }

    // -------------------------------------------------------------------------
    // 5. Smart Tactical Player Nodes
    // -------------------------------------------------------------------------
    for (var i = 0; i < currentPositions.length; i++) {
      final pos = currentPositions[i];
      final slot = slots[i];
      final isGk = slot.label == 'GK';
      const radius = 13.0;

      // Drop shadow beneath token for depth
      canvas.drawCircle(
        pos + const Offset(0, 3.5),
        radius,
        Paint()
          ..color = Colors.black.withValues(alpha: 0.45)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0),
      );

      // Token gradient background (Electric Emerald for outfield, Gold for GK)
      final tokenGradient = RadialGradient(
        colors: isGk
            ? [const Color(0xFFFFD54F), const Color(0xFFFF8F00)]
            : [AppColors.primary, const Color(0xFF00897B)],
      ).createShader(Rect.fromCircle(center: pos, radius: radius));

      canvas.drawCircle(
        pos,
        radius,
        Paint()
          ..shader = tokenGradient
          ..style = PaintingStyle.fill,
      );

      // Outer crisp white ring
      canvas.drawCircle(
        pos,
        radius,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8,
      );

      // Player Position/Number Label
      final label = slot.label ?? '${slot.number}';
      final textSpan = TextSpan(
        text: label,
        style: TextStyle(
          color: isGk ? const Color(0xFF261D00) : Colors.black,
          fontSize: label.length > 2 ? 8.5 : 9.5,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.2,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        Offset(
          pos.dx - (textPainter.width / 2),
          pos.dy - (textPainter.height / 2),
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ProTacticalPitchPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
