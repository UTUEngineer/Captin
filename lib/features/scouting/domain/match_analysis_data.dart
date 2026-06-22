import 'package:captain/features/video_analysis/domain/analysis_result.dart';
import 'package:captain/features/video_analysis/domain/analysis_result_mapper.dart';

class MatchPlayerData {
  const MatchPlayerData({
    required this.name,
    required this.trackId,
    required this.x,
    required this.y,
    required this.distanceKm,
    required this.sprintCount,
    required this.maxSpeedKmh,
    required this.heatmapZoneSummary,
  });

  final String name;
  final int trackId;
  final double x;
  final double y;
  final double distanceKm;
  final int sprintCount;
  final double maxSpeedKmh;
  final String heatmapZoneSummary;
}

class MatchAnalysisData {
  const MatchAnalysisData({
    required this.matchId,
    required this.durationSeconds,
    required this.players,
    this.matchLabel,
    this.possessionDefensive,
    this.possessionMiddle,
    this.possessionAttacking,
  });

  factory MatchAnalysisData.fromAnalysisResult(
    AnalysisResult result, {
    String? matchLabel,
  }) {
    final sampleTime = result.durationSeconds <= 0
        ? 0.0
        : result.durationSeconds / 2;
    final boardPlayers = result.playersAt(sampleTime);
    final analyticsByTrack = {
      for (final analytics in result.players) analytics.trackId: analytics,
    };

    final players = boardPlayers.map((boardPlayer) {
      final trackId = boardPlayer.number;
      final analytics = analyticsByTrack[trackId];
      return MatchPlayerData(
        name: boardPlayer.label ?? 'T$trackId',
        trackId: trackId,
        x: boardPlayer.x,
        y: boardPlayer.y,
        distanceKm: analytics?.distanceKm ?? 0,
        sprintCount: analytics?.sprintCount ?? 0,
        maxSpeedKmh: analytics?.maxSpeedKmh ?? 0,
        heatmapZoneSummary: _summarizeHeatmap(analytics?.heatmap ?? const []),
      );
    }).toList();

    final teamA = result.possessionZones?.teamA;

    return MatchAnalysisData(
      matchId: result.videoId,
      matchLabel: matchLabel,
      durationSeconds: result.durationSeconds,
      players: players,
      possessionDefensive: teamA?.defensive,
      possessionMiddle: teamA?.middle,
      possessionAttacking: teamA?.attacking,
    );
  }

  final String matchId;
  final String? matchLabel;
  final double durationSeconds;
  final List<MatchPlayerData> players;
  final double? possessionDefensive;
  final double? possessionMiddle;
  final double? possessionAttacking;
}

String _summarizeHeatmap(List<List<double>> heatmap) {
  if (heatmap.isEmpty || heatmap.first.isEmpty) {
    return 'لا توجد بيانات حرارية';
  }

  var maxRow = 0;
  var maxCol = 0;
  var maxValue = -1.0;

  for (var row = 0; row < heatmap.length; row++) {
    for (var col = 0; col < heatmap[row].length; col++) {
      if (heatmap[row][col] > maxValue) {
        maxValue = heatmap[row][col];
        maxRow = row;
        maxCol = col;
      }
    }
  }

  final rows = heatmap.length;
  final cols = heatmap.first.length;
  final y = (maxRow + 0.5) / rows;
  final zone = y < 1 / 3
      ? 'الثلث الدفاعي'
      : y < 2 / 3
          ? 'الوسط'
          : 'الثلث الهجومي';
  final lane = maxCol < cols / 3
      ? 'اليسار'
      : maxCol > 2 * cols / 3
          ? 'اليمين'
          : 'الوسط';
  return 'تركيز حراري: $zone / $lane';
}
