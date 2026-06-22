// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'match_timeline.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MatchTimeline _$MatchTimelineFromJson(Map<String, dynamic> json) =>
    _MatchTimeline(
      id: json['id'] as String,
      matchId: json['matchId'] as String,
      duration: (json['duration'] as num?)?.toInt() ?? 90,
      events:
          (json['events'] as List<dynamic>?)
              ?.map((e) => TimelineEvent.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$MatchTimelineToJson(_MatchTimeline instance) =>
    <String, dynamic>{
      'id': instance.id,
      'matchId': instance.matchId,
      'duration': instance.duration,
      'events': instance.events,
    };
