import 'package:captain/features/leagues/domain/team.dart';

class Standing {
  const Standing({
    required this.rank,
    required this.teamId,
    required this.teamName,
    required this.teamNameAr,
    required this.teamLogo,
    required this.played,
    required this.win,
    required this.draw,
    required this.lose,
    required this.points,
    required this.goalsFor,
    required this.goalsAgainst,
  });

  final int rank;
  final int teamId;
  final String teamName;
  final String teamNameAr;
  final String teamLogo;
  final int played;
  final int win;
  final int draw;
  final int lose;
  final int points;
  final int goalsFor;
  final int goalsAgainst;

  factory Standing.fromJson(Map<String, dynamic> json) {
    final team = json['team'] as Map<String, dynamic>;
    final all = json['all'] as Map<String, dynamic>;
    final goals = all['goals'] as Map<String, dynamic>;

    return Standing(
      rank: json['rank'] as int,
      teamId: team['id'] as int,
      teamName: team['name'] as String,
      teamNameAr: Team.arabicTeamNames[team['id'] as int] ?? team['name'] as String,
      teamLogo: team['logo'] as String? ?? '',
      played: all['played'] as int,
      win: all['win'] as int,
      draw: all['draw'] as int,
      lose: all['lose'] as int,
      points: json['points'] as int,
      goalsFor: goals['for'] as int,
      goalsAgainst: goals['against'] as int,
    );
  }
}
