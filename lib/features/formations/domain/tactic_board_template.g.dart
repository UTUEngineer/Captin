// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tactic_board_template.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TacticBoardTemplate _$TacticBoardTemplateFromJson(Map<String, dynamic> json) =>
    _TacticBoardTemplate(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isPreset: json['isPreset'] as bool? ?? false,
      formation: $enumDecodeNullable(_$FormationTypeEnumMap, json['formation']),
      orientation:
          $enumDecodeNullable(_$PitchOrientationEnumMap, json['orientation']) ??
          PitchOrientation.vertical,
      pitchStyle:
          $enumDecodeNullable(_$PitchStyleEnumMap, json['pitchStyle']) ??
          PitchStyle.striped,
      players:
          (json['players'] as List<dynamic>?)
              ?.map((e) => Player.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      arrows:
          (json['arrows'] as List<dynamic>?)
              ?.map((e) => Arrow.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      zones:
          (json['zones'] as List<dynamic>?)
              ?.map((e) => Zone.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      highlights:
          (json['highlights'] as List<dynamic>?)
              ?.map((e) => HighlightCircle.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      textAnnotations:
          (json['textAnnotations'] as List<dynamic>?)
              ?.map((e) => TextAnnotation.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$TacticBoardTemplateToJson(
  _TacticBoardTemplate instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'updatedAt': instance.updatedAt.toIso8601String(),
  'isPreset': instance.isPreset,
  'formation': _$FormationTypeEnumMap[instance.formation],
  'orientation': _$PitchOrientationEnumMap[instance.orientation]!,
  'pitchStyle': _$PitchStyleEnumMap[instance.pitchStyle]!,
  'players': instance.players,
  'arrows': instance.arrows,
  'zones': instance.zones,
  'highlights': instance.highlights,
  'textAnnotations': instance.textAnnotations,
};

const _$FormationTypeEnumMap = {
  FormationType.f433: 'f433',
  FormationType.f4231: 'f4231',
  FormationType.f442: 'f442',
  FormationType.f352: 'f352',
  FormationType.f4141: 'f4141',
  FormationType.f343: 'f343',
};

const _$PitchOrientationEnumMap = {
  PitchOrientation.vertical: 'vertical',
  PitchOrientation.horizontal: 'horizontal',
};

const _$PitchStyleEnumMap = {
  PitchStyle.solid: 'solid',
  PitchStyle.striped: 'striped',
};
