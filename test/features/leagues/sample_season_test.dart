import 'package:captain/features/leagues/domain/preset_leagues_data.dart';
import 'package:captain/features/leagues/domain/sample_season.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('sample season builds a consistent double round robin', () {
    final teams = PresetLeaguesData.iraqStarsLeagueClubs;
    final season = SampleSeason.forLeague(290, teams, now: DateTime(2026, 1, 1));

    // 20 teams → 38 rounds × 10 matches.
    expect(season.fixtures.length, 20 * 19);
    expect(season.standings.length, 20);

    final played = season.standings.first.played;
    for (final s in season.standings) {
      expect(s.played, played);
      expect(s.points, s.win * 3 + s.draw);
      expect(s.form.length, lessThanOrEqualTo(5));
    }
    // Sorted by points.
    for (var i = 1; i < season.standings.length; i++) {
      expect(
        season.standings[i - 1].points,
        greaterThanOrEqualTo(season.standings[i].points),
      );
    }
    final goalsFor = season.standings.fold<int>(0, (a, s) => a + s.goalsFor);
    final goalsAgainst =
        season.standings.fold<int>(0, (a, s) => a + s.goalsAgainst);
    expect(goalsFor, goalsAgainst);
  });

  test('sample season is deterministic', () {
    final teams = PresetLeaguesData.iraqStarsLeagueClubs;
    final a = SampleSeason.forLeague(290, teams, now: DateTime(2026, 1, 1));
    final b = SampleSeason.forLeague(290, teams, now: DateTime(2026, 1, 1));
    expect(
      a.standings.map((s) => s.points).toList(),
      b.standings.map((s) => s.points).toList(),
    );
  });
}
