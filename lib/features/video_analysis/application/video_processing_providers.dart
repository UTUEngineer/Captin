import 'package:captain/features/video_analysis/application/video_processing_notifier.dart';
import 'package:captain/features/video_analysis/application/video_analysis_providers.dart';
import 'package:captain/features/video_analysis/data/local_video_job_store.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final videoProcessingProvider = StateNotifierProvider.autoDispose
    .family<VideoProcessingNotifier, VideoProcessingState, LocalVideoJobStore>(
  (ref, jobStore) {
    final repository = ref.watch(videoAnalysisRepositoryProvider);
    return VideoProcessingNotifier(
      repository: repository,
      jobStore: jobStore,
    );
  },
);
