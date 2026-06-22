sealed class VideoAnalysisFailure {
  const VideoAnalysisFailure(this.message);

  final String message;
}

final class NetworkError extends VideoAnalysisFailure {
  const NetworkError([super.message = 'Network connection failed.']);
}

final class VideoTooLongError extends VideoAnalysisFailure {
  const VideoTooLongError([
    super.message = 'Video exceeds the maximum allowed duration.',
  ]);
}

final class InvalidUrlError extends VideoAnalysisFailure {
  const InvalidUrlError([super.message = 'The YouTube URL is invalid.']);
}

final class ServerProcessingError extends VideoAnalysisFailure {
  const ServerProcessingError([
    super.message = 'Video processing failed on the server.',
  ]);
}

final class CalibrationRequiredError extends VideoAnalysisFailure {
  const CalibrationRequiredError([
    super.message = 'Manual pitch calibration is required for this video.',
  ]);
}

final class CalibrationFailedError extends VideoAnalysisFailure {
  const CalibrationFailedError([
    super.message = 'Calibration points could not produce a valid homography.',
  ]);
}

final class UnknownVideoAnalysisError extends VideoAnalysisFailure {
  const UnknownVideoAnalysisError(super.message);
}
