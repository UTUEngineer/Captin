// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'training_session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TrainingSession _$TrainingSessionFromJson(Map<String, dynamic> json) =>
    _TrainingSession(
      id: json['id'] as String,
      name: json['name'] as String,
      notes: json['notes'] as String? ?? '',
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
      boardTemplate: json['boardTemplate'] == null
          ? null
          : TacticBoardTemplate.fromJson(
              json['boardTemplate'] as Map<String, dynamic>,
            ),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$TrainingSessionToJson(_TrainingSession instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'notes': instance.notes,
      'props': instance.props,
      'paths': instance.paths,
      'boardTemplate': instance.boardTemplate,
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
