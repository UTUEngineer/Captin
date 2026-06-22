import 'package:captain/core/network/result.dart';
import 'package:captain/core/network/video_analysis_failure.dart';
import 'package:captain/features/video_analysis/application/analysis_result_notifier.dart';
import 'package:captain/features/video_analysis/data/local_analysis_result_cache.dart';
import 'package:captain/features/video_analysis/domain/analysis_result.dart';
import 'package:captain/features/video_analysis/domain/video_analysis_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AnalysisResultNotifier cache-first loading', () {
    late LocalAnalysisResultCache cache;
    late _FakeRepository repository;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      cache = await LocalAnalysisResultCache.create();
      repository = _FakeRepository();
    });

    test('shows cached result when network fails', () async {
      await cache.save(_sampleResult());

      final notifier = AnalysisResultNotifier(
        videoId: 'video-1',
        repository: repository,
        getCache: () async => cache,
      );
      addTearDown(notifier.dispose);

      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(notifier.state.result, isNotNull);
      expect(notifier.state.loadedFromCache, isTrue);
      expect(notifier.state.errorMessage, isNull);
    });

    test('updates cache after successful network fetch', () async {
      repository.shouldFail = false;
      repository.result = _sampleResult(durationSeconds: 120);

      final notifier = AnalysisResultNotifier(
        videoId: 'video-1',
        repository: repository,
        getCache: () async => cache,
      );
      addTearDown(notifier.dispose);

      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(notifier.state.result?.durationSeconds, 120);
      expect(notifier.state.loadedFromCache, isFalse);

      final cached = await cache.load('video-1');
      expect(cached?.durationSeconds, 120);
    });
  });
}

AnalysisResult _sampleResult({double durationSeconds = 90}) {
  return AnalysisResult(
    videoId: 'video-1',
    durationSeconds: durationSeconds,
    tracks: const [],
    players: const [],
  );
}

class _FakeRepository implements VideoAnalysisRepository {
  AnalysisResult? result;
  var shouldFail = true;

  @override
  Future<Result<AnalysisResult>> getResult(
    String videoId, {
    String resolution = 'medium',
  }) async {
    if (shouldFail) {
      return const Failure(NetworkError('offline'));
    }
    return Success(result ?? _sampleResult());
  }

  @override
  Future<Result<bool>> checkBackendHealth() async => const Success(true);

  @override
  Future<Result<bool>> checkAnalysisQuota() async => const Success(true);

  @override
  Future<Result<void>> deleteVideo(String videoId) async => const Success(null);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
