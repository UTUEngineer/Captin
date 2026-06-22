import 'dart:typed_data';

import 'package:captain/core/network/result.dart';
import 'package:captain/features/video_analysis/domain/analysis_result.dart';
import 'package:captain/features/video_analysis/domain/calibration_point.dart';
import 'package:captain/features/video_analysis/domain/video_status_response.dart';
import 'package:captain/features/video_analysis/domain/video_upload_response.dart';

typedef UploadProgressCallback = void Function(int sent, int total);

abstract class VideoAnalysisRepository {
  Future<Result<VideoUploadResponse>> uploadVideo(
    String filePath, {
    UploadProgressCallback? onSendProgress,
  });

  Future<Result<VideoUploadResponse>> submitYoutubeUrl(String url);

  Future<Result<VideoStatusResponse>> getVideoStatus(String videoId);

  Future<Result<Uint8List>> getFirstFrame(String videoId);

  Future<Result<void>> submitCalibration(
    String videoId,
    List<CalibrationPoint> points,
  );

  Future<Result<void>> startProcessing(String videoId);

  Future<Result<AnalysisResult>> getResult(
    String videoId, {
    String resolution = 'medium',
  });

  /// Lightweight liveness probe for the vision backend (/health).
  Future<Result<bool>> checkBackendHealth();

  /// Remove server-side video artifacts after results are cached locally.
  Future<Result<void>> deleteVideo(String videoId);

  /// Central hook for future usage quotas. Always allowed in MVP.
  Future<Result<bool>> checkAnalysisQuota();
}
