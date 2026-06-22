// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calibration_point.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CalibrationPoint _$CalibrationPointFromJson(Map<String, dynamic> json) =>
    _CalibrationPoint(
      pixel: (json['pixel'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
      pitch: (json['pitch'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
    );

Map<String, dynamic> _$CalibrationPointToJson(_CalibrationPoint instance) =>
    <String, dynamic>{'pixel': instance.pixel, 'pitch': instance.pitch};
