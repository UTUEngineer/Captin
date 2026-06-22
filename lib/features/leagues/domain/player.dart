class Player {
  const Player({
    required this.id,
    required this.name,
    required this.nameAr,
    this.age,
    this.nationality,
    this.photo,
    this.position,
    this.number,
  });

  final int id;
  final String name;
  final String nameAr;
  final int? age;
  final String? nationality;
  final String? photo;
  final String? position;
  final String? number;

  factory Player.fromJson(Map<String, dynamic> json) {
    final player = json['player'] as Map<String, dynamic>;
    final statistics = json['statistics'] as List<dynamic>?;
    final games = statistics != null && statistics.isNotEmpty
        ? (statistics.first as Map<String, dynamic>)['games']
            as Map<String, dynamic>?
        : null;

    return Player(
      id: player['id'] as int,
      name: player['name'] as String,
      nameAr: player['name'] as String,
      age: player['age'] as int?,
      nationality: player['nationality'] as String?,
      photo: player['photo'] as String?,
      position: games?['position'] as String?,
      number: games?['number']?.toString(),
    );
  }

  String get positionAr {
    const map = {
      'Goalkeeper': 'حارس مرمى',
      'Defender': 'مدافع',
      'Midfielder': 'وسط',
      'Attacker': 'مهاجم',
    };
    return map[position] ?? position ?? '';
  }
}

class PlayerStats {
  const PlayerStats({
    required this.player,
    required this.goals,
    required this.assists,
    required this.appearances,
    required this.yellowCards,
    required this.redCards,
    required this.rating,
    required this.minutesPlayed,
  });

  final Player player;
  final int goals;
  final int assists;
  final int appearances;
  final int yellowCards;
  final int redCards;
  final double rating;
  final int minutesPlayed;

  factory PlayerStats.fromJson(Map<String, dynamic> json) {
    final stats = (json['statistics'] as List<dynamic>).first as Map<String, dynamic>;
    final goals = stats['goals'] as Map<String, dynamic>? ?? {};
    final games = stats['games'] as Map<String, dynamic>? ?? {};
    final cards = stats['cards'] as Map<String, dynamic>? ?? {};

    return PlayerStats(
      player: Player.fromJson(json),
      goals: goals['total'] as int? ?? 0,
      assists: goals['assists'] as int? ?? 0,
      appearances: games['appearences'] as int? ?? games['appearances'] as int? ?? 0,
      yellowCards: cards['yellow'] as int? ?? 0,
      redCards: cards['red'] as int? ?? 0,
      rating: double.tryParse('${games['rating'] ?? '0'}') ?? 0,
      minutesPlayed: games['minutes'] as int? ?? 0,
    );
  }
}
