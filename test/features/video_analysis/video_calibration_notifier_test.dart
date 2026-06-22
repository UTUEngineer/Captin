import 'dart:typed_data';

import 'package:captain/core/network/result.dart';
import 'package:captain/core/network/video_analysis_failure.dart';
import 'package:captain/features/video_analysis/application/video_calibration_notifier.dart';
import 'package:captain/features/video_analysis/domain/analysis_result.dart';
import 'package:captain/features/video_analysis/domain/calibration_point.dart';
import 'package:captain/features/video_analysis/domain/video_analysis_repository.dart';
import 'package:captain/features/video_analysis/domain/video_status_response.dart';
import 'package:captain/features/video_analysis/domain/video_upload_response.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('VideoCalibrationNotifier', () {
    test('addPinAtNormalized collects four points before submit', () async {
      final repository = _CalibrationFakeRepository();
      final notifier = VideoCalibrationNotifier(
        videoId: 'video-1',
        repository: repository,
      );

      await notifier.loadFrame();
      expect(notifier.state.frameBytes, isNotNull);
      expect(notifier.state.canSubmit, isFalse);

      notifier.addPinAtNormalized(const Offset(0.1, 0.1));
      notifier.addPinAtNormalized(const Offset(0.2, 0.1));
      notifier.addPinAtNormalized(const Offset(0.2, 0.2));
      notifier.addPinAtNormalized(const Offset(0.1, 0.2));

      expect(notifier.state.canSubmit, isTrue);

      await notifier.submitCalibration();
      expect(notifier.state.submitSucceeded, isTrue);
      expect(repository.submittedPoints, hasLength(4));
    });
  });
}

class _CalibrationFakeRepository implements VideoAnalysisRepository {
  List<CalibrationPoint> submittedPoints = const [];

  static final Uint8List _onePixelPng = Uint8List.fromList([
    137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82, 0, 0, 0,
    1, 0, 0, 0, 1, 8, 6, 0, 0, 0, 31, 21, 196, 137, 0, 0, 0, 10, 73, 68, 65,
    84, 120, 156, 99, 0, 1, 0, 0, 5, 0, 1, 13, 10, 45, 180, 0, 0, 0, 0, 73,
    69, 78, 68, 174, 66, 96, 130,
  ]);

  @override
  Future<Result<bool>> checkBackendHealth() async => const Success(true);

  @override
  Future<Result<bool>> checkAnalysisQuota() async => const Success(true);

  @override
  Future<Result<void>> deleteVideo(String videoId) async => const Success(null);

  @override
  Future<Result<Uint8List>> getFirstFrame(String videoId) async =>
      Success(_onePixelPng);

  @override
  Future<Result<AnalysisResult>> getResult(
    String videoId, {
    String resolution = 'medium',
  }) async =>
      Failure(UnknownVideoAnalysisError('not implemented'));

  @override
  Future<Result<VideoStatusResponse>> getVideoStatus(String videoId) async =>
      Failure(UnknownVideoAnalysisError('not implemented'));

  @override
  Future<Result<void>> startProcessing(String videoId) async =>
      const Success(null);

  @override
  Future<Result<void>> submitCalibration(
    String videoId,
    List<CalibrationPoint> points,
  ) async {
    submittedPoints = points;
    return const Success(null);
  }

  @override
  Future<Result<VideoUploadResponse>> submitYoutubeUrl(String url) async =>
      Failure(UnknownVideoAnalysisError('not implemented'));

  @override
  Future<Result<VideoUploadResponse>> uploadVideo(
    String filePath, {
    UploadProgressCallback? onSendProgress,
  }) async =>
      Failure(UnknownVideoAnalysisError('not implemented'));
}
