import 'package:captain/features/leagues/domain/league.dart';
import 'package:captain/features/leagues/domain/league_regions.dart';
import 'package:captain/features/leagues/domain/standing.dart';
import 'package:captain/features/leagues/domain/team.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('League', () {
    test('fromJson maps Arabic league name', () {
      final league = League.fromJson({
        'league': {'id': 290, 'name': 'Iraqi League', 'logo': 'logo.png'},
        'country': {'name': 'Iraq', 'code': 'IQ', 'flag': 'flag.png'},
        'seasons': [
          {'year': 2024},
        ],
      });

      expect(league.id, 290);
      expect(league.nameAr, 'دوري نجوم العراق');
      expect(league.season, 2024);
    });

    test('toJson round-trips through fromCache', () {
      const league = League(
        id: 39,
        name: 'Premier League',
        nameAr: 'الدوري الإنجليزي الممتاز',
        country: 'England',
        countryCode: 'GB',
        logo: 'logo.png',
        flag: 'flag.png',
        season: 2024,
      );

      final restored = League.fromCache(league.toJson());
      expect(restored.nameAr, league.nameAr);
      expect(restored.season, league.season);
    });
  });

  group('Standing', () {
    test('fromJson uses Arabic team name when known', () {
      final standing = Standing.fromJson({
        'rank': 1,
        'points': 30,
        'team': {'id': 40, 'name': 'Liverpool', 'logo': 'logo.png'},
        'all': {
          'played': 10,
          'win': 9,
          'draw': 1,
          'lose': 0,
          'goals': {'for': 20, 'against': 5},
        },
      });

      expect(standing.teamNameAr, 'ليفربول');
      expect(standing.points, 30);
    });
  });

  group('LeagueRegions', () {
    test('includes Iraqi league ids', () {
      expect(LeagueRegions.leagueIdsByRegion['IQ'], contains(290));
    });
  });
}
