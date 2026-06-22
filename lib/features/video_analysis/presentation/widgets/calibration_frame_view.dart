import 'package:captain/core/theme/app_colors.dart';
import 'package:captain/features/video_analysis/application/video_calibration_notifier.dart';
import 'package:flutter/material.dart';

class CalibrationFrameView extends StatelessWidget {
  const CalibrationFrameView({
    super.key,
    required this.state,
    required this.onTapNormalized,
    required this.onPinMoved,
  });

  final VideoCalibrationState state;
  final ValueChanged<Offset> onTapNormalized;
  final void Function(int index, Offset normalizedPosition) onPinMoved;

  @override
  Widget build(BuildContext context) {
    final bytes = state.frameBytes;
    if (bytes == null || state.imageWidth == 0 || state.imageHeight == 0) {
      return const SizedBox.shrink();
    }

    final aspectRatio = state.imageWidth / state.imageHeight;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: InteractiveViewer(
          minScale: 1,
          maxScale: 4,
          boundaryMargin: const EdgeInsets.all(80),
          child: AspectRatio(
            aspectRatio: aspectRatio,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final layoutSize = Size(
                  constraints.maxWidth,
                  constraints.maxHeight,
                );

                return GestureDetector(
                  onTapUp: (details) {
                    if (state.pins.length >= 4) return;
                    final box = context.findRenderObject() as RenderBox?;
                    if (box == null) return;
                    final local = box.globalToLocal(details.globalPosition);
                    onTapNormalized(
                      Offset(
                        (local.dx / layoutSize.width).clamp(0, 1),
                        (local.dy / layoutSize.height).clamp(0, 1),
                      ),
                    );
                  },
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.memory(
                        bytes,
                        fit: BoxFit.fill,
                        gaplessPlayback: true,
                      ),
                      ...state.pins.map(
                        (pin) => _DraggableCalibrationPin(
                          pin: pin,
                          layoutSize: layoutSize,
                          onMoved: (normalized) =>
                              onPinMoved(pin.index, normalized),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _DraggableCalibrationPin extends StatelessWidget {
  const _DraggableCalibrationPin({
    required this.pin,
    required this.layoutSize,
    required this.onMoved,
  });

  final PlacedCalibrationPin pin;
  final Size layoutSize;
  final ValueChanged<Offset> onMoved;

  @override
  Widget build(BuildContext context) {
    final position = pin.displayPosition(layoutSize);

    return Positioned(
      left: position.dx - 16,
      top: position.dy - 16,
      child: GestureDetector(
        onPanUpdate: (details) {
          onMoved(
            Offset(
              (pin.normalizedX + details.delta.dx / layoutSize.width)
                  .clamp(0, 1),
              (pin.normalizedY + details.delta.dy / layoutSize.height)
                  .clamp(0, 1),
            ),
          );
        },
        child: Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.accentOrange,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.textPrimary, width: 2),
            boxShadow: const [
              BoxShadow(
                color: Colors.black54,
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            '${pin.index + 1}',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
