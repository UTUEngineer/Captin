// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'highlight_circle.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_HighlightCircle _$HighlightCircleFromJson(Map<String, dynamic> json) =>
    _HighlightCircle(
      id: json['id'] as String,
      centerX: (json['centerX'] as num).toDouble(),
      centerY: (json['centerY'] as num).toDouble(),
      radiusX: (json['radiusX'] as num).toDouble(),
      radiusY: (json['radiusY'] as num).toDouble(),
      colorValue: (json['colorValue'] as num).toInt(),
      locked: json['locked'] as bool? ?? false,
      zIndex: (json['zIndex'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$HighlightCircleToJson(_HighlightCircle instance) =>
    <String, dynamic>{
      'id': instance.id,
      'centerX': instance.centerX,
      'centerY': instance.centerY,
      'radiusX': instance.radiusX,
      'radiusY': instance.radiusY,
      'colorValue': instance.colorValue,
      'locked': instance.locked,
      'zIndex': instance.zIndex,
    };
