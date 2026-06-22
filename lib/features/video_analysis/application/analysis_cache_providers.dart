import 'package:captain/features/video_analysis/application/recent_analyses_providers.dart';
import 'package:captain/features/video_analysis/application/video_analysis_providers.dart';
import 'package:captain/features/video_analysis/data/local_analysis_result_cache.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final analysisCacheEntryCountProvider = FutureProvider<int>((ref) async {
  final cache = await ref.watch(localAnalysisResultCacheProvider.future);
  return cache.entryCount();
});

class AnalysisCacheController {
  AnalysisCacheController(this._ref);

  final Ref _ref;

  Future<int> clearSavedResults() async {
    final cache = await _ref.read(localAnalysisResultCacheProvider.future);
    final repository = _ref.read(videoAnalysisRepositoryProvider);
    final videoIds = cache.listVideoIds();
    final count = await cache.entryCount();
    await cache.clearAll();
    for (final videoId in videoIds) {
      await repository.deleteVideo(videoId);
    }
    await _ref.read(recentAnalysesProvider.notifier).clearAll();
    _ref.invalidate(analysisCacheEntryCountProvider);
    return count;
  }
}

final analysisCacheControllerProvider = Provider<AnalysisCacheController>((ref) {
  return AnalysisCacheController(ref);
});
