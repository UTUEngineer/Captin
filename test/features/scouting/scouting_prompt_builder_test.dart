import 'package:captain/features/scouting/data/scouting_prompt_builder.dart';
import 'package:captain/features/scouting/domain/match_analysis_data.dart';
import 'package:captain/features/scouting/domain/report_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('buildUserPrompt includes player stats and report type', () {
    const data = MatchAnalysisData(
      matchId: 'vid-1',
      matchLabel: 'Friendly',
      durationSeconds: 5400,
      players: [
        MatchPlayerData(
          name: 'T1',
          trackId: 1,
          x: 0.4,
          y: 0.5,
          distanceKm: 9.2,
          sprintCount: 4,
          maxSpeedKmh: 29.5,
          heatmapZoneSummary: 'الوسط',
        ),
      ],
      possessionDefensive: 0.3,
      possessionMiddle: 0.4,
      possessionAttacking: 0.3,
    );

    final prompt = ScoutingPromptBuilder.buildUserPrompt(
      data,
      ReportType.playerScouting,
    );

    expect(prompt, contains('استكشاف لاعب'));
    expect(prompt, contains('T1'));
    expect(prompt, contains('9.2'));
    expect(prompt, contains('arabicContent'));
  });
}
