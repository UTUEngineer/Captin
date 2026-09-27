import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../core/config/app_config.dart';

class ClaudeScoutingService {
  ClaudeScoutingService._();
  static final ClaudeScoutingService instance = ClaudeScoutingService._();

  static const String _anthropicUrl = 'https://api.anthropic.com/v1/messages';

  Future<Map<String, dynamic>?> analyzeOpponentTactics({
    required String teamName,
    required String formation,
    required List<Map<String, dynamic>> players,
  }) async {
    final playerSummary = players.map((entry) {
      final p = entry['player'] ?? entry;
      final name = p['name'] ?? 'لاعب';
      final number = p['number'] ?? 0;
      final pos = p['pos'] ?? 'M';
      return "$name (#$number - $pos)";
    }).join(", ");

    final prompt = """
    أنت مدرب ومحلل تكتيكي محترف حاصل على شهادة UEFA Pro.
    قم بتحليل التشكيلة التالية لفريق $teamName بنظام $formation:
    اللاعبون الأساسيون: $playerSummary.

    المطلوب منك تحليل سريع ودقيق يخدم المدرب قبل المباراة، ويجب أن يكون الرد بصيغة JSON فقط بهذا الشكل:
    {
      "team_vulnerability": "نقطة الضعف التكتيكية الرئيسية للفريق (مثال: المساحات خلف الأظهرة أو بطء قلبي الدفاع)",
      "team_strength": "أكبر مصدر خطورة للفريق (مثال: التحولات الهجومية السريعة عبر الأجنحة)",
      "recommended_counter_strategy": "الخطة المقترحة لضرب هذا الفريق تكتيكياً",
      "counter_formation": "4-2-3-1",
      "key_player_to_press": {
        "name": "اسم أهم لاعب يجب تضييق المساحات عليه وصانع اللعب لديهم",
        "reason": "سبب استهدافه بالضغط"
      }
    }
    """;

    try {
      final res = await http.post(
        Uri.parse(_anthropicUrl),
        headers: {
          'x-api-key': AppConfig.anthropicApiKey,
          'anthropic-version': '2023-06-01',
          'content-type': 'application/json',
        },
        body: jsonEncode({
          'model': 'claude-3-5-sonnet-20241022',
          'max_tokens': 1000,
          'messages': [
            {'role': 'user', 'content': prompt}
          ],
        }),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(utf8.decode(res.bodyBytes));
        final String content = data['content'][0]['text'];

        // استخراج الـ JSON الصافي من رد الـ AI
        final jsonStart = content.indexOf('{');
        final jsonEnd = content.lastIndexOf('}') + 1;
        if (jsonStart != -1 && jsonEnd != -1) {
          return jsonDecode(content.substring(jsonStart, jsonEnd));
        }
      } else {
        debugPrint('Claude API Error: ${res.statusCode} - ${res.body}');
      }
      return null;
    } catch (e) {
      debugPrint('Error calling Claude AI: $e');
      return null;
    }
  }
}
