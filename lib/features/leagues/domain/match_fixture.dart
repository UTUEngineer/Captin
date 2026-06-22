import 'package:captain/features/leagues/domain/team.dart';

class MatchFixture {
  const MatchFixture({
    required this.id,
    required this.date,
    required this.statusShort,
    required this.homeTeam,
    required this.awayTeam,
    this.homeGoals,
    this.awayGoals,
  });

  final int id;
  final DateTime date;
  final String statusShort;
  final Team homeTeam;
  final Team awayTeam;
  final int? homeGoals;
  final int? awayGoals;

  bool get isLive => statusShort == 'LIVE' || statusShort == '1H' || statusShort == '2H';

  bool get isFinished => statusShort == 'FT';

  String get statusLabelAr {
    const map = {
      'NS': 'لم تبدأ',
      'LIVE': 'مباشر',
      '1H': 'الشوط الأول',
      '2H': 'الشوط الثاني',
      'HT': 'استراحة',
      'FT': 'انتهت',
      'PST': 'مؤجلة',
      'CANC': 'ملغاة',
    };
    return map[statusShort] ?? statusShort;
  }

  factory MatchFixture.fromJson(Map<String, dynamic> json) {
    final fixture = json['fixture'] as Map<String, dynamic>;
    final status = fixture['status'] as Map<String, dynamic>;
    final teams = json['teams'] as Map<String, dynamic>;
    final goals = json['goals'] as Map<String, dynamic>? ?? {};

    return MatchFixture(
      id: fixture['id'] as int,
      date: DateTime.parse(fixture['date'] as String),
      statusShort: status['short'] as String? ?? 'NS',
      homeTeam: Team.fromJson(teams['home'] as Map<String, dynamic>),
      awayTeam: Team.fromJson(teams['away'] as Map<String, dynamic>),
      homeGoals: goals['home'] as int?,
      awayGoals: goals['away'] as int?,
    );
  }
}
