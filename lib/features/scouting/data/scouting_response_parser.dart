import 'dart:convert';

import 'package:captain/features/scouting/domain/report_type.dart';
import 'package:captain/features/scouting/domain/scouting_report.dart';
import 'package:captain/features/scouting/domain/scouting_report_failure.dart';
import 'package:uuid/uuid.dart';

class ScoutingResponseParser {
  ScoutingResponseParser({Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  final Uuid _uuid;

  ScoutingReport parse({
    required String matchId,
    required ReportType reportType,
    required String rawText,
  }) {
    final payload = _extractJson(rawText);
    if (payload == null) {
      return ScoutingReport(
        id: _uuid.v4(),
        matchId: matchId,
        reportType: reportType,
        generatedAt: DateTime.now(),
        arabicContent: rawText.trim(),
        keyFindings: const [],
        playerRatings: const {},
        tacticalNotes: '',
      );
    }

    final arabicContent = payload['arabicContent'] as String? ?? rawText.trim();
    final keyFindings = _readStringList(payload['keyFindings']);
    final playerRatings = _readRatings(payload['playerRatings']);
    final tacticalNotes = payload['tacticalNotes'] as String? ?? '';

    return ScoutingReport(
      id: _uuid.v4(),
      matchId: matchId,
      reportType: reportType,
      generatedAt: DateTime.now(),
      arabicContent: arabicContent,
      keyFindings: keyFindings,
      playerRatings: playerRatings,
      tacticalNotes: tacticalNotes,
    );
  }

  Map<String, dynamic>? _extractJson(String rawText) {
    final trimmed = rawText.trim();
    try {
      final decoded = jsonDecode(trimmed);
      if (decoded is Map<String, dynamic>) return decoded;
    } catch (_) {
      // Fall through to fenced block extraction.
    }

    final start = trimmed.indexOf('{');
    final end = trimmed.lastIndexOf('}');
    if (start == -1 || end <= start) return null;

    try {
      final decoded = jsonDecode(trimmed.substring(start, end + 1));
      if (decoded is Map<String, dynamic>) return decoded;
    } catch (_) {
      return null;
    }
    return null;
  }

  List<String> _readStringList(Object? value) {
    if (value is! List) return const [];
    return value.map((item) => item.toString()).where((item) => item.isNotEmpty).toList();
  }

  Map<String, double> _readRatings(Object? value) {
    if (value is! Map) return const {};
    final ratings = <String, double>{};
    value.forEach((key, rawRating) {
      final rating = switch (rawRating) {
        num number => number.toDouble(),
        String text => double.tryParse(text),
        _ => null,
      };
      if (rating != null) {
        ratings[key.toString()] = rating.clamp(0, 10);
      }
    });
    return ratings;
  }
}

typedef ScoutingReportResult = ({
  ScoutingReport? report,
  ScoutingReportFailure? failure,
});

ScoutingReportResult scoutingSuccess(ScoutingReport report) =>
    (report: report, failure: null);

ScoutingReportResult scoutingFailure(ScoutingReportFailure failure) =>
    (report: null, failure: failure);
