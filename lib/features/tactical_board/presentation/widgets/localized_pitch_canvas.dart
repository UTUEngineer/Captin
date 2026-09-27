import 'package:flutter/material.dart';

class LocalizedPitchCanvas extends StatelessWidget {
  final List<Offset> players;
  final Function(int index, Offset newPos) onPlayerMoved;

  const LocalizedPitchCanvas({
    super.key,
    required this.players,
    required this.onPlayerMoved,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final canvasWidth = constraints.maxWidth;
        final canvasHeight = constraints.maxHeight;

        return GestureDetector(
          onPanUpdate: (details) {
            // Find closest player to drag
            final localX = details.localPosition.dx / canvasWidth;
            final localY = details.localPosition.dy / canvasHeight;

            int closestIndex = -1;
            double minDistance = 0.05; // Hit slop threshold

            for (int i = 0; i < players.length; i++) {
              final d = (players[i] - Offset(localX, localY)).distance;
              if (d < minDistance) {
                minDistance = d;
                closestIndex = i;
              }
            }

            if (closestIndex != -1) {
              onPlayerMoved(
                closestIndex,
                Offset(localX.clamp(0.0, 1.0), localY.clamp(0.0, 1.0)),
              );
            }
          },
          child: CustomPaint(
            size: Size(canvasWidth, canvasHeight),
            painter: FootballPitchPainter(players: players),
          ),
        );
      },
    );
  }
}

class FootballPitchPainter extends CustomPainter {
  final List<Offset> players;

  FootballPitchPainter({required this.players});

  @override
  void paint(Canvas canvas, Size size) {
    final grassPaint = Paint()
      ..color = const Color(0xFF1B4332)
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final playerPaint = Paint()
      ..color = const Color(0xFF3B82F6)
      ..style = PaintingStyle.fill;

    // 1. Draw Pitch Surface & Markings (Standard LTR)
    canvas.drawRect(Offset.zero & size, grassPaint);
    canvas.drawRect(Rect.fromLTWH(12, 12, size.width - 24, size.height - 24), linePaint);
    
    // Halfway line & Center Circle
    canvas.drawLine(
      Offset(size.width / 2, 12),
      Offset(size.width / 2, size.height - 12),
      linePaint,
    );
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), size.height * 0.15, linePaint);

    // 2. Draw Players
    for (final player in players) {
      final screenPos = Offset(player.dx * size.width, player.dy * size.height);
      canvas.drawCircle(screenPos, 12, playerPaint);
      canvas.drawCircle(screenPos, 12, linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant FootballPitchPainter oldDelegate) => true;
}
