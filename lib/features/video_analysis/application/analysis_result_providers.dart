import 'package:captain/features/video_analysis/application/analysis_result_notifier.dart';
import 'package:captain/features/video_analysis/application/video_analysis_providers.dart';
import 'package:captain/features/video_analysis/data/local_analysis_result_cache.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final analysisResultProvider = StateNotifierProvider.autoDispose
    .family<AnalysisResultNotifier, AnalysisResultState, String>(
  (ref, videoId) {
    final repository = ref.watch(videoAnalysisRepositoryProvider);
    return AnalysisResultNotifier(
      videoId: videoId,
      repository: repository,
      getCache: () => ref.read(localAnalysisResultCacheProvider.future),
    );
  },
);
