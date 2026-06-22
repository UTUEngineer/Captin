import 'package:captain/features/video_analysis/domain/analysis_result.dart';
import 'package:captain/features/video_analysis/domain/analysis_result_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('aggregateHeatmap normalizes summed player grids', () {
    const result = AnalysisResult(
      videoId: 'v1',
      durationSeconds: 60,
      tracks: [],
      players: [
        PlayerAnalytics(
          trackId: 1,
          distanceKm: 1,
          sprintCount: 1,
          maxSpeedKmh: 20,
          heatmap: [
            [1, 0],
            [0, 2],
          ],
        ),
        PlayerAnalytics(
          trackId: 2,
          distanceKm: 1,
          sprintCount: 1,
          maxSpeedKmh: 20,
          heatmap: [
            [1, 0],
            [0, 1],
          ],
        ),
      ],
    );

    final grid = result.aggregateHeatmap();
    expect(grid[0][0], closeTo(2 / 3, 0.001));
    expect(grid[1][1], 1);
  });

  test('playersAt interpolates between track samples', () {
    const result = AnalysisResult(
      videoId: 'v1',
      durationSeconds: 10,
      tracks: [
        VideoTrack(
          trackId: 3,
          positions: [
            TrackPosition(x: 0.2, y: 0.2, timestampSeconds: 0),
            TrackPosition(x: 0.8, y: 0.8, timestampSeconds: 2),
          ],
        ),
      ],
    );

    final players = result.playersAt(1);
    expect(players.single.x, closeTo(0.5, 0.001));
    expect(players.single.y, closeTo(0.5, 0.001));
  });
}
