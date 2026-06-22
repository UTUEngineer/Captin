import 'package:captain/core/router/app_router.dart';
import 'package:captain/core/theme/app_colors.dart';
import 'package:captain/features/video_analysis/application/video_calibration_providers.dart';
import 'package:captain/features/video_analysis/domain/video_processing_args.dart';
import 'package:captain/features/video_analysis/presentation/widgets/calibration_frame_view.dart';
import 'package:captain/features/video_analysis/presentation/widgets/penalty_box_reference_diagram.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class VideoCalibrationScreen extends ConsumerWidget {
  const VideoCalibrationScreen({
    super.key,
    required this.videoId,
  });

  final String videoId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(videoCalibrationProvider(videoId));
    final notifier = ref.read(videoCalibrationProvider(videoId).notifier);

    ref.listen(videoCalibrationProvider(videoId), (previous, next) {
      if (next.submitSucceeded) {
        context.go(
          AppRoutes.analyzeVideoProcessing,
          extra: VideoProcessingArgs.continueAfterCalibration(
            videoId: videoId,
            label: 'Video analysis',
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pitch calibration'),
        actions: [
          TextButton(
            onPressed: state.pins.isEmpty ? null : notifier.resetPins,
            child: const Text('Reset'),
          ),
        ],
      ),
      body: state.isLoadingFrame
          ? const Center(child: CircularProgressIndicator())
          : state.loadError != null
              ? _CalibrationMessageView(
                  message: state.loadError!,
                  actionLabel: 'Retry',
                  onAction: notifier.loadFrame,
                )
              : SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child: _InstructionBanner(message: state.nextStepLabel),
                      ),
                      if (state.submitError != null)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                          child: _ErrorBanner(message: state.submitError!),
                        ),
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final showSideBySide = constraints.maxWidth >= 760;
                            if (showSideBySide) {
                              return Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: CalibrationFrameView(
                                        state: state,
                                        onTapNormalized:
                                            notifier.addPinAtNormalized,
                                        onPinMoved: notifier.movePin,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    const Expanded(
                                      child: SingleChildScrollView(
                                        child: PenaltyBoxReferenceDiagram(),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }

                            return ListView(
                              padding: const EdgeInsets.all(16),
                              children: [
                                SizedBox(
                                  height: 280,
                                  child: CalibrationFrameView(
                                    state: state,
                                    onTapNormalized:
                                        notifier.addPinAtNormalized,
                                    onPinMoved: notifier.movePin,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const PenaltyBoxReferenceDiagram(),
                              ],
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: ElevatedButton.icon(
                          onPressed: state.canSubmit && !state.isSubmitting
                              ? notifier.submitCalibration
                              : null,
                          icon: state.isSubmitting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.check_circle_outline),
                          label: Text(
                            state.isSubmitting
                                ? 'Submitting calibration…'
                                : 'Confirm calibration',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}

class _InstructionBanner extends StatelessWidget {
  const _InstructionBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.touch_app_outlined,
            color: AppColors.pitchGreenLight,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary,
                    height: 1.4,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.accentRed.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accentRed),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, color: AppColors.accentRed, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary,
                    height: 1.4,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CalibrationMessageView extends StatelessWidget {
  const _CalibrationMessageView({
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.broken_image_outlined, size: 48),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onAction, child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }
}
