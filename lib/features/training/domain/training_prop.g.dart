// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'training_prop.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TrainingProp _$TrainingPropFromJson(Map<String, dynamic> json) =>
    _TrainingProp(
      id: json['id'] as String,
      type: const TrainingPropTypeConverter().fromJson(json['type'] as String),
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      rotation: (json['rotation'] as num?)?.toDouble() ?? 0.0,
      colorValue: (json['colorValue'] as num?)?.toInt(),
      label: json['label'] as String?,
    );

Map<String, dynamic> _$TrainingPropToJson(_TrainingProp instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': const TrainingPropTypeConverter().toJson(instance.type),
      'x': instance.x,
      'y': instance.y,
      'rotation': instance.rotation,
      'colorValue': instance.colorValue,
      'label': instance.label,
    };
