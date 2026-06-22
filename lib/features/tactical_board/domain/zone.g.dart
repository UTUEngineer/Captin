// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'zone.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Zone _$ZoneFromJson(Map<String, dynamic> json) => _Zone(
  id: json['id'] as String,
  x: (json['x'] as num).toDouble(),
  y: (json['y'] as num).toDouble(),
  width: (json['width'] as num).toDouble(),
  height: (json['height'] as num).toDouble(),
  colorValue: (json['colorValue'] as num).toInt(),
  locked: json['locked'] as bool? ?? false,
  zIndex: (json['zIndex'] as num?)?.toInt() ?? 0,
  rotation: (json['rotation'] as num?)?.toDouble() ?? 0.0,
);

Map<String, dynamic> _$ZoneToJson(_Zone instance) => <String, dynamic>{
  'id': instance.id,
  'x': instance.x,
  'y': instance.y,
  'width': instance.width,
  'height': instance.height,
  'colorValue': instance.colorValue,
  'locked': instance.locked,
  'zIndex': instance.zIndex,
  'rotation': instance.rotation,
};
