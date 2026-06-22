import 'package:captain/features/video_analysis/domain/standard_penalty_box_calibration.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'calibration_point.freezed.dart';
part 'calibration_point.g.dart';

@freezed
abstract class CalibrationPoint with _$CalibrationPoint {
  const factory CalibrationPoint({
    required List<double> pixel,
    required List<double> pitch,
  }) = _CalibrationPoint;

  factory CalibrationPoint.fromJson(Map<String, dynamic> json) =>
      _$CalibrationPointFromJson(json);
}

List<CalibrationPoint> buildCalibrationPoints({
  required List<List<double>> pixels,
}) {
  return List.generate(StandardPenaltyBoxCalibration.pitchCorners.length, (index) {
    return CalibrationPoint(
      pixel: pixels[index],
      pitch: StandardPenaltyBoxCalibration.pitchCorners[index],
    );
  });
}
