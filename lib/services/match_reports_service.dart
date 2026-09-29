import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Player Evaluation Entry
class PlayerEvaluation {
  final String id;
  final int number;
  final String name;
  final String role;
  final double rating;
  final String notes;
  final bool isMvp;

  PlayerEvaluation({
    required this.id,
    required this.number,
    required this.name,
    required this.role,
    required this.rating,
    required this.notes,
    this.isMvp = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'number': number,
        'name': name,
        'role': role,
        'rating': rating,
        'notes': notes,
        'isMvp': isMvp,
      };

  factory PlayerEvaluation.fromJson(Map<String, dynamic> json) {
    return PlayerEvaluation(
      id: json['id'] as String? ?? '',
      number: json['number'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      role: json['role'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 7.0,
      notes: json['notes'] as String? ?? '',
      isMvp: json['isMvp'] as bool? ?? false,
    );
  }
}

/// Match Statistics Overview Model
class MatchStatsModel {
  final int possessionHome;
  final int possessionAway;
  final int shotsHome;
  final int shotsAway;
  final int shotsOnTargetHome;
  final int shotsOnTargetAway;
  final int foulsHome;
  final int foulsAway;

  MatchStatsModel({
    this.possessionHome = 56,
    this.possessionAway = 44,
    this.shotsHome = 14,
    this.shotsAway = 8,
    this.shotsOnTargetHome = 6,
    this.shotsOnTargetAway = 3,
    this.foulsHome = 9,
    this.foulsAway = 12,
  });

  Map<String, dynamic> toJson() => {
        'possessionHome': possessionHome,
        'possessionAway': possessionAway,
        'shotsHome': shotsHome,
        'shotsAway': shotsAway,
        'shotsOnTargetHome': shotsOnTargetHome,
        'shotsOnTargetAway': shotsOnTargetAway,
        'foulsHome': foulsHome,
        'foulsAway': foulsAway,
      };

  factory MatchStatsModel.fromJson(Map<String, dynamic> json) {
    return MatchStatsModel(
      possessionHome: json['possessionHome'] as int? ?? 50,
      possessionAway: json['possessionAway'] as int? ?? 50,
      shotsHome: json['shotsHome'] as int? ?? 0,
      shotsAway: json['shotsAway'] as int? ?? 0,
      shotsOnTargetHome: json['shotsOnTargetHome'] as int? ?? 0,
      shotsOnTargetAway: json['shotsOnTargetAway'] as int? ?? 0,
      foulsHome: json['foulsHome'] as int? ?? 0,
      foulsAway: json['foulsAway'] as int? ?? 0,
    );
  }
}

/// Full Post-Match Report Model
class MatchReportPayload {
  final String? shiftId;
  final String? captainId;
  final int scoreHome;
  final int scoreAway;
  final String matchOutcome; // 'win' | 'draw' | 'loss'
  final MatchStatsModel stats;
  final List<PlayerEvaluation> playerEvaluations;
  final String mvpPlayerId;

  MatchReportPayload({
    this.shiftId,
    this.captainId,
    required this.scoreHome,
    required this.scoreAway,
    required this.matchOutcome,
    required this.stats,
    required this.playerEvaluations,
    required this.mvpPlayerId,
  });

  Map<String, dynamic> toJson() => {
        'shift_id': shiftId,
        'captain_id': captainId,
        'final_score_home': scoreHome,
        'final_score_away': scoreAway,
        'match_outcome': matchOutcome,
        'stats': stats.toJson(),
        'player_evaluations': playerEvaluations.map((e) => e.toJson()).toList(),
        'mvp_player_id': mvpPlayerId,
        'submitted_at': DateTime.now().toIso8601String(),
      };
}

class MatchReportsService {
  final SupabaseClient _supabase;

  MatchReportsService(this._supabase);

  /// Save finalized match report to Supabase Cloud
  Future<bool> exportMatchReport(MatchReportPayload payload) async {
    try {
      await _supabase.from('match_reports').insert(payload.toJson());
      return true;
    } catch (e) {
      return false;
    }
  }
}

/// Riverpod Provider for MatchReportsService
final matchReportsServiceProvider = Provider<MatchReportsService>((ref) {
  return MatchReportsService(Supabase.instance.client);
});
