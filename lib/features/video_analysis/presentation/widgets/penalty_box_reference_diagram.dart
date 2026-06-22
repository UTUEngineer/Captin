import 'package:captain/core/theme/app_colors.dart';
import 'package:captain/features/video_analysis/domain/standard_penalty_box_calibration.dart';
import 'package:flutter/material.dart';

class PenaltyBoxReferenceDiagram extends StatelessWidget {
  const PenaltyBoxReferenceDiagram({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Reference: one penalty box',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Mark the same four corners on the video frame in this order.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          AspectRatio(
            aspectRatio: 105 / 68,
            child: CustomPaint(
              painter: _PenaltyBoxReferencePainter(),
            ),
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < StandardPenaltyBoxCalibration.cornerLabels.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  _CornerBadge(number: i + 1),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      StandardPenaltyBoxCalibration.cornerLabels[i],
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textPrimary,
                          ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _CornerBadge extends StatelessWidget {
  const _CornerBadge({required this.number});

  final int number;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.accentOrange,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.textPrimary, width: 1.5),
      ),
      child: Text(
        '$number',
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _PenaltyBoxReferencePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.pitchGreenLight
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final fill = Paint()
      ..color = AppColors.accentOrange.withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;

    final pitch = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(8),
    );
    canvas.drawRRect(pitch, Paint()..color = AppColors.pitchGreen.withValues(alpha: 0.35));
    canvas.drawRRect(pitch, paint);

    final boxWidth = size.width * 0.165;
    final boxHeight = size.height * 0.105;
    final box = Rect.fromLTWH(0, 0, boxWidth, boxHeight);
    canvas.drawRect(box, fill);
    canvas.drawRect(box, paint..color = AppColors.accentOrange);

    _drawCorner(canvas, box.topLeft, 1);
    _drawCorner(canvas, box.topRight, 2);
    _drawCorner(canvas, box.bottomRight, 3);
    _drawCorner(canvas, box.bottomLeft, 4);
  }

  void _drawCorner(Canvas canvas, Offset point, int number) {
    canvas.drawCircle(
      point,
      6,
      Paint()..color = AppColors.accentOrange,
    );
    final textPainter = TextPainter(
      text: TextSpan(
        text: '$number',
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      point - Offset(textPainter.width / 2, textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
