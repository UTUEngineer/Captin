enum CoachRole {
  headCoach('head_coach', 'Head coach', 'مدرب رئيسي'),
  assistantCoach('assistant_coach', 'Assistant coach', 'مساعد مدرب'),
  tacticalAnalyst('tactical_analyst', 'Tactical analyst', 'محلل تكتيكي'),
  youthCoach('youth_coach', 'Youth coach', 'مدرب ناشئين');

  const CoachRole(this.wireName, this.englishLabel, this.arabicLabel);
  final String wireName;
  final String englishLabel;
  final String arabicLabel;

  static CoachRole fromWire(String? value) {
    return CoachRole.values.firstWhere(
      (role) => role.wireName == value,
      orElse: () => CoachRole.headCoach,
    );
  }
}
