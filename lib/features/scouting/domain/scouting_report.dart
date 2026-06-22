import 'package:captain/features/scouting/domain/report_type.dart';

class ScoutingReport {
  const ScoutingReport({
    required this.id,
    required this.matchId,
    required this.reportType,
    required this.generatedAt,
    required this.arabicContent,
    required this.keyFindings,
    required this.playerRatings,
    required this.tacticalNotes,
    this.exportedPdfPath,
  });

  final String id;
  final String matchId;
  final ReportType reportType;
  final DateTime generatedAt;
  final String arabicContent;
  final List<String> keyFindings;
  final Map<String, double> playerRatings;
  final String tacticalNotes;
  final String? exportedPdfPath;

  ScoutingReport copyWith({String? exportedPdfPath}) {
    return ScoutingReport(
      id: id,
      matchId: matchId,
      reportType: reportType,
      generatedAt: generatedAt,
      arabicContent: arabicContent,
      keyFindings: keyFindings,
      playerRatings: playerRatings,
      tacticalNotes: tacticalNotes,
      exportedPdfPath: exportedPdfPath ?? this.exportedPdfPath,
    );
  }
}
