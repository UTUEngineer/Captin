// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analysis_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TrackPosition _$TrackPositionFromJson(Map<String, dynamic> json) =>
    _TrackPosition(
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      timestampSeconds: (json['timestamp_seconds'] as num).toDouble(),
      frame: (json['frame'] as num?)?.toInt(),
    );

Map<String, dynamic> _$TrackPositionToJson(_TrackPosition instance) =>
    <String, dynamic>{
      'x': instance.x,
      'y': instance.y,
      'timestamp_seconds': instance.timestampSeconds,
      'frame': instance.frame,
    };

_VideoTrack _$VideoTrackFromJson(Map<String, dynamic> json) => _VideoTrack(
  trackId: (json['track_id'] as num).toInt(),
  positions: (json['positions'] as List<dynamic>)
      .map((e) => TrackPosition.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$VideoTrackToJson(_VideoTrack instance) =>
    <String, dynamic>{
      'track_id': instance.trackId,
      'positions': instance.positions,
    };

_PlayerAnalytics _$PlayerAnalyticsFromJson(Map<String, dynamic> json) =>
    _PlayerAnalytics(
      trackId: (json['track_id'] as num).toInt(),
      distanceKm: (json['distance_km'] as num).toDouble(),
      sprintCount: (json['sprint_count'] as num).toInt(),
      maxSpeedKmh: (json['max_speed_kmh'] as num).toDouble(),
      heatmap: (json['heatmap'] as List<dynamic>)
          .map(
            (e) =>
                (e as List<dynamic>).map((e) => (e as num).toDouble()).toList(),
          )
          .toList(),
    );

Map<String, dynamic> _$PlayerAnalyticsToJson(_PlayerAnalytics instance) =>
    <String, dynamic>{
      'track_id': instance.trackId,
      'distance_km': instance.distanceKm,
      'sprint_count': instance.sprintCount,
      'max_speed_kmh': instance.maxSpeedKmh,
      'heatmap': instance.heatmap,
    };

_TeamPossessionZones _$TeamPossessionZonesFromJson(Map<String, dynamic> json) =>
    _TeamPossessionZones(
      defensive: (json['defensive'] as num).toDouble(),
      middle: (json['middle'] as num).toDouble(),
      attacking: (json['attacking'] as num).toDouble(),
    );

Map<String, dynamic> _$TeamPossessionZonesToJson(
  _TeamPossessionZones instance,
) => <String, dynamic>{
  'defensive': instance.defensive,
  'middle': instance.middle,
  'attacking': instance.attacking,
};

_PossessionZones _$PossessionZonesFromJson(
  Map<String, dynamic> json,
) => _PossessionZones(
  teamA: json['team_a'] == null
      ? null
      : TeamPossessionZones.fromJson(json['team_a'] as Map<String, dynamic>),
  teamB: json['team_b'] == null
      ? null
      : TeamPossessionZones.fromJson(json['team_b'] as Map<String, dynamic>),
);

Map<String, dynamic> _$PossessionZonesToJson(_PossessionZones instance) =>
    <String, dynamic>{'team_a': instance.teamA, 'team_b': instance.teamB};

_AnalysisResult _$AnalysisResultFromJson(Map<String, dynamic> json) =>
    _AnalysisResult(
      videoId: json['video_id'] as String,
      durationSeconds: (json['duration_seconds'] as num).toDouble(),
      tracks: (json['tracks'] as List<dynamic>)
          .map((e) => VideoTrack.fromJson(e as Map<String, dynamic>))
          .toList(),
      players:
          (json['players'] as List<dynamic>?)
              ?.map((e) => PlayerAnalytics.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      possessionZones: json['possession_zones'] == null
          ? null
          : PossessionZones.fromJson(
              json['possession_zones'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$AnalysisResultToJson(_AnalysisResult instance) =>
    <String, dynamic>{
      'video_id': instance.videoId,
      'duration_seconds': instance.durationSeconds,
      'tracks': instance.tracks,
      'players': instance.players,
      'possession_zones': instance.possessionZones,
    };
