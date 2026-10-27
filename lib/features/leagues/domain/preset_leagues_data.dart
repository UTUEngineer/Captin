import 'package:captain/features/leagues/domain/league.dart';
import 'package:captain/features/leagues/domain/match_fixture.dart';
import 'package:captain/features/leagues/domain/standing.dart';
import 'package:captain/features/leagues/domain/team.dart';

abstract final class PresetLeaguesData {
  static const currentSeason = 2025;

  // ---------------------------------------------------------------------------
  // Leagues by Region
  // ---------------------------------------------------------------------------
  static final Map<String, List<League>> leaguesByRegion = {
    'IQ': [
      const League(
        id: 290,
        name: 'Iraq Stars League',
        nameAr: 'دوري نجوم العراق',
        country: 'Iraq',
        countryCode: 'IQ',
        logo: 'https://media.api-sports.io/football/leagues/290.png',
        flag: 'https://media.api-sports.io/flags/iq.svg',
        season: currentSeason,
      ),
      const League(
        id: 291,
        name: 'Iraq FA Cup',
        nameAr: 'كأس العراق',
        country: 'Iraq',
        countryCode: 'IQ',
        logo: 'https://media.api-sports.io/football/leagues/291.png',
        flag: 'https://media.api-sports.io/flags/iq.svg',
        season: currentSeason,
      ),
    ],
    'AR': [
      const League(
        id: 307,
        name: 'Saudi Pro League (Roshn)',
        nameAr: 'دوري روشن السعودي للمحترفين',
        country: 'Saudi-Arabia',
        countryCode: 'SA',
        logo: 'https://media.api-sports.io/football/leagues/307.png',
        flag: 'https://media.api-sports.io/flags/sa.svg',
        season: currentSeason,
      ),
      const League(
        id: 233,
        name: 'Egyptian Premier League',
        nameAr: 'الدوري المصري الممتاز',
        country: 'Egypt',
        countryCode: 'EG',
        logo: 'https://media.api-sports.io/football/leagues/233.png',
        flag: 'https://media.api-sports.io/flags/eg.svg',
        season: currentSeason,
      ),
      const League(
        id: 98,
        name: 'ADNOC Pro League (UAE)',
        nameAr: 'دوري أدنوك الإماراتي للمحترفين',
        country: 'UAE',
        countryCode: 'AE',
        logo: 'https://media.api-sports.io/football/leagues/98.png',
        flag: 'https://media.api-sports.io/flags/ae.svg',
        season: currentSeason,
      ),
      const League(
        id: 197,
        name: 'Botola Pro Inwi (Morocco)',
        nameAr: 'الدوري المغربي الاحترافي (البطولة)',
        country: 'Morocco',
        countryCode: 'MA',
        logo: 'https://media.api-sports.io/football/leagues/197.png',
        flag: 'https://media.api-sports.io/flags/ma.svg',
        season: currentSeason,
      ),
    ],
    'EU': [
      const League(
        id: 39,
        name: 'Premier League',
        nameAr: 'الدوري الإنجليزي الممتاز',
        country: 'England',
        countryCode: 'GB',
        logo: 'https://media.api-sports.io/football/leagues/39.png',
        flag: 'https://media.api-sports.io/flags/gb.svg',
        season: currentSeason,
      ),
      const League(
        id: 140,
        name: 'La Liga (EA Sports)',
        nameAr: 'الدوري الإسباني (لا ليغا)',
        country: 'Spain',
        countryCode: 'ES',
        logo: 'https://media.api-sports.io/football/leagues/140.png',
        flag: 'https://media.api-sports.io/flags/es.svg',
        season: currentSeason,
      ),
      const League(
        id: 2,
        name: 'UEFA Champions League',
        nameAr: 'دوري أبطال أوروبا',
        country: 'World',
        countryCode: 'EU',
        logo: 'https://media.api-sports.io/football/leagues/2.png',
        flag: '',
        season: currentSeason,
      ),
      const League(
        id: 135,
        name: 'Serie A',
        nameAr: 'الدوري الإيطالي الممتاز',
        country: 'Italy',
        countryCode: 'IT',
        logo: 'https://media.api-sports.io/football/leagues/135.png',
        flag: 'https://media.api-sports.io/flags/it.svg',
        season: currentSeason,
      ),
      const League(
        id: 78,
        name: 'Bundesliga',
        nameAr: 'الدوري الألماني (بوندسليغا)',
        country: 'Germany',
        countryCode: 'DE',
        logo: 'https://media.api-sports.io/football/leagues/78.png',
        flag: 'https://media.api-sports.io/flags/de.svg',
        season: currentSeason,
      ),
      const League(
        id: 61,
        name: 'Ligue 1',
        nameAr: 'الدوري الفرنسي (ليغ 1)',
        country: 'France',
        countryCode: 'FR',
        logo: 'https://media.api-sports.io/football/leagues/61.png',
        flag: 'https://media.api-sports.io/flags/fr.svg',
        season: currentSeason,
      ),
    ],
    'WW': [
      const League(
        id: 1,
        name: 'FIFA World Cup',
        nameAr: 'كأس العالم FIFA',
        country: 'World',
        countryCode: 'WW',
        logo: 'https://media.api-sports.io/football/leagues/1.png',
        flag: '',
        season: 2026,
      ),
      const League(
        id: 4,
        name: 'FIFA Club World Cup',
        nameAr: 'كأس العالم للأندية',
        country: 'World',
        countryCode: 'WW',
        logo: 'https://media.api-sports.io/football/leagues/4.png',
        flag: '',
        season: currentSeason,
      ),
      const League(
        id: 9,
        name: 'Africa Cup of Nations',
        nameAr: 'كأس أمم أفريقيا (كان)',
        country: 'World',
        countryCode: 'WW',
        logo: 'https://media.api-sports.io/football/leagues/9.png',
        flag: '',
        season: currentSeason,
      ),
    ],
  };

