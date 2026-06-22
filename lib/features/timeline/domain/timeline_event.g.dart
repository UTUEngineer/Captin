// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timeline_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TimelineEvent _$TimelineEventFromJson(Map<String, dynamic> json) =>
    _TimelineEvent(
      id: json['id'] as String,
      minute: (json['minute'] as num).toInt(),
      second: (json['second'] as num?)?.toInt() ?? 0,
      type: const TimelineEventTypeConverter().fromJson(json['type'] as String),
      description: json['description'] as String? ?? '',
      linkedTacticalBoardId: json['linkedTacticalBoardId'] as String?,
      teamId: json['teamId'] as String?,
      playerName: json['playerName'] as String?,
    );

Map<String, dynamic> _$TimelineEventToJson(_TimelineEvent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'minute': instance.minute,
      'second': instance.second,
      'type': const TimelineEventTypeConverter().toJson(instance.type),
      'description': instance.description,
      'linkedTacticalBoardId': instance.linkedTacticalBoardId,
      'teamId': instance.teamId,
      'playerName': instance.playerName,
    };
