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

  @override
  void initState() {
    super.initState();
    final slots = formationSlotsFor(FormationType.f433);
    _targetPositions =
        slots.map((slot) => Offset(slot.x, slot.y)).toList(growable: false);
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
      duration: const Duration(milliseconds: 2200),
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
      aspectRatio: 0.68,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _OnboardingPitchPainter(
              progress: Curves.easeInOut.transform(_controller.value),
              startPositions: _startPositions,
              targetPositions: _targetPositions,
            ),
          );
        },
      ),
    );
  }
}

class _OnboardingPitchPainter extends CustomPainter {
  _OnboardingPitchPainter({
    required this.progress,
    required this.startPositions,
    required this.targetPositions,
  });

  final double progress;
  final List<Offset> startPositions;
  final List<Offset> targetPositions;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(18),
    );
    final pitchPaint = Paint()..color = AppColors.pitchGreen;
    canvas.drawRRect(rect, pitchPaint);

    final linePaint = Paint()
      ..color = AppColors.pitchLine
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRRect(rect.deflate(12), linePaint);
    canvas.drawLine(
      Offset(12, size.height / 2),
      Offset(size.width - 12, size.height / 2),
      linePaint,
    );

    for (var i = 0; i < targetPositions.length; i++) {
      final start = startPositions[i];
      final target = targetPositions[i];
      final position = Offset(
        (start.dx + (target.dx - start.dx) * progress) * size.width,
        (start.dy + (target.dy - start.dy) * progress) * size.height,
      );
      canvas.drawCircle(
        position,
        10,
        Paint()..color = AppColors.pitchGreenLight,
      );
      canvas.drawCircle(
        position,
        10,
        Paint()
          ..color = AppColors.textPrimary
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _OnboardingPitchPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
