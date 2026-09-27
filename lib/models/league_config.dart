class LeagueConfig {
  final int id;
  final String name;
  final String country;
  final String flagEmoji;
  final int currentSeason;

  const LeagueConfig({
    required this.id,
    required this.name,
    required this.country,
    required this.flagEmoji,
    this.currentSeason = 2025, // أو 2026 حسب تاريخ الموسم الحالي
  });
}

class SupportedLeagues {
  static const List<LeagueConfig> all = [
    // الدوريات المحلية والعربية
    LeagueConfig(
      id: 382, // Iraq Stars League / Premier League
      name: 'دوري نجوم العراق',
      country: 'Iraq',
      flagEmoji: '🇮🇶',
    ),
    LeagueConfig(
      id: 307, // Saudi Pro League (دوري روشن)
      name: 'دوري روشن السعودي',
      country: 'Saudi Arabia',
      flagEmoji: '🇸🇦',
    ),
    LeagueConfig(
      id: 17, // AFC Champions League
      name: 'دوري أبطال آسيا',
      country: 'Asia',
      flagEmoji: '🌏',
    ),

    // الدوريات الأوروبية الكبرى
    LeagueConfig(
      id: 39, // Premier League
      name: 'الدوري الإنجليزي الممتاز',
      country: 'England',
      flagEmoji: '🏴',
    ),
    LeagueConfig(
      id: 140, // La Liga
      name: 'الدوري الإسباني (La Liga)',
      country: 'Spain',
      flagEmoji: '🇪🇸',
    ),
    LeagueConfig(
      id: 135, // Serie A
      name: 'الدوري الإيطالي',
      country: 'Italy',
      flagEmoji: '🇮🇹',
    ),
    LeagueConfig(
      id: 78, // Bundesliga
      name: 'الدوري الألماني',
      country: 'Germany',
      flagEmoji: '🇩🇪',
    ),
    LeagueConfig(
      id: 2, // UEFA Champions League
      name: 'دوري أبطال أوروبا',
      country: 'Europe',
      flagEmoji: '🏆',
    ),
  ];
}
