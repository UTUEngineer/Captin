import 'package:captain/features/video_analysis/domain/analysis_result.dart';
import 'package:captain/features/video_analysis/domain/analysis_result_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final result = AnalysisResult.fromJson({
    'video_id': 'v1',
    'duration_seconds': 4.0,
    'tracks': [
      {
        'track_id': 7,
        'team': 'B',
        'positions': [
          {'x': 0.5, 'y': 0.5, 'timestamp_seconds': 0.0},
        ],
      },
    ],
    'players': [
      {
        'track_id': 7,
        'team': 'B',
        'distance_km': 0.4,
        'sprint_count': 2,
        'max_speed_kmh': 29.5,
        'avg_speed_kmh': 7.1,
        'heatmap': [
          [0.0, 1.0],
        ],
      },
    ],
    'ball': [
      {'x': 0.2, 'y': 0.2, 'timestamp_seconds': 1.0},
      {'x': 0.4, 'y': 0.6, 'timestamp_seconds': 2.0},
    ],
    'calibrated': false,
    'summary': {'ball_detected_ratio': 0.8},
  });

  test('parses backend team + ball fields', () {
    expect(result.tracks.single.team, 'B');
    expect(result.calibrated, isFalse);
    expect(result.players.single.avgSpeedKmh, closeTo(7.1, 1e-9));
    expect(result.playersAt(0).single.isHomeTeam, isFalse);
  });

  test('ballAt interpolates and hides when unseen', () {
    final mid = result.ballAt(1.5)!;
    expect(mid.x, closeTo(0.3, 1e-9));
    expect(mid.y, closeTo(0.4, 1e-9));
    expect(result.ballAt(3.5), isNull);
  });

  test('team totals aggregate player analytics', () {
    final b = result.teamTotals('B');
    expect(b.sprints, 2);
    expect(b.topSpeed, 29.5);
  });
}
