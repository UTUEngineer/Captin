import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:three_js/three_js.dart' as three;
import '../core/config/app_config.dart';
import '../services/tactical_session_service.dart';

class TacticalBoardRepository {
  TacticalBoardRepository._();
  static final TacticalBoardRepository instance = TacticalBoardRepository._();

  SupabaseClient? get _client {
    if (!AppConfig.isSupabaseConfigured) return null;
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  /// حفظ خطة جديدة أو تحديث خطة سابقة
  Future<String?> saveTactic({
    String? boardId,
    required String title,
    required String formation,
    String? opponentName,
    String? matchNotes,
    required List<TacticalPlayerModel> players,
    Map<String, dynamic>? aiReport,
  }) async {
    final client = _client;
    if (client == null) {
      debugPrint('Error: Supabase is not configured.');
      return null;
    }

    final user = client.auth.currentUser;
    if (user == null) {
      debugPrint('Error: User is not authenticated.');
      return null;
    }

    // تجهيز مصفوفة اللاعبين بصيغة JSONB
    final List<Map<String, dynamic>> playersJson = players.map((p) {
      return {
        'id': p.id,
        'name': p.name,
        'number': p.number,
        'position': p.position,
        'team': p.team,
        'coords3D': {
          'x': p.coords3D.x,
          'y': p.coords3D.y,
          'z': p.coords3D.z,
        },
        'strengths': p.strengths,
        'weaknesses': p.weaknesses,
      };
    }).toList();

    final payload = {
      'user_id': user.id,
      'title': title,
      'formation': formation,
      'opponent_name': opponentName,
      'match_notes': matchNotes,
      'players_payload': playersJson,
      'ai_scouting_report': aiReport,
      'updated_at': DateTime.now().toIso8601String(),
    };

    try {
      if (boardId != null && boardId.isNotEmpty) {
        // تحديث خطة قائمة
        final response = await client
            .from('tactical_boards')
            .update(payload)
            .eq('id', boardId)
            .select('id')
            .single();
        return response['id'] as String;
      } else {
        // إدراج خطة جديدة
        final response = await client
            .from('tactical_boards')
            .insert(payload)
            .select('id')
            .single();
        return response['id'] as String;
      }
    } catch (e) {
      debugPrint('Supabase Save Tactic Error: $e');
      return null;
    }
  }

  /// جلب جميع الخطط المحفوظة الخاصة بالمدرب
  Future<List<Map<String, dynamic>>> fetchSavedTactics() async {
    final client = _client;
    if (client == null) return [];

    try {
      final response = await client
          .from('tactical_boards')
          .select('id, title, formation, opponent_name, created_at, updated_at')
          .order('updated_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Supabase Fetch Tactics Error: $e');
      return [];
    }
  }

  /// تحميل خطة بالكامل وتطبيقها على الملعب 3D
  Future<bool> loadTacticToPlayground(String boardId) async {
    final client = _client;
    if (client == null) return false;

    try {
      final data = await client
          .from('tactical_boards')
          .select()
          .eq('id', boardId)
          .single();

      final List rawPlayers = data['players_payload'] ?? [];
      final List<TacticalPlayerModel> loadedSquad = rawPlayers.map((p) {
        final coords = p['coords3D'] ?? {};
        return TacticalPlayerModel(
          id: p['id']?.toString() ?? '',
          name: p['name'] ?? '',
          number: p['number'] ?? 0,
          position: p['position'] ?? 'MID',
          team: p['team'] ?? 'home',
          coords3D: three.Vector3(
            (coords['x'] as num?)?.toDouble() ?? 0.0,
            (coords['y'] as num?)?.toDouble() ?? 0.0,
            (coords['z'] as num?)?.toDouble() ?? 0.0,
          ),
          strengths: List<String>.from(p['strengths'] ?? []),
          weaknesses: List<String>.from(p['weaknesses'] ?? []),
        );
      }).toList();

      TacticalSessionService.instance.importSquadToTactics(
        matchTitle: data['title'] ?? 'خطة تكتيكية',
        formation: data['formation'] ?? '4-3-3',
        squad: loadedSquad,
      );

      return true;
    } catch (e) {
      debugPrint('Supabase Load Tactic Error: $e');
      return false;
    }
  }

  /// حذف خطة من السحابة
  Future<bool> deleteTactic(String boardId) async {
    final client = _client;
    if (client == null) return false;

    try {
      await client.from('tactical_boards').delete().eq('id', boardId);
      return true;
    } catch (e) {
      debugPrint('Supabase Delete Tactic Error: $e');
      return false;
    }
  }
}
