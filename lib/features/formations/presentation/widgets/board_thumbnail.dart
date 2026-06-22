import 'dart:math' as math;

import 'package:captain/core/theme/app_colors.dart';
import 'package:captain/features/formations/domain/tactic_board_template.dart';
import 'package:captain/features/tactical_board/domain/pitch_orientation.dart';
import 'package:captain/features/tactical_board/domain/pitch_style.dart';
import 'package:captain/features/tactical_board/presentation/widgets/annotations_painter.dart';
import 'package:captain/features/tactical_board/presentation/widgets/pitch_painter.dart';
import 'package:flutter/material.dart';

class BoardThumbnail extends StatelessWidget {
  const BoardThumbnail({
    super.key,
    required this.template,
    this.width = 160,
    this.height = 104,
  });

  final TacticBoardTemplate template;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: width,
        height: height,
        child: CustomPaint(
          painter: _BoardThumbnailPainter(template: template),
        ),
      ),
    );
  }
}

class _BoardThumbnailPainter extends CustomPainter {
  _BoardThumbnailPainter({required this.template});

  final TacticBoardTemplate template;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final layout = PitchLayout(
      rect: rect,
      orientation: PitchOrientation.vertical,
      tokenSize: size.shortestSide * 0.08,
    );

    PitchPainter(
      orientation: PitchOrientation.vertical,
      style: PitchStyle.striped,
    ).paint(canvas, size);

    AnnotationsPainter(
      layout: layout,
      zones: template.zones,
      highlights: template.highlights,
      arrows: template.arrows,
    ).paint(canvas, size);

    for (final player in template.players) {
      final center = layout.positionFor(player.x, player.y);
      final radius = layout.tokenSize * 0.38;
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = player.isHomeTeam
              ? AppColors.pitchGreenLight
              : AppColors.accentRed,
      );
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.8)
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(1, radius * 0.15),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BoardThumbnailPainter oldDelegate) {
    return oldDelegate.template != template;
  }
}
