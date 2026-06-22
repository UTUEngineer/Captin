// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'text_annotation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TextAnnotation _$TextAnnotationFromJson(Map<String, dynamic> json) =>
    _TextAnnotation(
      id: json['id'] as String,
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      text: json['text'] as String,
      locked: json['locked'] as bool? ?? false,
      zIndex: (json['zIndex'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$TextAnnotationToJson(_TextAnnotation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'x': instance.x,
      'y': instance.y,
      'text': instance.text,
      'locked': instance.locked,
      'zIndex': instance.zIndex,
    };
