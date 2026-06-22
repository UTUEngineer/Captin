// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Player _$PlayerFromJson(Map<String, dynamic> json) => _Player(
  id: json['id'] as String,
  number: (json['number'] as num).toInt(),
  x: (json['x'] as num).toDouble(),
  y: (json['y'] as num).toDouble(),
  label: json['label'] as String?,
  isHomeTeam: json['isHomeTeam'] as bool? ?? true,
  locked: json['locked'] as bool? ?? false,
  zIndex: (json['zIndex'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$PlayerToJson(_Player instance) => <String, dynamic>{
  'id': instance.id,
  'number': instance.number,
  'x': instance.x,
  'y': instance.y,
  'label': instance.label,
  'isHomeTeam': instance.isHomeTeam,
  'locked': instance.locked,
  'zIndex': instance.zIndex,
};
