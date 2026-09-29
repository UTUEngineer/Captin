import 'dart:convert';
import 'package:http/http.dart' as http;

class FootballApiService {
  static const String _baseUrl = 'https://v3.football.api-sports.io';
  final String apiKey;

  FootballApiService({required this.apiKey});

  Map<String, String> get _headers => {
        'x-apisports-key': apiKey,
        'Content-Type': 'application/json',
      };

  /// Fetch players by league and season (e.g. Iraq Stars League or Premier League)
  Future<List<Map<String, dynamic>>> fetchSquadPlayers({
    required int teamId,
    required int season,
  }) async {
    final uri = Uri.parse('$_baseUrl/players?team=$teamId&season=$season');
    final response = await http.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final List results = (data['response'] as List?) ?? [];
      return results.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to fetch squad: ${response.statusCode} - ${response.body}');
    }
  }
}
