import 'package:captain/features/video_analysis/data/local_recent_analyses_store.dart';
import 'package:captain/features/video_analysis/domain/recent_video_analysis.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final recentAnalysesProvider =
    AsyncNotifierProvider<RecentAnalysesNotifier, List<RecentVideoAnalysis>>(
  RecentAnalysesNotifier.new,
);

class RecentAnalysesNotifier extends AsyncNotifier<List<RecentVideoAnalysis>> {
  @override
  Future<List<RecentVideoAnalysis>> build() async {
    final store = await ref.watch(localRecentAnalysesStoreProvider.future);
    return store.loadAll();
  }

  Future<void> recordCompleted({
    required String videoId,
    required String label,
  }) async {
    final store = await ref.read(localRecentAnalysesStoreProvider.future);
    await store.recordCompleted(videoId: videoId, label: label);
    ref.invalidateSelf();
  }

  Future<void> clearAll() async {
    final store = await ref.read(localRecentAnalysesStoreProvider.future);
    await store.clearAll();
    ref.invalidateSelf();
  }
}
