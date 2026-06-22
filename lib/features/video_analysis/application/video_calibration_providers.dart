import 'package:captain/features/video_analysis/application/video_analysis_providers.dart';
import 'package:captain/features/video_analysis/application/video_calibration_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final videoCalibrationProvider = StateNotifierProvider.autoDispose
    .family<VideoCalibrationNotifier, VideoCalibrationState, String>(
  (ref, videoId) {
    final repository = ref.watch(videoAnalysisRepositoryProvider);
    return VideoCalibrationNotifier(
      videoId: videoId,
      repository: repository,
    );
  },
);
