import 'package:captain/features/video_analysis/domain/video_processing_status.dart';

extension VideoProcessingStatusUi on VideoProcessingStatus {
  String get phaseLabel {
    return switch (this) {
      VideoProcessingStatus.uploaded => 'Preparing video…',
      VideoProcessingStatus.extracting => 'Extracting frames…',
      VideoProcessingStatus.detecting => 'Detecting players…',
      VideoProcessingStatus.tracking => 'Tracking player movement…',
      VideoProcessingStatus.needsCalibration => 'Pitch calibration required',
      VideoProcessingStatus.analyzing => 'Running match analytics…',
      VideoProcessingStatus.completed => 'Analysis complete',
      VideoProcessingStatus.failed => 'Analysis failed',
      VideoProcessingStatus.unknown => 'Processing video…',
    };
  }

  int get fallbackProgressPercent {
    return switch (this) {
      VideoProcessingStatus.uploaded => 10,
      VideoProcessingStatus.extracting => 25,
      VideoProcessingStatus.detecting => 45,
      VideoProcessingStatus.tracking => 65,
      VideoProcessingStatus.needsCalibration => 70,
      VideoProcessingStatus.analyzing => 90,
      VideoProcessingStatus.completed => 100,
      VideoProcessingStatus.failed => 0,
      VideoProcessingStatus.unknown => 5,
    };
  }

  bool get shouldStopPolling {
    return this == VideoProcessingStatus.completed ||
        this == VideoProcessingStatus.failed ||
        this == VideoProcessingStatus.needsCalibration;
  }
}
