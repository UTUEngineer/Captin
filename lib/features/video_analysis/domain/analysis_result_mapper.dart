import 'package:captain/features/tactical_board/domain/player.dart';
import 'package:captain/features/video_analysis/domain/analysis_result.dart';

extension AnalysisResultPlayers on AnalysisResult {
  List<Player> playersAt(double timestampSeconds, {int? highlightTrackId}) {
    return tracks.map((track) {
      final position = _positionAt(track, timestampSeconds);
      final isSelected = highlightTrackId == track.trackId;
      return Player(
        id: 'track-${track.trackId}',
        number: track.trackId,
        x: position.x,
        y: position.y,
        label: 'T${track.trackId}',
        isHomeTeam: track.trackId.isEven,
        zIndex: isSelected ? 999 : track.trackId,
      );
    }).toList();
  }

  PlayerAnalytics? analyticsFor(int trackId) {
    for (final analytics in players) {
      if (analytics.trackId == trackId) return analytics;
    }
    return null;
  }

  List<List<double>> aggregateHeatmap({int? trackId}) {
    if (trackId != null) {
      return analyticsFor(trackId)?.heatmap ?? const [];
    }

    if (players.isEmpty) return const [];
    final rows = players.first.heatmap.length;
    if (rows == 0) return const [];
    final cols = players.first.heatmap.first.length;
    final grid = List.generate(rows, (_) => List<double>.filled(cols, 0));

    for (final analytics in players) {
      for (var row = 0; row < rows; row++) {
        for (var col = 0; col < cols; col++) {
          grid[row][col] += analytics.heatmap[row][col];
        }
      }
    }

    final maxValue = grid
        .expand((row) => row)
        .fold<double>(0, (value, cell) => cell > value ? cell : value);
    if (maxValue <= 0) return grid;

    for (var row = 0; row < rows; row++) {
      for (var col = 0; col < cols; col++) {
        grid[row][col] /= maxValue;
      }
    }
    return grid;
  }

  TrackPosition _positionAt(VideoTrack track, double timestampSeconds) {
    if (track.positions.isEmpty) {
      return const TrackPosition(x: 0.5, y: 0.5, timestampSeconds: 0);
    }

    TrackPosition? before;
    TrackPosition? after;

    for (final position in track.positions) {
      if (position.timestampSeconds <= timestampSeconds) {
        before = position;
      }
      if (position.timestampSeconds >= timestampSeconds) {
        after = position;
        break;
      }
    }

    before ??= track.positions.first;
    after ??= track.positions.last;

    if (before.timestampSeconds == after.timestampSeconds) {
      return before;
    }

    final t = (timestampSeconds - before.timestampSeconds) /
        (after.timestampSeconds - before.timestampSeconds);

    return TrackPosition(
      x: before.x + (after.x - before.x) * t,
      y: before.y + (after.y - before.y) * t,
      timestampSeconds: timestampSeconds,
    );
  }
}
