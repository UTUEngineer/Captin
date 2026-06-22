class League {
  const League({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.country,
    required this.countryCode,
    required this.logo,
    required this.flag,
    required this.season,
    this.isFavorite = false,
  });

  final int id;
  final String name;
  final String nameAr;
  final String country;
  final String countryCode;
  final String logo;
  final String flag;
  final int season;
  final bool isFavorite;

  factory League.fromJson(Map<String, dynamic> json) {
    final league = json['league'] as Map<String, dynamic>;
    final country = json['country'] as Map<String, dynamic>;
    final seasons = json['seasons'] as List<dynamic>? ?? [];
    final currentSeason = seasons.isNotEmpty
        ? (seasons.last as Map<String, dynamic>)['year'] as int
        : DateTime.now().year;

    return League(
      id: league['id'] as int,
      name: league['name'] as String,
      nameAr: arabicLeagueNames[league['id'] as int] ?? league['name'] as String,
      country: country['name'] as String? ?? '',
      countryCode: country['code'] as String? ?? '',
      logo: league['logo'] as String? ?? '',
      flag: country['flag'] as String? ?? '',
      season: currentSeason,
    );
  }

  factory League.fromCache(Map<String, dynamic> json) {
    return League(
      id: json['id'] as int,
      name: json['name'] as String,
      nameAr: json['nameAr'] as String,
      country: json['country'] as String,
      countryCode: json['countryCode'] as String? ?? '',
      logo: json['logo'] as String? ?? '',
      flag: json['flag'] as String? ?? '',
      season: json['season'] as int,
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'nameAr': nameAr,
        'country': country,
        'countryCode': countryCode,
        'logo': logo,
        'flag': flag,
        'season': season,
        'isFavorite': isFavorite,
      };

  static const Map<int, String> arabicLeagueNames = {
    290: 'دوري نجوم العراق',
    291: 'كأس العراق',
    307: 'دوري روشن السعودي',
    233: 'الدوري المصري الممتاز',
    98: 'دوري أدنوك الإماراتي',
    197: 'الدوري المغربي',
    65: 'دوري أبطال أوروبا',
    39: 'الدوري الإنجليزي الممتاز',
    140: 'الدوري الإسباني',
    135: 'الدوري الإيطالي',
    78: 'الدوري الألماني',
    61: 'الدوري الفرنسي',
    2: 'دوري أبطال أوروبا',
    3: 'الدوري الأوروبي',
    848: 'دوري المؤتمر الأوروبي',
    1: 'كأس العالم',
    4: 'كأس العالم للأندية',
    9: 'كأس أمم أفريقيا',
  };
}
