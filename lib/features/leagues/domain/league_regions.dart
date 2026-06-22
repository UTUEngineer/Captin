abstract final class LeagueRegions {
  static const categories = [
    (labelAr: 'العراقية', code: 'IQ'),
    (labelAr: 'العربية', code: 'AR'),
    (labelAr: 'أوروبا', code: 'EU'),
    (labelAr: 'العالمية', code: 'WW'),
  ];

  static const Map<String, List<int>> leagueIdsByRegion = {
    'IQ': [290, 291],
    'AR': [307, 233, 98, 197],
    'EU': [39, 140, 135, 78, 61, 2, 3],
    'WW': [1, 4, 9],
  };
}
