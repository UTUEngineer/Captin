class VideoProcessingArgs {
  const VideoProcessingArgs.upload({
    required this.filePath,
    required this.label,
  })  : youtubeUrl = null,
        videoId = null,
        startProcessingOnLaunch = false;

  const VideoProcessingArgs.youtube({
    required this.youtubeUrl,
  })  : filePath = null,
        videoId = null,
        label = null,
        startProcessingOnLaunch = false;

  const VideoProcessingArgs.resume({
    required this.videoId,
    required this.label,
  })  : filePath = null,
        youtubeUrl = null,
        startProcessingOnLaunch = false;

  const VideoProcessingArgs.continueAfterCalibration({
    required this.videoId,
    required this.label,
  })  : filePath = null,
        youtubeUrl = null,
        startProcessingOnLaunch = true;

  final String? filePath;
  final String? youtubeUrl;
  final String? videoId;
  final String? label;
  final bool startProcessingOnLaunch;

  bool get isResume => videoId != null && filePath == null && youtubeUrl == null;
  bool get isUpload => filePath != null;
  bool get isYoutube => youtubeUrl != null;
}
