import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Match Incident Model for Live Timeline & Persistence
class MatchIncident {
  final String id;
  final String? shiftId;
  final int minute;
  final String eventType; // 'goal' | 'yellow_card' | 'red_card' | 'substitution'
  final String playerId;
  final String playerName;
  final int playerNumber;
  final String? detail;
  final DateTime createdAt;

  MatchIncident({
    required this.id,
    this.shiftId,
    required this.minute,
    required this.eventType,
    required this.playerId,
    required this.playerName,
    required this.playerNumber,
    this.detail,
    required this.createdAt,
  });

  factory MatchIncident.fromJson(Map<String, dynamic> json) {
    String? detailStr;
    if (json['detail'] != null) {
      if (json['detail'] is Map) {
        detailStr = json['detail']['note'] as String?;
      } else {
        detailStr = json['detail'].toString();
      }
    }

    return MatchIncident(
      id: json['id'] as String? ?? '',
      shiftId: json['shift_id'] as String?,
      minute: json['match_minute'] as int? ?? 1,
      eventType: json['event_type'] as String? ?? 'goal',
      playerId: json['player_id'] as String? ?? '',
      playerName: json['player_name'] as String? ?? '',
      playerNumber: json['player_number'] as int? ?? 0,
      detail: detailStr,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'shift_id': shiftId,
        'match_minute': minute,
        'event_type': eventType,
        'player_id': playerId,
        'player_name': playerName,
        'player_number': playerNumber,
        'detail': {'note': detail},
      };
}

class MatchEventsService {
  final SupabaseClient _supabase;

  MatchEventsService(this._supabase);

  /// Log a match incident live to Supabase
  Future<MatchIncident?> logIncident({
    required String? shiftId,
    required int minute,
    required String eventType,
    required String playerId,
    required String playerName,
    required int playerNumber,
    String? detail,
  }) async {
    if (shiftId == null || shiftId.isEmpty) return null;

    try {
      final response = await _supabase.from('match_events').insert({
        'shift_id': shiftId,
        'match_minute': minute,
        'event_type': eventType,
        'player_id': playerId,
        'player_name': playerName,
        'player_number': playerNumber,
        'detail': {'note': detail},
      }).select().single();

      return MatchIncident.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  /// Fetch all logged match incidents for an active shift
  Future<List<MatchIncident>> fetchMatchEvents(String shiftId) async {
    try {
      final response = await _supabase
          .from('match_events')
          .select()
          .eq('shift_id', shiftId)
          .order('match_minute', ascending: false);

      return (response as List)
          .map((json) => MatchIncident.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }
}

/// Riverpod Provider for MatchEventsService
final matchEventsServiceProvider = Provider<MatchEventsService>((ref) {
  return MatchEventsService(Supabase.instance.client);
});
