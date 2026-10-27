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
    this.round,
    this.venue,
    this.referee,
    this.elapsed,
  });

  final int id;
  final DateTime date;
  final String statusShort;
  final Team homeTeam;
  final Team awayTeam;
  final int? homeGoals;
  final int? awayGoals;
  final String? round;
  final String? venue;
  final String? referee;
  final int? elapsed;

  bool get isUpcoming => !isFinished && !isLive && statusShort != 'HT';

  /// 1 = home win, 0 = draw, -1 = away win; null if not played.
  int? get outcome {
    if (homeGoals == null || awayGoals == null || !isFinished) return null;
    return (homeGoals! - awayGoals!).sign;
  }

  bool get isLive => statusShort == 'LIVE' || statusShort == '1H' || statusShort == '2H';

  bool get isFinished =>
      statusShort == 'FT' || statusShort == 'AET' || statusShort == 'PEN';

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
    final league = json['league'] as Map<String, dynamic>? ?? {};
    final venue = fixture['venue'] as Map<String, dynamic>?;

    return MatchFixture(
      id: fixture['id'] as int,
      date: DateTime.parse(fixture['date'] as String),
      statusShort: status['short'] as String? ?? 'NS',
      homeTeam: Team.fromJson(teams['home'] as Map<String, dynamic>),
      awayTeam: Team.fromJson(teams['away'] as Map<String, dynamic>),
      homeGoals: goals['home'] as int?,
      awayGoals: goals['away'] as int?,
      round: league['round'] as String?,
      venue: venue?['name'] as String?,
      referee: fixture['referee'] as String?,
      elapsed: status['elapsed'] as int?,
    );
  }
}
