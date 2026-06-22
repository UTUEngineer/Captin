import 'dart:async';

import 'package:captain/core/router/app_router.dart';
import 'package:captain/core/theme/app_colors.dart';
import 'package:captain/features/video_analysis/application/recent_analyses_providers.dart';
import 'package:captain/features/video_analysis/application/video_processing_notifier.dart';
import 'package:captain/features/video_analysis/application/video_processing_providers.dart';
import 'package:captain/features/video_analysis/data/local_video_job_store.dart';
import 'package:captain/features/video_analysis/domain/video_processing_args.dart';
import 'package:captain/features/video_analysis/domain/video_processing_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class VideoProcessingScreen extends ConsumerStatefulWidget {
  const VideoProcessingScreen({
    super.key,
    required this.args,
  });

  final VideoProcessingArgs args;

  @override
  ConsumerState<VideoProcessingScreen> createState() =>
      _VideoProcessingScreenState();
}

class _VideoProcessingScreenState extends ConsumerState<VideoProcessingScreen> {
  var _started = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    if (_started || !mounted) return;
    final store = await ref.read(localVideoJobStoreProvider.future);
    if (!mounted) return;
    _started = true;
    await ref
        .read(videoProcessingProvider(store).notifier)
        .start(widget.args);
  }

  Future<void> _confirmCancel() async {
    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Stop monitoring?'),
        content: const Text(
          'Analysis will continue on the server, but this screen will stop '
          'checking for updates. You can resume later from Home.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep waiting'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Stop monitoring'),
          ),
        ],
      ),
    );

    if (shouldCancel != true || !mounted) return;
    final store = await ref.read(localVideoJobStoreProvider.future);
    ref.read(videoProcessingProvider(store).notifier).cancel();
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final storeAsync = ref.watch(localVideoJobStoreProvider);

    return storeAsync.when(
      data: (store) {
        final processingState = ref.watch(videoProcessingProvider(store));

        ref.listen<VideoProcessingState>(
          videoProcessingProvider(store),
          (previous, next) {
            if (!mounted) return;

            if (next.serverStatus == VideoProcessingStatus.needsCalibration &&
                next.videoId != null) {
              context.go(AppRoutes.videoCalibration(next.videoId!));
              return;
            }

            if (next.phase == VideoProcessingPhase.completed &&
                next.videoId != null) {
              unawaited(
                ref.read(recentAnalysesProvider.notifier).recordCompleted(
                      videoId: next.videoId!,
                      label: next.jobLabel ?? 'Video analysis',
                    ),
              );
              context.go(AppRoutes.videoResult(next.videoId!));
            }
          },
        );

        return Scaffold(
          appBar: AppBar(
            title: const Text('Analyzing video'),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: processingState.isTerminal
                  ? () => context.pop()
                  : _confirmCancel,
            ),
          ),
          body: _ProcessingBody(
            state: processingState,
            onCancel: _confirmCancel,
            onRetry: () => context.go(AppRoutes.analyzeVideo),
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: const Text('Analyzing video')),
        body: _ProcessingErrorView(
          message: error.toString(),
          onRetry: () => context.go(AppRoutes.analyzeVideo),
        ),
      ),
    );
  }
}

class _ProcessingBody extends StatelessWidget {
  const _ProcessingBody({
    required this.state,
    required this.onCancel,
    required this.onRetry,
  });

  final VideoProcessingState state;
  final VoidCallback onCancel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return switch (state.phase) {
      VideoProcessingPhase.failed => _ProcessingErrorView(
          message: state.failureMessage ?? 'Video analysis failed.',
          onRetry: onRetry,
        ),
      VideoProcessingPhase.cancelled => _ProcessingErrorView(
          message: state.statusMessage ?? 'Monitoring stopped.',
          onRetry: onRetry,
          retryLabel: 'Back to analyze',
        ),
      VideoProcessingPhase.completed => const Center(
          child: CircularProgressIndicator(),
        ),
      _ => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (state.jobLabel != null) ...[
                  Text(
                    state.jobLabel!,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                ],
                Text(
                  state.statusMessage ?? 'Working…',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 32),
                if (state.phase == VideoProcessingPhase.uploading) ...[
                  LinearProgressIndicator(
                    value: state.uploadProgress.clamp(0, 1),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(999),
                    backgroundColor: AppColors.surfaceElevated,
                    color: AppColors.pitchGreenLight,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Uploading… ${(state.uploadProgress * 100).clamp(0, 100).toStringAsFixed(0)}%',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ] else ...[
                  LinearProgressIndicator(
                    value: state.processingProgress.clamp(0, 100) / 100,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(999),
                    backgroundColor: AppColors.surfaceElevated,
                    color: AppColors.accentOrange,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${state.processingProgress.clamp(0, 100)}% complete',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
                const Spacer(),
                OutlinedButton(
                  onPressed: onCancel,
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ),
        ),
    };
  }
}

class _ProcessingErrorView extends StatelessWidget {
  const _ProcessingErrorView({
    required this.message,
    required this.onRetry,
    this.retryLabel = 'Try again',
  });

  final String message;
  final VoidCallback onRetry;
  final String retryLabel;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: AppColors.accentRed,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRetry,
              child: Text(retryLabel),
            ),
          ],
        ),
      ),
    );
  }
}
