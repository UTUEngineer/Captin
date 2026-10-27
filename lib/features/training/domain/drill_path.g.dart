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
  style: json['style'] == null
      ? DrillPathStyle.run
      : const DrillPathStyleConverter().fromJson(json['style'] as String),
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
      'style': const DrillPathStyleConverter().toJson(instance.style),
      'colorValue': instance.colorValue,
    };
