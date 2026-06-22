import 'dart:convert';

import 'package:captain/features/scouting/domain/match_analysis_data.dart';
import 'package:captain/features/scouting/domain/report_type.dart';

abstract final class ScoutingPromptBuilder {
  static const systemPrompt =
      'أنت محلل تكتيكي محترف. اكتب تقارير كرة قدم احترافية باللغة العربية بأسلوب مختصر ومحكم.';

  static String buildUserPrompt(MatchAnalysisData data, ReportType type) {
    final buffer = StringBuffer()
      ..writeln('اكتب تقريراً من نوع "${type.arabicLabel}".')
      ..writeln('مدة المباراة: ${_formatDuration(data.durationSeconds)}.')
      ..writeln('معرف المباراة: ${data.matchId}.');

    if (data.matchLabel != null) {
      buffer.writeln('الوصف: ${data.matchLabel}.');
    }

    if (data.possessionDefensive != null &&
        data.possessionMiddle != null &&
        data.possessionAttacking != null) {
      buffer.writeln(
        'استحواذ تقريبي — دفاعي: '
        '${(data.possessionDefensive! * 100).toStringAsFixed(0)}%، '
        'وسط: ${(data.possessionMiddle! * 100).toStringAsFixed(0)}%، '
        'هجومي: ${(data.possessionAttacking! * 100).toStringAsFixed(0)}%.',
      );
    }

    buffer.writeln('\nبيانات اللاعبين:');
    for (final player in data.players) {
      buffer.writeln(
        '- ${player.name} (T${player.trackId}): '
        'موقع (${player.x.toStringAsFixed(2)}, ${player.y.toStringAsFixed(2)}), '
        'مسافة ${player.distanceKm.toStringAsFixed(2)} كم، '
        'عدد السبرنت ${player.sprintCount}، '
        'سرعة قصوى ${player.maxSpeedKmh.toStringAsFixed(1)} كم/س، '
        '${player.heatmapZoneSummary}',
      );
    }

    buffer.writeln(
      '\nأرجع JSON فقط بدون markdown أو شرح إضافي بالشكل التالي:',
    );
    buffer.writeln(jsonEncode(_responseSchemaExample(type)));

    return buffer.toString();
  }

  static Map<String, dynamic> _responseSchemaExample(ReportType type) {
    return {
      'arabicContent': 'نص التقرير الكامل بالعربية...',
      'keyFindings': ['ملاحظة 1', 'ملاحظة 2', 'ملاحظة 3'],
      'playerRatings': {'T1': 7.5, 'T2': 6.8},
      'tacticalNotes': 'ملاحظات تكتيكية مختصرة حسب ${type.apiValue}',
    };
  }

  static String _formatDuration(double seconds) {
    final total = seconds.floor();
    final minutes = total ~/ 60;
    final remaining = total % 60;
    return '$minutes:${remaining.toString().padLeft(2, '0')}';
  }
}
