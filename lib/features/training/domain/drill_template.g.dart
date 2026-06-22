// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drill_template.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DrillTemplate _$DrillTemplateFromJson(Map<String, dynamic> json) =>
    _DrillTemplate(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      props:
          (json['props'] as List<dynamic>?)
              ?.map((e) => TrainingProp.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      paths:
          (json['paths'] as List<dynamic>?)
              ?.map((e) => DrillPath.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      recommendedPlayers: (json['recommendedPlayers'] as num?)?.toInt() ?? 8,
    );

Map<String, dynamic> _$DrillTemplateToJson(_DrillTemplate instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'props': instance.props,
      'paths': instance.paths,
      'recommendedPlayers': instance.recommendedPlayers,
    };
