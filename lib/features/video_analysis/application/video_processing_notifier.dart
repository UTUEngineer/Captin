import 'dart:async';

import 'package:captain/core/network/video_analysis_failure.dart';
import 'package:captain/features/video_analysis/application/video_processing_failure_messages.dart';
import 'package:captain/features/video_analysis/data/local_video_job_store.dart';
import 'package:captain/features/video_analysis/domain/pending_video_job.dart';
import 'package:captain/features/video_analysis/domain/video_analysis_repository.dart';
import 'package:captain/features/video_analysis/domain/video_processing_args.dart';
import 'package:captain/features/video_analysis/domain/video_processing_status.dart';
import 'package:captain/features/video_analysis/domain/video_processing_status_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum VideoProcessingPhase {
  uploading,
  processing,
  failed,
  completed,
  cancelled,
}

class VideoProcessingState {
  const VideoProcessingState({
    this.phase = VideoProcessingPhase.uploading,
    this.uploadProgress = 0,
    this.processingProgress = 0,
    this.serverStatus,
    this.videoId,
    this.jobLabel,
    this.statusMessage,
    this.failureMessage,
  });

  final VideoProcessingPhase phase;
  final double uploadProgress;
  final int processingProgress;
  final VideoProcessingStatus? serverStatus;
  final String? videoId;
  final String? jobLabel;
  final String? statusMessage;
  final String? failureMessage;

  bool get isTerminal {
    return phase == VideoProcessingPhase.failed ||
        phase == VideoProcessingPhase.completed ||
        phase == VideoProcessingPhase.cancelled;
  }

  VideoProcessingState copyWith({
    VideoProcessingPhase? phase,
    double? uploadProgress,
    int? processingProgress,
    VideoProcessingStatus? serverStatus,
    String? videoId,
    String? jobLabel,
    String? statusMessage,
    String? failureMessage,
    bool clearFailure = false,
  }) {
    return VideoProcessingState(
      phase: phase ?? this.phase,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      processingProgress: processingProgress ?? this.processingProgress,
      serverStatus: serverStatus ?? this.serverStatus,
      videoId: videoId ?? this.videoId,
      jobLabel: jobLabel ?? this.jobLabel,
      statusMessage: statusMessage ?? this.statusMessage,
      failureMessage:
          clearFailure ? null : (failureMessage ?? this.failureMessage),
    );
  }
}

class VideoProcessingNotifier extends StateNotifier<VideoProcessingState> {
  VideoProcessingNotifier({
    required VideoAnalysisRepository repository,
    required LocalVideoJobStore jobStore,
  })  : _repository = repository,
        _jobStore = jobStore,
        super(const VideoProcessingState());

  final VideoAnalysisRepository _repository;
  final LocalVideoJobStore _jobStore;
  Timer? _pollTimer;
  var _cancelled = false;

  static const _pollInterval = Duration(seconds: 4);

  Future<void> start(VideoProcessingArgs args) async {
    _cancelled = false;

    if (args.isResume) {
      state = VideoProcessingState(
        phase: VideoProcessingPhase.processing,
        videoId: args.videoId,
        jobLabel: args.label,
        statusMessage: VideoProcessingStatus.unknown.phaseLabel,
      );

      if (args.startProcessingOnLaunch) {
        final processResult =
            await _repository.startProcessing(args.videoId!);
        if (_cancelled) return;
        if (processResult.isFailure) {
          _setFailure(processResult.failureOrNull!);
          return;
        }
      }

      _startPolling();
      return;
    }

    if (args.isUpload) {
      state = VideoProcessingState(
        phase: VideoProcessingPhase.uploading,
        jobLabel: args.label,
      );
      final uploadResult = await _repository.uploadVideo(
        args.filePath!,
        onSendProgress: (sent, total) {
          if (total <= 0 || _cancelled) return;
          state = state.copyWith(uploadProgress: sent / total);
        },
      );
      if (_cancelled) return;
      if (uploadResult.isFailure) {
        _setFailure(uploadResult.failureOrNull!);
        return;
      }
      await _continueWithVideoId(
        uploadResult.valueOrNull!.videoId,
        args.label ?? 'Uploaded video',
      );
      return;
    }

    if (args.isYoutube) {
      state = VideoProcessingState(
        phase: VideoProcessingPhase.processing,
        jobLabel: 'YouTube clip',
        statusMessage: 'Downloading clip…',
      );
      final submitResult =
          await _repository.submitYoutubeUrl(args.youtubeUrl!.trim());
      if (_cancelled) return;
      if (submitResult.isFailure) {
        _setFailure(submitResult.failureOrNull!);
        return;
      }
      await _continueWithVideoId(
        submitResult.valueOrNull!.videoId,
        'YouTube clip',
      );
    }
  }

