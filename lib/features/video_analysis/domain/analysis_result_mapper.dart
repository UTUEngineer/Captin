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
        isHomeTeam: track.team == null ? track.trackId.isEven : track.team != 'B',
        zIndex: isSelected ? 999 : track.trackId,
      );
    }).toList();
  }

  /// Ball position at [timestampSeconds], or null when the ball was not seen
  /// within half a second of that moment.
  ({double x, double y})? ballAt(double timestampSeconds) {
    if (ball.isEmpty) return null;
    TrackPosition? before;
    TrackPosition? after;
    for (final p in ball) {
      if (p.timestampSeconds <= timestampSeconds) before = p;
      if (p.timestampSeconds >= timestampSeconds) {
        after = p;
        break;
      }
    }
    if (before == null && after == null) return null;
    final a = before ?? after!;
    final b = after ?? before!;
    final gap = (b.timestampSeconds - a.timestampSeconds).abs();
    final nearest = (timestampSeconds - a.timestampSeconds).abs() <
            (b.timestampSeconds - timestampSeconds).abs()
        ? a
        : b;
    if ((nearest.timestampSeconds - timestampSeconds).abs() > 0.5) return null;
    if (gap == 0) return (x: a.x, y: a.y);
    final w = ((timestampSeconds - a.timestampSeconds) / gap).clamp(0.0, 1.0);
    return (x: a.x + (b.x - a.x) * w, y: a.y + (b.y - a.y) * w);
  }

  /// Team totals for the summary card.
  ({double distanceKm, int sprints, double topSpeed}) teamTotals(String team) {
    var distance = 0.0;
    var sprints = 0;
    var top = 0.0;
    for (final p in players) {
      final t = p.team ??
          (tracks.where((tr) => tr.trackId == p.trackId).firstOrNull?.team);
      if (t != team) continue;
      distance += p.distanceKm;
      sprints += p.sprintCount;
      if (p.maxSpeedKmh > top) top = p.maxSpeedKmh;
    }
    return (distanceKm: distance, sprints: sprints, topSpeed: top);
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
