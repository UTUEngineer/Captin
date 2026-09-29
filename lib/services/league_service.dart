import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum SupportedLeague {
  iraqStarsLeague,
  // مستقبلاً:
  // aclElite,
  // premierLeague,
}

extension LeagueExtension on SupportedLeague {
  String get key {
    switch (this) {
      case SupportedLeague.iraqStarsLeague:
        return 'iraq_stars_league';
    }
  }

  String get displayName {
    switch (this) {
      case SupportedLeague.iraqStarsLeague:
        return 'دوري نجوم العراق';
    }
  }
}

class LeagueService {
  final SupabaseClient _supabase;

  LeagueService([SupabaseClient? client])
      : _supabase = client ?? Supabase.instance.client;

  /// جلب جدول ترتيب الدوري (الافتراضي: دوري نجوم العراق)
  Future<List<dynamic>> fetchStandings({
    SupportedLeague league = SupportedLeague.iraqStarsLeague,
    int season = 2026,
  }) async {
    try {
      final FunctionResponse response = await _supabase.functions.invoke(
        'football-data',
        body: {
          'endpoint': 'standings',
          'leagueKey': league.key,
          'season': season,
        },
      );

      if (response.status != 200) {
        final String errorMsg = response.data is Map
            ? (response.data['error'] ?? 'فشل جلب جدول الترتيب')
            : 'فشل جلب جدول الترتيب (${response.status})';
        throw Exception(errorMsg);
      }

      final data = response.data['data'] as List<dynamic>;
      return data;
    } catch (e) {
      throw Exception('خطأ في جلب بيانات الدوري: $e');
    }
  }

  /// جلب الجولات والمباريات القادمة
  Future<List<dynamic>> fetchFixtures({
    SupportedLeague league = SupportedLeague.iraqStarsLeague,
    int season = 2026,
  }) async {
    try {
      final FunctionResponse response = await _supabase.functions.invoke(
        'football-data',
        body: {
          'endpoint': 'fixtures',
          'leagueKey': league.key,
          'season': season,
        },
      );

      if (response.status != 200) {
        final String errorMsg = response.data is Map
            ? (response.data['error'] ?? 'فشل جلب المباريات')
            : 'فشل جلب المباريات (${response.status})';
        throw Exception(errorMsg);
      }

      return response.data['data'] as List<dynamic>;
    } catch (e) {
      throw Exception('خطأ في جلب جدول المباريات: $e');
    }
  }
}

/// Provider for LeagueService
final leagueServiceProvider = Provider<LeagueService>((ref) {
  return LeagueService();
});
