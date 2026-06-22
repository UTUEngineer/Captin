// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drill_path.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DrillPath _$DrillPathFromJson(Map<String, dynamic> json) => _DrillPath(
  id: json['id'] as String,
  startX: (json['startX'] as num).toDouble(),
  startY: (json['startY'] as num).toDouble(),
  endX: (json['endX'] as num).toDouble(),
  endY: (json['endY'] as num).toDouble(),
  controlPoints:
      (json['controlPoints'] as List<dynamic>?)
          ?.map((e) => PathControlPoint.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  style:
      $enumDecodeNullable(_$DrillPathStyleEnumMap, json['style']) ??
      DrillPathStyle.run,
  colorValue: (json['colorValue'] as num?)?.toInt() ?? 0xFF2E7D32,
);

Map<String, dynamic> _$DrillPathToJson(_DrillPath instance) =>
    <String, dynamic>{
      'id': instance.id,
      'startX': instance.startX,
      'startY': instance.startY,
      'endX': instance.endX,
      'endY': instance.endY,
      'controlPoints': instance.controlPoints,
      'style': _$DrillPathStyleEnumMap[instance.style]!,
      'colorValue': instance.colorValue,
    };

const _$DrillPathStyleEnumMap = {
  DrillPathStyle.run: 'run',
  DrillPathStyle.pass: 'pass',
  DrillPathStyle.shot: 'shot',
};