  Future<void> _continueWithVideoId(String videoId, String label) async {
    state = state.copyWith(
      phase: VideoProcessingPhase.processing,
      videoId: videoId,
      jobLabel: label,
      uploadProgress: 1,
      statusMessage: 'Starting analysis…',
    );

    await _persistJob(
      videoId: videoId,
      label: label,
      status: VideoProcessingStatus.uploaded,
    );

    final processResult = await _repository.startProcessing(videoId);
    if (_cancelled) return;
    if (processResult.isFailure) {
      _setFailure(processResult.failureOrNull!);
      return;
    }

    _startPolling();
  }

  void _startPolling() {
    _pollTimer?.cancel();
    unawaited(_pollStatus());
    _pollTimer = Timer.periodic(_pollInterval, (_) => _pollStatus());
  }

  Future<void> _pollStatus() async {
    final videoId = state.videoId;
    if (videoId == null || _cancelled || state.isTerminal) return;

    final result = await _repository.getVideoStatus(videoId);
    if (_cancelled) return;

    if (result.isFailure) {
      _setFailure(result.failureOrNull!);
      return;
    }

    final status = result.valueOrNull!;
    final processingStatus = status.processingStatus;
    final progress = status.progressPercent > 0
        ? status.progressPercent
        : processingStatus.fallbackProgressPercent;

    state = state.copyWith(
      processingProgress: progress,
      serverStatus: processingStatus,
      statusMessage: status.message ?? processingStatus.phaseLabel,
    );

    await _persistJob(
      videoId: videoId,
      label: state.jobLabel ?? 'Video analysis',
      status: processingStatus,
    );

    if (processingStatus == VideoProcessingStatus.failed) {
      _pollTimer?.cancel();
      state = state.copyWith(
        phase: VideoProcessingPhase.failed,
        failureMessage: state.statusMessage ?? 'Video analysis failed.',
      );
      await _jobStore.clearPendingJob();
      return;
    }

    if (processingStatus == VideoProcessingStatus.completed) {
      _pollTimer?.cancel();
      state = state.copyWith(
        phase: VideoProcessingPhase.completed,
        processingProgress: 100,
        statusMessage: VideoProcessingStatus.completed.phaseLabel,
      );
      await _jobStore.clearPendingJob();
      return;
    }

    if (processingStatus.shouldStopPolling) {
      _pollTimer?.cancel();
    }
  }

  Future<void> _persistJob({
    required String videoId,
    required String label,
    required VideoProcessingStatus status,
  }) async {
    await _jobStore.savePendingJob(
      PendingVideoJob(
        videoId: videoId,
        label: label,
        status: status,
        updatedAt: DateTime.now(),
      ),
    );
  }

  void _setFailure(VideoAnalysisFailure failure) {
    _pollTimer?.cancel();
    state = state.copyWith(
      phase: VideoProcessingPhase.failed,
      failureMessage: videoProcessingFailureMessage(failure),
    );
    unawaited(_jobStore.clearPendingJob());
  }

  void cancel() {
    _cancelled = true;
    _pollTimer?.cancel();
    state = state.copyWith(
      phase: VideoProcessingPhase.cancelled,
      statusMessage: 'Analysis monitoring stopped.',
    );
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }
}
