import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/config/app_config.dart';

class FootballApiService {
  FootballApiService._();
  static final FootballApiService instance = FootballApiService._();

  final String _baseUrl = 'https://v3.football.api-sports.io';

  Map<String, String> get _headers => {
        'x-rapidapi-key': AppConfig.apiFootballKey,
        'x-rapidapi-host': AppConfig.apiFootballHost,
      };

  SupabaseClient? get _supabaseClient {
    if (!AppConfig.isSupabaseConfigured) return null;
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  /// جلب المباريات القادمة أو الحالية لدوري معين
  Future<List<Map<String, dynamic>>> getUpcomingFixtures({
    required int leagueId,
    required int season,
    int count = 10,
  }) async {
    final uri = Uri.parse(
      '$_baseUrl/fixtures?league=$leagueId&season=$season&next=$count',
    );

    try {
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List fixtures = data['response'] ?? [];
        if (fixtures.isNotEmpty) {
          return fixtures.cast<Map<String, dynamic>>();
        }
      }
    } catch (e) {
      debugPrint('Error fetching fixtures: $e');
    }

    // Fallback لدوري نجوم العراق عند عدم توفر API خارجي أو نفاذ الحصة
    if (leagueId == 382) {
      return _getLocalIraqFixtures();
    }

    return [];
  }

  List<Map<String, dynamic>> _getLocalIraqFixtures() {
    final now = DateTime.now();
    return [
      {
        'fixture': {
          'id': 1001,
          'date': now.toIso8601String(),
        },
        'teams': {
          'home': {'name': 'نادي الزوراء'},
          'away': {'name': 'نادي الشرطة'},
        },
      },
      {
        'fixture': {
          'id': 1002,
          'date': now.add(const Duration(days: 1)).toIso8601String(),
        },
        'teams': {
          'home': {'name': 'نادي القوة الجوية'},
          'away': {'name': 'نادي الطلبة'},
        },
      },
      {
        'fixture': {
          'id': 1003,
          'date': now.add(const Duration(days: 2)).toIso8601String(),
        },
        'teams': {
          'home': {'name': 'نادي زاخو'},
          'away': {'name': 'نادي أربيل'},
        },
      },
      {
        'fixture': {
          'id': 1004,
          'date': now.add(const Duration(days: 3)).toIso8601String(),
        },
        'teams': {
          'home': {'name': 'نادي دهوك'},
          'away': {'name': 'نادي الميناء'},
        },
      },
      {
        'fixture': {
          'id': 1005,
          'date': now.add(const Duration(days: 4)).toIso8601String(),
        },
        'teams': {
          'home': {'name': 'نادي النفط'},
          'away': {'name': 'نادي النجف'},
        },
      },
    ];
  }

  /// جلب التشكيلة الرسمية لمباراة معينة مع التخزين المؤقت في Supabase (Hybrid Caching Mode)
  Future<Map<String, dynamic>?> getFixtureLineups(int fixtureId) async {
    // 1. المحاولة الأولى: فحص التخزين المؤقت المحلي بـ Supabase (تستهلك 0 طلبات API)
    final client = _supabaseClient;
    if (client != null) {
      try {
        final cached = await client
            .from('cached_lineups')
            .select()
            .eq('fixture_id', fixtureId)
            .maybeSingle();

        if (cached != null && cached['home_lineup'] != null) {
          debugPrint('Lineup fetched from Supabase cache (0 API calls used)!');
          return {
            'home': cached['home_lineup'],
            'away': cached['away_lineup'],
          };
        }
      } catch (e) {
        debugPrint('Supabase Cache fetch error: $e');
      }
    }

    // 2. المحاولة الثانية: جلب التشكيلة مباشرة من API-Football عند عدم التخزين مسبقاً
    final uri = Uri.parse('$_baseUrl/fixtures/lineups?fixture=$fixtureId');

    try {
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List lineups = data['response'] ?? [];
        if (lineups.isNotEmpty) {
          final result = {
            'home': lineups[0],
            'away': lineups.length > 1 ? lineups[1] : null,
          };

          // 3. حفظ التشكيلة في Supabase لخدمة الطلبات المستقبليّة بـ 0 طلبات API
          if (client != null) {
            try {
              await client.from('cached_lineups').upsert({
                'fixture_id': fixtureId,
                'home_lineup': result['home'],
                'away_lineup': result['away'],
              });
            } catch (e) {
              debugPrint('Failed to save lineup to Supabase cache: $e');
            }
          }

          return result;
        }
      }
    } catch (e) {
      debugPrint('Error fetching lineups from API: $e');
    }
    return null;
  }

  /// في حالة عدم توفر رصيد API خارجي، يتم الجلب من Supabase مجاناً (Free Tier Fallback)
  Future<Map<String, dynamic>?> getTeamLineupFree(String teamName) async {
    final client = _supabaseClient;
    if (client == null) return null;

    try {
      final response = await client
          .from('local_teams')
          .select()
          .ilike('name', '%$teamName%')
          .maybeSingle();

      if (response != null) {
        final List startingXi = response['starting_xi'] is List
            ? response['starting_xi']
            : jsonDecode(response['starting_xi'].toString());

        final formattedXI = startingXi.map((p) {
          return {
            'player': {
              'id': p['id'] ?? 'p_${p['number']}',
              'name': p['name'] ?? '',
              'number': p['number'] ?? 0,
              'pos': p['pos'] ?? 'M',
              'grid': p['grid'] ?? '1:1',
            },
          };
        }).toList();

        return {
          'team': {'name': response['name']},
          'teamName': response['name'],
          'formation': response['formation'] ?? '4-3-3',
          'startXI': formattedXI,
          'players': startingXi,
        };
      }
    } catch (e) {
      debugPrint('Supabase Local fetch error: $e');
    }
    return null;
  }
}
