import 'dart:typed_data';

import 'package:captain/core/network/result.dart';
import 'package:captain/core/network/video_analysis_failure.dart';
import 'package:captain/features/video_analysis/application/video_processing_notifier.dart';
import 'package:captain/features/video_analysis/data/local_video_job_store.dart';
import 'package:captain/features/video_analysis/domain/analysis_result.dart';
import 'package:captain/features/video_analysis/domain/calibration_point.dart';
import 'package:captain/features/video_analysis/domain/video_analysis_repository.dart';
import 'package:captain/features/video_analysis/domain/video_processing_args.dart';
import 'package:captain/features/video_analysis/domain/video_processing_status.dart';
import 'package:captain/features/video_analysis/domain/video_status_response.dart';
import 'package:captain/features/video_analysis/domain/video_upload_response.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('VideoProcessingNotifier', () {
    late LocalVideoJobStore store;
    late FakeVideoAnalysisRepository repository;
    late VideoProcessingNotifier notifier;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      store = await LocalVideoJobStore.create();
      repository = FakeVideoAnalysisRepository();
      notifier = VideoProcessingNotifier(
        repository: repository,
        jobStore: store,
      );
    });

    tearDown(() {
      notifier.dispose();
    });

    test('upload flow moves to processing and completes', () async {
      await notifier.start(
        const VideoProcessingArgs.upload(
          filePath: '/tmp/sample.mp4',
          label: 'sample.mp4',
        ),
      );

      expect(notifier.state.phase, VideoProcessingPhase.processing);
      expect(notifier.state.videoId, 'video-1');
      expect(notifier.state.uploadProgress, 1);

      await notifier.start(
        const VideoProcessingArgs.resume(
          videoId: 'video-1',
          label: 'sample.mp4',
        ),
      );

      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(notifier.state.phase, VideoProcessingPhase.completed);
      expect(notifier.state.processingProgress, 100);
      expect(await store.loadPendingJob(), isNull);
    });

    test('cancel stops monitoring without clearing server-side job', () async {
      await notifier.start(
        const VideoProcessingArgs.youtube(
          youtubeUrl: 'https://youtu.be/demo',
        ),
      );

      notifier.cancel();
      expect(notifier.state.phase, VideoProcessingPhase.cancelled);
    });

    test('failed status surfaces retryable error', () async {
      repository.failProcessing = true;

      await notifier.start(
        const VideoProcessingArgs.youtube(
          youtubeUrl: 'https://youtu.be/demo',
        ),
      );

      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(notifier.state.phase, VideoProcessingPhase.failed);
      expect(notifier.state.failureMessage, isNotEmpty);
    });
  });
}

class FakeVideoAnalysisRepository implements VideoAnalysisRepository {
  var failProcessing = false;
  var pollCount = 0;

  @override
  Future<Result<bool>> checkBackendHealth() async => const Success(true);

  @override
  Future<Result<bool>> checkAnalysisQuota() async => const Success(true);

  @override
  Future<Result<void>> deleteVideo(String videoId) async => const Success(null);

  @override
  Future<Result<Uint8List>> getFirstFrame(String videoId) async =>
      const Failure(UnknownVideoAnalysisError('not implemented'));

  @override
  Future<Result<AnalysisResult>> getResult(
    String videoId, {
    String resolution = 'medium',
  }) async =>
      const Failure(UnknownVideoAnalysisError('not implemented'));

  @override
  Future<Result<VideoStatusResponse>> getVideoStatus(String videoId) async {
    pollCount += 1;
    if (failProcessing) {
      return Success(
        VideoStatusResponse(
          videoId: videoId,
          status: VideoProcessingStatus.failed.apiValue,
          progressPercent: 0,
          message: 'Processing failed',
        ),
      );
    }

    if (pollCount < 2) {
      return Success(
        VideoStatusResponse(
          videoId: videoId,
          status: VideoProcessingStatus.detecting.apiValue,
          progressPercent: 40,
        ),
      );
    }

    return Success(
      VideoStatusResponse(
        videoId: videoId,
        status: VideoProcessingStatus.completed.apiValue,
        progressPercent: 100,
      ),
    );
  }

  @override
  Future<Result<void>> startProcessing(String videoId) async =>
      const Success(null);

  @override
  Future<Result<void>> submitCalibration(
    String videoId,
    List<CalibrationPoint> points,
  ) async =>
      const Success(null);

  @override
  Future<Result<VideoUploadResponse>> submitYoutubeUrl(String url) async {
    return Success(
      VideoUploadResponse(
        videoId: 'video-1',
        status: 'uploaded',
        durationSeconds: 30,
      ),
    );
  }

  @override
  Future<Result<VideoUploadResponse>> uploadVideo(
    String filePath, {
    UploadProgressCallback? onSendProgress,
  }) async {
    onSendProgress?.call(50, 100);
    onSendProgress?.call(100, 100);
    return Success(
      VideoUploadResponse(
        videoId: 'video-1',
        status: 'uploaded',
        durationSeconds: 45,
      ),
    );
  }
}
