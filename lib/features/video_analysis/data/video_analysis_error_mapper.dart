import 'package:captain/core/network/result.dart';
import 'package:captain/core/network/video_analysis_failure.dart';
import 'package:dio/dio.dart';

VideoAnalysisFailure mapDioException(DioException error) {
  final statusCode = error.response?.statusCode;
  final detail = _extractDetail(error.response?.data);

  if (error.type == DioExceptionType.connectionTimeout ||
      error.type == DioExceptionType.receiveTimeout ||
      error.type == DioExceptionType.sendTimeout ||
      error.type == DioExceptionType.connectionError) {
    return NetworkError(detail ?? 'Network connection failed.');
  }

  if (statusCode == 413 ||
      _containsAny(detail, ['too long', 'duration', 'max_video'])) {
    return VideoTooLongError(detail ?? 'Video exceeds the maximum duration.');
  }

  if (statusCode == 400 &&
      _containsAny(detail, ['ffprobe', 'ffmpeg', 'unable to read video duration'])) {
    return ServerProcessingError(
      'The vision backend is missing ffmpeg/ffprobe. '
      'Use Docker (recommended) or install ffmpeg on the backend host.',
    );
  }

  if (statusCode == 400 &&
      _containsAny(detail, ['youtube', 'url', 'invalid url'])) {
    return InvalidUrlError(detail ?? 'The YouTube URL is invalid.');
  }

  if (statusCode == 422 &&
      _containsAny(detail, ['calibration', 'homography'])) {
    return CalibrationFailedError(
      detail ?? 'Calibration points could not produce a valid homography.',
    );
  }

  if (statusCode == 409 &&
      _containsAny(detail, ['calibration', 'needs_calibration'])) {
    return CalibrationRequiredError(
      detail ?? 'Manual pitch calibration is required for this video.',
    );
  }

  if (statusCode != null && statusCode >= 500) {
    return ServerProcessingError(detail ?? 'Video processing failed on the server.');
  }

  return UnknownVideoAnalysisError(
    detail ?? error.message ?? 'Unexpected video analysis error.',
  );
}

Result<T> failureFromDio<T>(DioException error) {
  return Failure(mapDioException(error));
}

String? _extractDetail(Object? data) {
  if (data == null) return null;
  if (data is String && data.isNotEmpty) return data;
  if (data is Map<String, dynamic>) {
    final detail = data['detail'] ?? data['message'] ?? data['error'];
    if (detail is String) return detail;
    if (detail is List && detail.isNotEmpty) {
      final first = detail.first;
      if (first is Map && first['msg'] is String) {
        return first['msg'] as String;
      }
      return detail.join(', ');
    }
  }
  return null;
}

bool _containsAny(String? text, List<String> needles) {
  if (text == null) return false;
  final lower = text.toLowerCase();
  return needles.any(lower.contains);
}