  static List<League> getLeaguesByRegion(String regionCode) {
    return leaguesByRegion[regionCode] ?? [];
  }

  static League? getLeagueById(int id) {
    for (final list in leaguesByRegion.values) {
      for (final l in list) {
        if (l.id == id) return l;
      }
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Preset Standings
  // ---------------------------------------------------------------------------
  static List<Standing> getStandings(int leagueId) {
    switch (leagueId) {
      case 290: // Iraq Stars League
        return [
          const Standing(
            rank: 1,
            teamId: 5573,
            teamName: 'Al-Shorta SC',
            teamNameAr: 'الشرطة',
            teamLogo: 'https://media.api-sports.io/football/teams/5573.png',
            played: 28,
            win: 21,
            draw: 5,
            lose: 2,
            points: 68,
            goalsFor: 58,
            goalsAgainst: 19,
          ),
          const Standing(
            rank: 2,
            teamId: 5572,
            teamName: 'Al-Quwa Al-Jawiya',
            teamNameAr: 'القوة الجوية',
            teamLogo: 'https://media.api-sports.io/football/teams/5572.png',
            played: 28,
            win: 19,
            draw: 6,
            lose: 3,
            points: 63,
            goalsFor: 52,
            goalsAgainst: 21,
          ),
          const Standing(
            rank: 3,
            teamId: 5571,
            teamName: 'Al-Zawraa SC',
            teamNameAr: 'الزوراء',
            teamLogo: 'https://media.api-sports.io/football/teams/5571.png',
            played: 28,
            win: 17,
            draw: 7,
            lose: 4,
            points: 58,
            goalsFor: 44,
            goalsAgainst: 22,
          ),
          const Standing(
            rank: 4,
            teamId: 5578,
            teamName: 'Zakho FC',
            teamNameAr: 'زاخو',
            teamLogo: 'https://media.api-sports.io/football/teams/5578.png',
            played: 28,
            win: 14,
            draw: 9,
            lose: 5,
            points: 51,
            goalsFor: 35,
            goalsAgainst: 20,
          ),
          const Standing(
            rank: 5,
            teamId: 5579,
            teamName: 'Al-Talaba SC',
            teamNameAr: 'الطلبة',
            teamLogo: 'https://media.api-sports.io/football/teams/5579.png',
            played: 28,
            win: 13,
            draw: 7,
            lose: 8,
            points: 46,
            goalsFor: 39,
            goalsAgainst: 30,
          ),
        ];

      case 307: // Saudi Pro League
        return [
          const Standing(
            rank: 1,
            teamId: 1021,
            teamName: 'Al-Hilal',
            teamNameAr: 'الهلال',
            teamLogo: 'https://media.api-sports.io/football/teams/1021.png',
            played: 30,
            win: 26,
            draw: 3,
            lose: 1,
            points: 81,
            goalsFor: 84,
            goalsAgainst: 23,
          ),
          const Standing(
            rank: 2,
            teamId: 1022,
            teamName: 'Al-Nassr',
            teamNameAr: 'النصر',
            teamLogo: 'https://media.api-sports.io/football/teams/1022.png',
            played: 30,
            win: 23,
            draw: 4,
            lose: 3,
            points: 73,
            goalsFor: 79,
            goalsAgainst: 31,
          ),
          const Standing(
            rank: 3,
            teamId: 1024,
            teamName: 'Al-Ittihad',
            teamNameAr: 'الاتحاد',
            teamLogo: 'https://media.api-sports.io/football/teams/1024.png',
            played: 30,
            win: 21,
            draw: 5,
            lose: 4,
            points: 68,
            goalsFor: 65,
            goalsAgainst: 28,
          ),
          const Standing(
            rank: 4,
            teamId: 1023,
            teamName: 'Al-Ahli',
            teamNameAr: 'الأهلي',
            teamLogo: 'https://media.api-sports.io/football/teams/1023.png',
            played: 30,
            win: 18,
            draw: 6,
            lose: 6,
            points: 60,
            goalsFor: 57,
            goalsAgainst: 34,
          ),
        ];

      case 39: // Premier League
      default:
        return [
          const Standing(
            rank: 1,
            teamId: 42,
            teamName: 'Arsenal',
            teamNameAr: 'أرسنال',
            teamLogo: 'https://media.api-sports.io/football/teams/42.png',
            played: 30,
            win: 23,
            draw: 4,
            lose: 3,
            points: 73,
            goalsFor: 72,
            goalsAgainst: 24,
          ),
          const Standing(
            rank: 2,
            teamId: 50,
            teamName: 'Manchester City',
            teamNameAr: 'مانشستر سيتي',
            teamLogo: 'https://media.api-sports.io/football/teams/50.png',
            played: 30,
            win: 22,
            draw: 5,
            lose: 3,
            points: 71,
            goalsFor: 75,
            goalsAgainst: 28,
          ),
          const Standing(
            rank: 3,
            teamId: 40,
            teamName: 'Liverpool',
            teamNameAr: 'ليفربول',
            teamLogo: 'https://media.api-sports.io/football/teams/40.png',
            played: 30,
            win: 21,
            draw: 6,
            lose: 3,
            points: 69,
            goalsFor: 70,
            goalsAgainst: 27,
          ),
          const Standing(
            rank: 4,
            teamId: 49,
            teamName: 'Chelsea',
            teamNameAr: 'تشيلسي',
            teamLogo: 'https://media.api-sports.io/football/teams/49.png',
            played: 30,
            win: 17,
            draw: 6,
            lose: 7,
            points: 57,
            goalsFor: 58,
            goalsAgainst: 38,
          ),
          const Standing(
            rank: 5,
            teamId: 33,
            teamName: 'Manchester United',
            teamNameAr: 'مانشستر يونايتد',
            teamLogo: 'https://media.api-sports.io/football/teams/33.png',
            played: 30,
            win: 16,
            draw: 5,
            lose: 9,
            points: 53,
            goalsFor: 51,
            goalsAgainst: 42,
          ),
        ];
    }
  }

  // ---------------------------------------------------------------------------
  // Preset Fixtures
  // ---------------------------------------------------------------------------
  static List<MatchFixture> getFixtures(int leagueId) {
    final now = DateTime.now();
    return [
      MatchFixture(
        id: 101,
        date: now.subtract(const Duration(days: 1)),
        statusShort: 'FT',
        homeTeam: const Team(
          id: 42,
          name: 'Arsenal',
          nameAr: 'أرسنال',
          logo: 'https://media.api-sports.io/football/teams/42.png',
          country: 'England',
        ),
        awayTeam: const Team(
          id: 49,
          name: 'Chelsea',
          nameAr: 'تشيلسي',
          logo: 'https://media.api-sports.io/football/teams/49.png',
          country: 'England',
        ),
        homeGoals: 2,
        awayGoals: 1,
      ),
      MatchFixture(
        id: 102,
        date: now.add(const Duration(hours: 3)),
        statusShort: 'LIVE',
        homeTeam: const Team(
          id: 50,
          name: 'Manchester City',
          nameAr: 'مانشستر سيتي',
          logo: 'https://media.api-sports.io/football/teams/50.png',
          country: 'England',
        ),
        awayTeam: const Team(
          id: 40,
          name: 'Liverpool',
          nameAr: 'ليفربول',
          logo: 'https://media.api-sports.io/football/teams/40.png',
          country: 'England',
        ),
        homeGoals: 1,
        awayGoals: 1,
      ),
      MatchFixture(
        id: 103,
        date: now.add(const Duration(days: 2)),
        statusShort: 'NS',
        homeTeam: const Team(
          id: 5573,
          name: 'Al-Shorta SC',
          nameAr: 'الشرطة',
          logo: 'https://media.api-sports.io/football/teams/5573.png',
          country: 'Iraq',
        ),
        awayTeam: const Team(
          id: 5571,
          name: 'Al-Zawraa SC',
          nameAr: 'الزوراء',
          logo: 'https://media.api-sports.io/football/teams/5571.png',
          country: 'Iraq',
        ),
      ),
    ];
  }

  // ---------------------------------------------------------------------------
  // Preset Teams
  // ---------------------------------------------------------------------------
  static List<Team> getTeams(int leagueId) {
    if (leagueId == 290 || leagueId == 291) {
      return iraqStarsLeagueClubs;
    }
    return [
      const Team(id: 42, name: 'Arsenal', nameAr: 'أرسنال', logo: 'https://media.api-sports.io/football/teams/42.png', country: 'England'),
      const Team(id: 50, name: 'Manchester City', nameAr: 'مانشستر سيتي', logo: 'https://media.api-sports.io/football/teams/50.png', country: 'England'),
      const Team(id: 40, name: 'Liverpool', nameAr: 'ليفربول', logo: 'https://media.api-sports.io/football/teams/40.png', country: 'England'),
      const Team(id: 49, name: 'Chelsea', nameAr: 'تشيلسي', logo: 'https://media.api-sports.io/football/teams/49.png', country: 'England'),
      const Team(id: 33, name: 'Manchester United', nameAr: 'مانشستر يونايتد', logo: 'https://media.api-sports.io/football/teams/33.png', country: 'England'),
      const Team(id: 47, name: 'Tottenham Hotspur', nameAr: 'توتنهام', logo: 'https://media.api-sports.io/football/teams/47.png', country: 'England'),
    ];
  }

  static Team _iq(int id, String name, String nameAr, String venue) => Team(
        id: id,
        name: name,
        nameAr: nameAr,
        logo: id < 900000
            ? 'https://media.api-sports.io/football/teams/$id.png'
            : '',
        country: 'Iraq',
        venue: venue,
      );

  /// Iraq Stars League clubs (order ≈ recent strength, used by the sample
  /// season generator).
  static final List<Team> iraqStarsLeagueClubs = [
    _iq(5573, 'Al-Shorta', 'الشرطة', 'Al-Shaab Stadium'),
    _iq(5572, 'Al-Quwa Al-Jawiya', 'القوة الجوية', 'Al-Madina Stadium'),
    _iq(5571, 'Al-Zawraa', 'الزوراء', 'Al-Zawraa Stadium'),
    _iq(5579, 'Al-Talaba', 'الطلبة', 'Al-Talaba Stadium'),
    _iq(5576, 'Erbil', 'أربيل', 'Franso Hariri Stadium'),
    _iq(5578, 'Zakho', 'زاخو', 'Zakho International Stadium'),
    _iq(5577, 'Duhok', 'دهوك', 'Duhok Stadium'),
    _iq(5575, 'Naft Al-Wasat', 'نفط الوسط', 'Al-Najaf International Stadium'),
    _iq(5574, 'Al-Karkh', 'الكرخ', 'Al-Karkh Stadium'),
    _iq(900001, 'Al-Kahrabaa', 'الكهرباء', 'Al-Kahrabaa Stadium'),
    _iq(900002, 'Naft Maysan', 'نفط ميسان', 'Maysan Olympic Stadium'),
    _iq(900003, 'Al-Najaf', 'النجف', 'Al-Najaf International Stadium'),
    _iq(900004, "Al-Mina'a", 'الميناء', 'Al-Fayhaa Stadium'),
    _iq(900005, 'Naft Al-Basra', 'نفط البصرة', 'Basra International Stadium'),
    _iq(900006, 'Al-Naft', 'النفط', 'Al-Naft Stadium'),
    _iq(900007, 'Al-Diwaniya', 'الديوانية', 'Al-Diwaniya Olympic Stadium'),
    _iq(900008, 'Al-Qasim', 'القاسم', 'Al-Qasim Stadium'),
    _iq(900009, 'Karbala', 'كربلاء', 'Karbala International Stadium'),
    _iq(900010, 'Al-Hudood', 'الحدود', 'Al-Hudood Stadium'),
    _iq(900011, 'Newroz', 'نوروز', 'Sulaymaniyah Stadium'),
  ];
}
