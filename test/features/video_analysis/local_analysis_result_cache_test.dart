import 'package:captain/features/video_analysis/data/local_analysis_result_cache.dart';
import 'package:captain/features/video_analysis/domain/analysis_result.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

AnalysisResult _sampleResult({String videoId = 'video-1'}) {
  return AnalysisResult(
    videoId: videoId,
    durationSeconds: 90,
    tracks: const [],
    players: const [],
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LocalAnalysisResultCache', () {
    test('save and load round-trip analysis json', () async {
      SharedPreferences.setMockInitialValues({});
      final cache = await LocalAnalysisResultCache.create();

      await cache.save(_sampleResult());
      final loaded = await cache.load('video-1');

      expect(loaded, isNotNull);
      expect(loaded!.videoId, 'video-1');
      expect(loaded.durationSeconds, 90);
    });

    test('clearAll removes all cached entries', () async {
      SharedPreferences.setMockInitialValues({});
      final cache = await LocalAnalysisResultCache.create();

      await cache.save(_sampleResult());
      await cache.save(_sampleResult(videoId: 'video-2'));
      expect(await cache.entryCount(), 2);

      await cache.clearAll();
      expect(await cache.entryCount(), 0);
      expect(await cache.load('video-1'), isNull);
    });
  });
}
