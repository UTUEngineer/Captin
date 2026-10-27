import 'dart:math' as math;

import 'package:captain/features/leagues/domain/match_fixture.dart';
import 'package:captain/features/leagues/domain/standing.dart';
import 'package:captain/features/leagues/domain/team.dart';

/// Offline sample season used when no API-Football key is configured.
///
/// It builds a full double round-robin for the league's clubs, simulates the
/// rounds already "played" with a seeded RNG (so it is stable between app
/// launches) and derives a complete table — points, goal difference, form and
/// qualification zones — from those results. The UI labels it as sample data.
class SampleSeason {
  SampleSeason._(this.teams, this.fixtures, this.standings);

  final List<Team> teams;
  final List<MatchFixture> fixtures;
  final List<Standing> standings;

  static final Map<int, SampleSeason> _cache = {};

  factory SampleSeason.forLeague(
    int leagueId,
    List<Team> teams, {
    DateTime? now,
    double playedShare = 0.6,
  }) {
    if (now == null && _cache.containsKey(leagueId)) return _cache[leagueId]!;
    final season = _build(leagueId, teams, now ?? DateTime.now(), playedShare);
    if (now == null) _cache[leagueId] = season;
    return season;
  }

  static SampleSeason _build(
    int leagueId,
    List<Team> teams,
    DateTime now,
    double playedShare,
  ) {
    if (teams.length < 2) return SampleSeason._(teams, const [], const []);
    final rng = math.Random(leagueId * 7919 + teams.length);
    // Earlier teams in the list are treated as stronger.
    final strength = {
      for (var i = 0; i < teams.length; i++)
        teams[i].id: 1.0 - (i / teams.length) * 0.55 + rng.nextDouble() * 0.12,
    };

    final rounds = _roundRobin(teams);
    final played = (rounds.length * playedShare).round().clamp(1, rounds.length);
    final today = DateTime(now.year, now.month, now.day, 18);
    final fixtures = <MatchFixture>[];
    var id = leagueId * 100000;

    for (var r = 0; r < rounds.length; r++) {
      final date = today.add(Duration(days: (r - played + 1) * 7 - 3));
      for (final pair in rounds[r]) {
        final home = pair.$1, away = pair.$2;
        final isPlayed = r < played;
        int? hg, ag;
        if (isPlayed) {
          hg = _goals(rng, strength[home.id]! * 1.12, strength[away.id]!);
          ag = _goals(rng, strength[away.id]!, strength[home.id]! * 1.08);
        }
        fixtures.add(
          MatchFixture(
            id: id++,
            date: date.add(Duration(hours: rng.nextInt(4))),
            statusShort: isPlayed ? 'FT' : 'NS',
            homeTeam: home,
            awayTeam: away,
            homeGoals: hg,
            awayGoals: ag,
            round: 'Regular Season - ${r + 1}',
            venue: home.venue,
          ),
        );
      }
    }

    return SampleSeason._(teams, fixtures, computeStandings(teams, fixtures));
  }

  static int _goals(math.Random rng, double attack, double defence) {
    // Poisson-ish goal count driven by relative strength.
    final lambda = (1.35 * attack / defence).clamp(0.3, 3.2);
    final limit = math.exp(-lambda);
    var k = 0;
    var p = 1.0;
    do {
      k++;
      p *= rng.nextDouble();
    } while (p > limit);
    return k - 1;
  }

  /// Circle-method double round robin; returns rounds of (home, away).
  static List<List<(Team, Team)>> _roundRobin(List<Team> input) {
    final teams = [...input];
    if (teams.length.isOdd) {
      teams.add(const Team(id: -1, name: 'BYE', nameAr: 'راحة', logo: '', country: ''));
    }
    final n = teams.length;
    final firstLeg = <List<(Team, Team)>>[];
    final rotating = teams.sublist(1);
    for (var r = 0; r < n - 1; r++) {
      final round = <(Team, Team)>[];
      final lineup = [teams.first, ...rotating];
      for (var i = 0; i < n ~/ 2; i++) {
        final a = lineup[i], b = lineup[n - 1 - i];
        if (a.id == -1 || b.id == -1) continue;
        round.add(r.isEven ? (a, b) : (b, a));
      }
      firstLeg.add(round);
      rotating.insert(0, rotating.removeLast());
    }
    final secondLeg = [
      for (final round in firstLeg) [for (final m in round) (m.$2, m.$1)],
    ];
    return [...firstLeg, ...secondLeg];
  }

  /// Builds a league table (with form and zones) from finished fixtures.
  static List<Standing> computeStandings(
    List<Team> teams,
    List<MatchFixture> fixtures,
  ) {
    final rows = {
      for (final t in teams) t.id: _Row(t),
    };
    final finished = fixtures.where((f) => f.outcome != null).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    for (final f in finished) {
      final home = rows[f.homeTeam.id], away = rows[f.awayTeam.id];
      if (home == null || away == null) continue;
      home.add(f.homeGoals!, f.awayGoals!);
      away.add(f.awayGoals!, f.homeGoals!);
    }
    final sorted = rows.values.toList()
      ..sort((a, b) {
        final byPoints = b.points.compareTo(a.points);
        if (byPoints != 0) return byPoints;
        final byGd = (b.gf - b.ga).compareTo(a.gf - a.ga);
        if (byGd != 0) return byGd;
        return b.gf.compareTo(a.gf);
      });
    final total = sorted.length;
    return [
      for (var i = 0; i < total; i++)
        Standing(
          rank: i + 1,
          teamId: sorted[i].team.id,
          teamName: sorted[i].team.name,
          teamNameAr: sorted[i].team.nameAr,
          teamLogo: sorted[i].team.logo,
          played: sorted[i].played,
          win: sorted[i].w,
          draw: sorted[i].d,
          lose: sorted[i].l,
          points: sorted[i].points,
          goalsFor: sorted[i].gf,
          goalsAgainst: sorted[i].ga,
          form: sorted[i].form.length > 5
              ? sorted[i].form.substring(sorted[i].form.length - 5)
              : sorted[i].form,
          description: i == 0
              ? 'Promotion - AFC Champions League Elite'
              : i <= 2 && total > 6
                  ? 'Promotion - AFC Champions League Two'
                  : i >= total - 2 && total > 6
                      ? 'Relegation'
                      : null,
        ),
    ];
  }
}

class _Row {
  _Row(this.team);

  final Team team;
  int w = 0, d = 0, l = 0, gf = 0, ga = 0;
  String form = '';

  int get played => w + d + l;
  int get points => w * 3 + d;

  void add(int scored, int conceded) {
    gf += scored;
    ga += conceded;
    if (scored > conceded) {
      w++;
      form += 'W';
    } else if (scored == conceded) {
      d++;
      form += 'D';
    } else {
      l++;
      form += 'L';
    }
  }
}
