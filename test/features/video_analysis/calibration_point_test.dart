import 'package:captain/features/video_analysis/domain/calibration_point.dart';
import 'package:captain/features/video_analysis/domain/standard_penalty_box_calibration.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('buildCalibrationPoints pairs pixels with standard pitch corners', () {
    final points = buildCalibrationPoints(
      pixels: const [
        [10, 20],
        [100, 20],
        [100, 80],
        [10, 80],
      ],
    );

    expect(points, hasLength(4));
    expect(points.first.pitch, StandardPenaltyBoxCalibration.pitchCorners.first);
    expect(points.last.pitch, StandardPenaltyBoxCalibration.pitchCorners.last);
    expect(points.first.pixel, [10, 20]);
  });
}
