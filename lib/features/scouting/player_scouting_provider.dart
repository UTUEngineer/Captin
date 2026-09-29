import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/supabase_client.dart';
import 'player_dossier_model.dart';

class PlayerScoutingRepository {
  final SupabaseClient _supabase;

  PlayerScoutingRepository(this._supabase);

  /// Fetch full relational player profile in 1 round-trip
  Future<PlayerFullDossier> getPlayerDossier(String playerId) async {
    final response = await _supabase
        .from('players')
        .select('''
          *,
          teams ( name, league_name, logo_url ),
          player_attributes ( * ),
          player_match_logs ( * ),
          ai_scouting_reports ( * )
        ''')
        .eq('id', playerId)
        .order('match_date', ascending: false, referencedTable: 'player_match_logs')
        .single();

    return PlayerFullDossier.fromSupabase(response);
  }
}

final playerScoutingRepositoryProvider = Provider<PlayerScoutingRepository>((ref) {
  final client = ref.watch(supabaseProvider);
  return PlayerScoutingRepository(client);
});

// Family provider to dynamically fetch any player by ID
final playerDossierProvider =
    FutureProvider.family<PlayerFullDossier, String>((ref, playerId) async {
  final repo = ref.watch(playerScoutingRepositoryProvider);
  return repo.getPlayerDossier(playerId);
});
