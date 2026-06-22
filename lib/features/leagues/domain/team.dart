class Team {
  const Team({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.logo,
    required this.country,
    this.founded,
    this.venue,
  });

  final int id;
  final String name;
  final String nameAr;
  final String logo;
  final String country;
  final int? founded;
  final String? venue;

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['id'] as int,
      name: json['name'] as String,
      nameAr: arabicTeamNames[json['id'] as int] ?? json['name'] as String,
      logo: json['logo'] as String? ?? '',
      country: json['country'] as String? ?? '',
      founded: json['founded'] as int?,
      venue: (json['venue'] as Map<String, dynamic>?)?['name'] as String?,
    );
  }

  static const Map<int, String> arabicTeamNames = {
    5571: 'الزوراء',
    5572: 'القوة الجوية',
    5573: 'الشرطة',
    5574: 'الكرخ',
    5575: 'نفط الوسط',
    5576: 'أربيل',
    5577: 'دهوك',
    5578: 'زاخو',
    5579: 'الطلبة',
    5580: 'الكوت',
    5581: 'السماوة',
    5582: 'البصرة',
    33: 'مانشستر يونايتد',
    40: 'ليفربول',
    49: 'تشيلسي',
    50: 'مانشستر سيتي',
    42: 'أرسنال',
    47: 'توتنهام',
    529: 'برشلونة',
    541: 'ريال مدريد',
    530: 'أتلتيكو مدريد',
    489: 'أك ميلان',
    496: 'يوفنتوس',
    492: 'نابولي',
    157: 'بايرن ميونخ',
    165: 'بروسيا دورتموند',
    85: 'باريس سان جيرمان',
  };
}
