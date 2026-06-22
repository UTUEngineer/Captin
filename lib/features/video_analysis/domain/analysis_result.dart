import 'package:freezed_annotation/freezed_annotation.dart';

part 'analysis_result.freezed.dart';
part 'analysis_result.g.dart';

@freezed
abstract class TrackPosition with _$TrackPosition {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory TrackPosition({
    required double x,
    required double y,
    required double timestampSeconds,
    int? frame,
  }) = _TrackPosition;

  factory TrackPosition.fromJson(Map<String, dynamic> json) =>
      _$TrackPositionFromJson(json);
}

@freezed
abstract class VideoTrack with _$VideoTrack {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory VideoTrack({
    required int trackId,
    required List<TrackPosition> positions,
  }) = _VideoTrack;

  factory VideoTrack.fromJson(Map<String, dynamic> json) =>
      _$VideoTrackFromJson(json);
}

@freezed
abstract class PlayerAnalytics with _$PlayerAnalytics {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory PlayerAnalytics({
    required int trackId,
    required double distanceKm,
    required int sprintCount,
    required double maxSpeedKmh,
    required List<List<double>> heatmap,
  }) = _PlayerAnalytics;

  factory PlayerAnalytics.fromJson(Map<String, dynamic> json) =>
      _$PlayerAnalyticsFromJson(json);
}

@freezed
abstract class TeamPossessionZones with _$TeamPossessionZones {
  const factory TeamPossessionZones({
    required double defensive,
    required double middle,
    required double attacking,
  }) = _TeamPossessionZones;

  factory TeamPossessionZones.fromJson(Map<String, dynamic> json) =>
      _$TeamPossessionZonesFromJson(json);
}

@freezed
abstract class PossessionZones with _$PossessionZones {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory PossessionZones({
    TeamPossessionZones? teamA,
    TeamPossessionZones? teamB,
  }) = _PossessionZones;

  factory PossessionZones.fromJson(Map<String, dynamic> json) =>
      _$PossessionZonesFromJson(json);
}

@freezed
abstract class AnalysisResult with _$AnalysisResult {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory AnalysisResult({
    required String videoId,
    required double durationSeconds,
    required List<VideoTrack> tracks,
    @Default([]) List<PlayerAnalytics> players,
    PossessionZones? possessionZones,
  }) = _AnalysisResult;

  factory AnalysisResult.fromJson(Map<String, dynamic> json) =>
      _$AnalysisResultFromJson(json);
}
