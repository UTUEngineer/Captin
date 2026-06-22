import 'package:captain/core/network/video_analysis_failure.dart';

String videoProcessingFailureMessage(VideoAnalysisFailure failure) {
  return switch (failure) {
    NetworkError() =>
      'Could not reach the analysis service. Check your connection and try again.',
    VideoTooLongError() =>
      'This video is too long. Use a shorter clip and try again.',
    InvalidUrlError() =>
      'The YouTube link is invalid or the video is unavailable.',
    ServerProcessingError() =>
      'Video processing failed on the server. Please try again.',
    CalibrationRequiredError() =>
      'Pitch calibration is required before analysis can continue.',
    CalibrationFailedError() =>
      'Calibration failed. Adjust the four reference points and try again.',
    UnknownVideoAnalysisError(:final message) => message,
  };
}
