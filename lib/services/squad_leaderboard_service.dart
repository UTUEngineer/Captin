import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Leaderboard Player Performance Model
class LeaderboardPlayer {
  final String id;
  final String name;
  final int number;
  final String role;
  final int appearances;
  final int goals;
  final int assists;
  final double avgRating;
  final int mvpCount;

  LeaderboardPlayer({
    required this.id,
    required this.name,
    required this.number,
    required this.role,
    required this.appearances,
    required this.goals,
    required this.assists,
    required this.avgRating,
    required this.mvpCount,
  });

  factory LeaderboardPlayer.fromJson(Map<String, dynamic> json) {
    return LeaderboardPlayer(
      id: json['player_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['player_name']?.toString() ?? json['name']?.toString() ?? 'Player',
      number: (json['jersey_number'] ?? json['number'] ?? 0) as int,
      role: json['role']?.toString() ?? 'CM',
      appearances: (json['appearances'] ?? 0) as int,
      goals: (json['goals'] ?? 0) as int,
      assists: (json['assists'] ?? 0) as int,
      avgRating: (json['avg_rating'] ?? json['avgRating'] ?? 7.0) is num
          ? ((json['avg_rating'] ?? json['avgRating'] ?? 7.0) as num).toDouble()
          : 7.0,
      mvpCount: (json['mvp_count'] ?? json['mvpCount'] ?? 0) as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'player_id': id,
      'player_name': name,
      'jersey_number': number,
      'role': role,
      'appearances': appearances,
      'goals': goals,
      'assists': assists,
      'avg_rating': avgRating,
      'mvp_count': mvpCount,
    };
  }
}

/// Fallback Default Squad Data for Demo & Offline Mode
final List<LeaderboardPlayer> kDefaultSquadData = [
  LeaderboardPlayer(id: 'p8', name: 'A. Saadoon', number: 10, role: 'CAM', appearances: 14, goals: 9, assists: 11, avgRating: 8.85, mvpCount: 5),
  LeaderboardPlayer(id: 'p10', name: 'A. Hussein', number: 9, role: 'ST', appearances: 13, goals: 12, assists: 3, avgRating: 8.25, mvpCount: 3),
  LeaderboardPlayer(id: 'p6', name: 'I. Bayesh', number: 8, role: 'CM', appearances: 14, goals: 4, assists: 8, avgRating: 8.15, mvpCount: 2),
  LeaderboardPlayer(id: 'p9', name: 'Y. Amyn', number: 7, role: 'RW', appearances: 12, goals: 5, assists: 6, avgRating: 7.85, mvpCount: 1),
  LeaderboardPlayer(id: 'p11', name: 'A. Jasim', number: 11, role: 'LW', appearances: 14, goals: 4, assists: 7, avgRating: 7.70, mvpCount: 1),
  LeaderboardPlayer(id: 'p3', name: 'Z. Tahseen', number: 4, role: 'CB', appearances: 14, goals: 1, assists: 1, avgRating: 7.95, mvpCount: 1),
  LeaderboardPlayer(id: 'p1', name: 'H. Jassim', number: 1, role: 'GK', appearances: 14, goals: 0, assists: 0, avgRating: 7.80, mvpCount: 1),
  LeaderboardPlayer(id: 'p7', name: 'O. Rashid', number: 6, role: 'CDM', appearances: 13, goals: 1, assists: 4, avgRating: 7.65, mvpCount: 0),
  LeaderboardPlayer(id: 'p4', name: 'S. Natiq', number: 5, role: 'CB', appearances: 12, goals: 0, assists: 0, avgRating: 7.45, mvpCount: 0),
  LeaderboardPlayer(id: 'p2', name: 'M. Kareem', number: 2, role: 'RB', appearances: 11, goals: 1, assists: 3, avgRating: 7.30, mvpCount: 0),
  LeaderboardPlayer(id: 'p5', name: 'A. Adnan', number: 3, role: 'LB', appearances: 10, goals: 0, assists: 2, avgRating: 7.15, mvpCount: 0),
];

/// Data Service for Squad Season Leaderboard
class SquadLeaderboardService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<LeaderboardPlayer>> fetchLeaderboard() async {
    try {
      final response = await _supabase
          .from('squad_season_leaderboard')
          .select()
          .order('avg_rating', ascending: false);

      if ((response as List).isNotEmpty) {
        return (response as List)
            .map((item) => LeaderboardPlayer.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return kDefaultSquadData;
    } catch (e) {
      // Fallback demo dataset if network error or unconfigured Supabase view
      return kDefaultSquadData;
    }
  }
}

/// Riverpod Providers
final squadLeaderboardServiceProvider = Provider<SquadLeaderboardService>((ref) {
  return SquadLeaderboardService();
});

final squadLeaderboardProvider = FutureProvider<List<LeaderboardPlayer>>((ref) async {
  final service = ref.watch(squadLeaderboardServiceProvider);
  return await service.fetchLeaderboard();
});
