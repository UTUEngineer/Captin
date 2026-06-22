import 'package:captain/features/training/domain/training_prop_type.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'training_prop.freezed.dart';
part 'training_prop.g.dart';

class TrainingPropTypeConverter
    implements JsonConverter<TrainingPropType, String> {
  const TrainingPropTypeConverter();

  @override
  TrainingPropType fromJson(String json) {
    return TrainingPropTypeJson.fromWire(json) ?? TrainingPropType.cone;
  }

  @override
  String toJson(TrainingPropType object) => object.wireName;
}

@freezed
abstract class TrainingProp with _$TrainingProp {
  const factory TrainingProp({
    required String id,
    @TrainingPropTypeConverter() required TrainingPropType type,
    required double x,
    required double y,
    @Default(0.0) double rotation,
    int? colorValue,
    String? label,
  }) = _TrainingProp;

  factory TrainingProp.fromJson(Map<String, dynamic> json) =>
      _$TrainingPropFromJson(json);
}

extension TrainingPropColors on TrainingProp {
  Color get color {
    if (colorValue != null) return Color(colorValue!);
    return type.defaultColor;
  }
}
