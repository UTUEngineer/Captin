import 'package:captain/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class HeatmapOverlayPainter extends CustomPainter {
  HeatmapOverlayPainter({required this.grid});

  final List<List<double>> grid;

  @override
  void paint(Canvas canvas, Size size) {
    if (grid.isEmpty) return;

    final rows = grid.length;
    final cols = grid.first.length;
    final cellWidth = size.width / cols;
    final cellHeight = size.height / rows;

    for (var row = 0; row < rows; row++) {
      for (var col = 0; col < cols; col++) {
        final intensity = grid[row][col].clamp(0.0, 1.0);
        if (intensity <= 0.01) continue;

        final paint = Paint()
          ..color = Color.lerp(
            AppColors.accentOrange.withValues(alpha: 0.05),
            AppColors.accentRed.withValues(alpha: 0.55),
            intensity,
          )!;
        canvas.drawRect(
          Rect.fromLTWH(col * cellWidth, row * cellHeight, cellWidth, cellHeight),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant HeatmapOverlayPainter oldDelegate) {
    return oldDelegate.grid != grid;
  }
}
