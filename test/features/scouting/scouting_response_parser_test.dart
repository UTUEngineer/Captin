import 'package:captain/features/scouting/data/scouting_response_parser.dart';
import 'package:captain/features/scouting/domain/report_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parse extracts structured scouting json', () {
    const raw = '''
{
  "arabicContent": "تقرير مباراة قوي.",
  "keyFindings": ["ضغط جيد", "تحرك واسع"],
  "playerRatings": {"T1": 8.0, "T2": "7.2"},
  "tacticalNotes": "الفريق حافظ على شكل 4-3-3."
}
''';

    final report = ScoutingResponseParser().parse(
      matchId: 'match-1',
      reportType: ReportType.matchSummary,
      rawText: raw,
    );

    expect(report.arabicContent, contains('تقرير'));
    expect(report.keyFindings, hasLength(2));
    expect(report.playerRatings['T1'], 8.0);
    expect(report.tacticalNotes, isNotEmpty);
  });

  test('parse falls back to raw text when json missing', () {
    final report = ScoutingResponseParser().parse(
      matchId: 'match-2',
      reportType: ReportType.teamAnalysis,
      rawText: 'تقرير نصي بدون JSON',
    );

    expect(report.arabicContent, 'تقرير نصي بدون JSON');
    expect(report.keyFindings, isEmpty);
  });
}
