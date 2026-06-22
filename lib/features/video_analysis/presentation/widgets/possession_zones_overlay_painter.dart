import 'package:captain/core/theme/app_colors.dart';
import 'package:captain/features/video_analysis/domain/analysis_result.dart';
import 'package:flutter/material.dart';

class PossessionZonesOverlayPainter extends CustomPainter {
  PossessionZonesOverlayPainter({required this.zones});

  final TeamPossessionZones zones;

  @override
  void paint(Canvas canvas, Size size) {
    final bands = [
      (label: 'Def', value: zones.defensive, top: 0.0, bottom: 1 / 3),
      (label: 'Mid', value: zones.middle, top: 1 / 3, bottom: 2 / 3),
      (label: 'Att', value: zones.attacking, top: 2 / 3, bottom: 1.0),
    ];

    for (final band in bands) {
      final rect = Rect.fromLTWH(
        0,
        size.height * band.top,
        size.width,
        size.height * (band.bottom - band.top),
      );
      canvas.drawRect(
        rect,
        Paint()
          ..color = AppColors.pitchGreenLight
              .withValues(alpha: 0.08 + band.value * 0.22),
      );
      canvas.drawRect(
        rect,
        Paint()
          ..style = PaintingStyle.stroke
          ..color = AppColors.pitchLine.withValues(alpha: 0.35),
      );
    }
  }

  @override
  bool shouldRepaint(covariant PossessionZonesOverlayPainter oldDelegate) {
    return oldDelegate.zones != zones;
  }
}
