import 'dart:math' as math;

import 'package:captain/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class TacticalBoardSpinner extends StatefulWidget {
  const TacticalBoardSpinner({super.key});

  @override
  State<TacticalBoardSpinner> createState() => _TacticalBoardSpinnerState();
}

class _TacticalBoardSpinnerState extends State<TacticalBoardSpinner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 180,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _PitchSpinnerPainter(progress: _controller.value),
          );
        },
      ),
    );
  }
}

class _PitchSpinnerPainter extends CustomPainter {
  _PitchSpinnerPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final pitchPaint = Paint()
      ..color = AppColors.pitchGreen
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(12)),
      pitchPaint,
    );

    final linePaint = Paint()
      ..color = AppColors.pitchLine
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawRect(rect.deflate(8), linePaint);
    canvas.drawLine(
      Offset(size.width / 2, 8),
      Offset(size.width / 2, size.height - 8),
      linePaint,
    );

    final tokenPaint = Paint()..color = const Color(0xFF00C853);
    for (var index = 0; index < 5; index++) {
      final angle = (progress * math.pi * 2) + (index * 1.2566);
      final cx = size.width / 2 +
          (size.width * 0.22 * (index.isEven ? 1 : -1)) *
              math.sin(angle + index);
      final cy = size.height * 0.35 + (index * 16) + (10 * math.cos(angle));
      canvas.drawCircle(Offset(cx, cy), 8, tokenPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _PitchSpinnerPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
