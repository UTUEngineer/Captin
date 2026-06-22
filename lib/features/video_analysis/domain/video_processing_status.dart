enum VideoProcessingStatus {
  uploaded,
  extracting,
  detecting,
  tracking,
  needsCalibration,
  analyzing,
  completed,
  failed,
  unknown;

  static VideoProcessingStatus fromApiValue(String? value) {
    return switch (value) {
      'uploaded' => VideoProcessingStatus.uploaded,
      'extracting' => VideoProcessingStatus.extracting,
      'detecting' => VideoProcessingStatus.detecting,
      'tracking' => VideoProcessingStatus.tracking,
      'needs_calibration' => VideoProcessingStatus.needsCalibration,
      'analyzing' => VideoProcessingStatus.analyzing,
      'completed' => VideoProcessingStatus.completed,
      'failed' => VideoProcessingStatus.failed,
      _ => VideoProcessingStatus.unknown,
    };
  }

  String get apiValue => switch (this) {
        VideoProcessingStatus.uploaded => 'uploaded',
        VideoProcessingStatus.extracting => 'extracting',
        VideoProcessingStatus.detecting => 'detecting',
        VideoProcessingStatus.tracking => 'tracking',
        VideoProcessingStatus.needsCalibration => 'needs_calibration',
        VideoProcessingStatus.analyzing => 'analyzing',
        VideoProcessingStatus.completed => 'completed',
        VideoProcessingStatus.failed => 'failed',
        VideoProcessingStatus.unknown => 'unknown',
      };
}
