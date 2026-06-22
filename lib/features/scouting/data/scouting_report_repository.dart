import 'dart:convert';
import 'dart:io';

import 'package:captain/features/scouting/data/claude_api_key_store.dart';
import 'package:captain/features/scouting/data/scouting_prompt_builder.dart';
import 'package:captain/features/scouting/data/scouting_response_parser.dart';
import 'package:captain/features/scouting/domain/match_analysis_data.dart';
import 'package:captain/features/scouting/domain/report_type.dart';
import 'package:captain/features/scouting/domain/scouting_report.dart';
import 'package:captain/features/scouting/domain/scouting_report_failure.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class ScoutingReportRepository {
  ScoutingReportRepository({
    required ClaudeApiKeyStore apiKeyStore,
    http.Client? httpClient,
    ScoutingResponseParser? parser,
  })  : _apiKeyStore = apiKeyStore,
        _httpClient = httpClient ?? http.Client(),
        _parser = parser ?? ScoutingResponseParser();

  static const _messagesUrl = 'https://api.anthropic.com/v1/messages';
  static const _anthropicVersion = '2023-06-01';
  static const _model = 'claude-sonnet-4-20250514';
  static const _maxRetries = 3;

  final ClaudeApiKeyStore _apiKeyStore;
  final http.Client _httpClient;
  final ScoutingResponseParser _parser;

  Future<ScoutingReportResult> generateReport(
    MatchAnalysisData data,
    ReportType type,
  ) async {
    final apiKey = await _apiKeyStore.readApiKey();
    if (apiKey == null || apiKey.trim().isEmpty) {
      return scoutingFailure(const MissingApiKeyFailure());
    }

    try {
      final rawText = await _callClaudeWithRetry(
        apiKey: apiKey.trim(),
        userPrompt: ScoutingPromptBuilder.buildUserPrompt(data, type),
      );
      final report = _parser.parse(
        matchId: data.matchId,
        reportType: type,
        rawText: rawText,
      );
      return scoutingSuccess(report);
    } on RateLimitFailure catch (error) {
      return scoutingFailure(error);
    } on NetworkFailure catch (error) {
      return scoutingFailure(error);
    } on ServerFailure catch (error) {
      return scoutingFailure(error);
    } on ParseFailure catch (error) {
      return scoutingFailure(error);
    } catch (error) {
      return scoutingFailure(NetworkFailure(error.toString()));
    }
  }

  Future<String> testApiKey(String apiKey) async {
    return _callClaudeWithRetry(
      apiKey: apiKey.trim(),
      userPrompt: 'رد بكلمة واحدة فقط: مرحبا',
      maxTokens: 32,
    );
  }

  Future<ScoutingReport> exportReportPdf(ScoutingReport report) async {
    final document = pw.Document();
    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return [
            pw.Text(
              report.reportType.arabicLabel,
              style: pw.TextStyle(
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Text(report.generatedAt.toIso8601String()),
            pw.SizedBox(height: 16),
            pw.Text(report.arabicContent),
            if (report.keyFindings.isNotEmpty) ...[
              pw.SizedBox(height: 16),
              pw.Text('Key findings', style: pw.TextStyle(fontSize: 14)),
              for (final finding in report.keyFindings) pw.Bullet(text: finding),
            ],
            if (report.tacticalNotes.isNotEmpty) ...[
              pw.SizedBox(height: 16),
              pw.Text('Tactical notes'),
              pw.Text(report.tacticalNotes),
            ],
          ];
        },
      ),
    );

    final directory = await getTemporaryDirectory();
    final file = File(
      '${directory.path}/scouting_report_${report.id}.pdf',
    );
    await file.writeAsBytes(await document.save());
    return report.copyWith(exportedPdfPath: file.path);
  }

  Future<String> _callClaudeWithRetry({
    required String apiKey,
    required String userPrompt,
    int maxTokens = 4096,
  }) async {
    Object? lastError;

    for (var attempt = 0; attempt < _maxRetries; attempt++) {
      try {
        return await _callClaude(
          apiKey: apiKey,
          userPrompt: userPrompt,
          maxTokens: maxTokens,
        );
      } on RateLimitFailure catch (error) {
        lastError = error;
        if (attempt == _maxRetries - 1) rethrow;
        await Future<void>.delayed(Duration(milliseconds: 500 * (1 << attempt)));
      } catch (error) {
        lastError = error;
        rethrow;
      }
    }

    throw lastError ?? const NetworkFailure('Unknown Claude API error.');
  }

  Future<String> _callClaude({
    required String apiKey,
    required String userPrompt,
    required int maxTokens,
  }) async {
    final response = await _httpClient.post(
      Uri.parse(_messagesUrl),
      headers: {
        'x-api-key': apiKey,
        'anthropic-version': _anthropicVersion,
        'content-type': 'application/json',
      },
      body: jsonEncode({
        'model': _model,
        'max_tokens': maxTokens,
        'system': ScoutingPromptBuilder.systemPrompt,
        'messages': [
          {'role': 'user', 'content': userPrompt},
        ],
      }),
    );

    if (response.statusCode == 429) {
      throw const RateLimitFailure();
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ServerFailure(
        'Claude API error (${response.statusCode}): ${response.body}',
      );
    }

    final payload = jsonDecode(response.body);
    if (payload is! Map<String, dynamic>) {
      throw const ParseFailure('Unexpected Claude response shape.');
    }

    final content = payload['content'];
    if (content is! List || content.isEmpty) {
      throw const ParseFailure('Claude response did not include content.');
    }

    final first = content.first;
    if (first is Map<String, dynamic> && first['text'] is String) {
      return first['text'] as String;
    }

    throw const ParseFailure('Could not read Claude text content.');
  }

  void dispose() {
    _httpClient.close();
  }
}
