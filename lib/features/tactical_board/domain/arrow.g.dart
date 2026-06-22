// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'arrow.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Arrow _$ArrowFromJson(Map<String, dynamic> json) => _Arrow(
  id: json['id'] as String,
  startX: (json['startX'] as num).toDouble(),
  startY: (json['startY'] as num).toDouble(),
  endX: (json['endX'] as num).toDouble(),
  endY: (json['endY'] as num).toDouble(),
  type: $enumDecode(_$ArrowTypeEnumMap, json['type']),
  curved: json['curved'] as bool? ?? false,
  colorValue: (json['colorValue'] as num?)?.toInt(),
  locked: json['locked'] as bool? ?? false,
  zIndex: (json['zIndex'] as num?)?.toInt() ?? 0,
  rotation: (json['rotation'] as num?)?.toDouble() ?? 0.0,
);

Map<String, dynamic> _$ArrowToJson(_Arrow instance) => <String, dynamic>{
  'id': instance.id,
  'startX': instance.startX,
  'startY': instance.startY,
  'endX': instance.endX,
  'endY': instance.endY,
  'type': _$ArrowTypeEnumMap[instance.type]!,
  'curved': instance.curved,
  'colorValue': instance.colorValue,
  'locked': instance.locked,
  'zIndex': instance.zIndex,
  'rotation': instance.rotation,
};

const _$ArrowTypeEnumMap = {
  ArrowType.pass: 'pass',
  ArrowType.run: 'run',
  ArrowType.press: 'press',
  ArrowType.curvedRun: 'curvedRun',
};
