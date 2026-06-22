import 'dart:async';

import 'package:captain/features/video_analysis/application/video_processing_failure_messages.dart';
import 'package:captain/features/video_analysis/data/local_analysis_result_cache.dart';
import 'package:captain/features/video_analysis/domain/analysis_result.dart';
import 'package:captain/features/video_analysis/domain/video_analysis_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AnalysisResultState {
  const AnalysisResultState({
    this.isLoading = true,
    this.isRefreshing = false,
    this.result,
    this.errorMessage,
    this.loadedFromCache = false,
    this.currentTimeSeconds = 0,
    this.isPlaying = false,
    this.showHeatmap = false,
    this.showPossessionZones = false,
    this.showStatsPanel = false,
    this.selectedTrackId,
  });

  final bool isLoading;
  final bool isRefreshing;
  final AnalysisResult? result;
  final String? errorMessage;
  final bool loadedFromCache;
  final double currentTimeSeconds;
  final bool isPlaying;
  final bool showHeatmap;
  final bool showPossessionZones;
  final bool showStatsPanel;
  final int? selectedTrackId;

  AnalysisResultState copyWith({
    bool? isLoading,
    bool? isRefreshing,
    AnalysisResult? result,
    String? errorMessage,
    bool? loadedFromCache,
    double? currentTimeSeconds,
    bool? isPlaying,
    bool? showHeatmap,
    bool? showPossessionZones,
    bool? showStatsPanel,
    int? selectedTrackId,
    bool clearSelectedTrack = false,
    bool clearError = false,
  }) {
    return AnalysisResultState(
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      result: result ?? this.result,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      loadedFromCache: loadedFromCache ?? this.loadedFromCache,
      currentTimeSeconds: currentTimeSeconds ?? this.currentTimeSeconds,
      isPlaying: isPlaying ?? this.isPlaying,
      showHeatmap: showHeatmap ?? this.showHeatmap,
      showPossessionZones: showPossessionZones ?? this.showPossessionZones,
      showStatsPanel: showStatsPanel ?? this.showStatsPanel,
      selectedTrackId:
          clearSelectedTrack ? null : (selectedTrackId ?? this.selectedTrackId),
    );
  }
}

class AnalysisResultNotifier extends StateNotifier<AnalysisResultState> {
  AnalysisResultNotifier({
    required this.videoId,
    required VideoAnalysisRepository repository,
    required Future<LocalAnalysisResultCache> Function() getCache,
  })  : _repository = repository,
        _getCache = getCache,
        super(const AnalysisResultState()) {
    load();
  }

  final String videoId;
  final VideoAnalysisRepository _repository;
  final Future<LocalAnalysisResultCache> Function() _getCache;
  Timer? _playbackTimer;

  static const _playbackStep = Duration(milliseconds: 100);

  Future<void> load() async {
    state = state.copyWith(
      isLoading: state.result == null,
      isRefreshing: state.result != null,
      clearError: true,
    );

    final cache = await _getCache();
    final cachedResult = await cache.load(videoId);
    if (cachedResult != null) {
      state = state.copyWith(
        isLoading: false,
        result: cachedResult,
        loadedFromCache: true,
        currentTimeSeconds: 0,
      );
    }

    final response = await _repository.getResult(videoId);
    if (response.isSuccess) {
      final result = response.valueOrNull!;
      await cache.save(result);
      await _repository.deleteVideo(videoId);
      state = state.copyWith(
        isLoading: false,
        isRefreshing: false,
        result: result,
        loadedFromCache: false,
        currentTimeSeconds: 0,
      );
      return;
    }

    if (cachedResult != null) {
      state = state.copyWith(
        isLoading: false,
        isRefreshing: false,
        loadedFromCache: true,
      );
      return;
    }

    state = state.copyWith(
      isLoading: false,
      isRefreshing: false,
      errorMessage: videoProcessingFailureMessage(response.failureOrNull!),
    );
  }

  void setCurrentTime(double seconds) {
    final duration = state.result?.durationSeconds ?? 0;
    state = state.copyWith(
      currentTimeSeconds: seconds.clamp(0, duration),
      isPlaying: false,
    );
    _playbackTimer?.cancel();
  }

  void togglePlayback() {
    if (state.result == null) return;

    if (state.isPlaying) {
      _playbackTimer?.cancel();
      state = state.copyWith(isPlaying: false);
      return;
    }

    state = state.copyWith(isPlaying: true);
    _playbackTimer = Timer.periodic(_playbackStep, (_) {
      final duration = state.result!.durationSeconds;
      final next = state.currentTimeSeconds + 0.1;
      if (next >= duration) {
        _playbackTimer?.cancel();
        state = state.copyWith(
          currentTimeSeconds: duration,
          isPlaying: false,
        );
        return;
      }
      state = state.copyWith(currentTimeSeconds: next);
    });
  }

  void toggleHeatmap() {
    state = state.copyWith(showHeatmap: !state.showHeatmap);
  }

  void togglePossessionZones() {
    state = state.copyWith(showPossessionZones: !state.showPossessionZones);
  }

  void toggleStatsPanel() {
    state = state.copyWith(showStatsPanel: !state.showStatsPanel);
  }

  void selectTrack(int? trackId) {
    state = state.copyWith(
      selectedTrackId: trackId,
      clearSelectedTrack: trackId == null,
      showStatsPanel: trackId != null ? true : state.showStatsPanel,
    );
  }

  @override
  void dispose() {
    _playbackTimer?.cancel();
    super.dispose();
  }
}
