class PlayerFullDossier {
  final String id;
  final String fullName;
  final String commonName;
  final int jerseyNumber;
  final String primaryPosition;
  final String clubName;
  final String nationality;
  final int age;
  final String height;
  final String weight;
  final String preferredFoot;
  final String marketValue;
  final String tacticalArchetype;
  final int overallRating;

  // Radar values
  final int pace;
  final int shooting;
  final int passing;
  final int dribbling;
  final int defending;
  final int physical;

  // Sub-metrics
  final int sprintSpeed;
  final int visionXT;
  final int closeDribbling;
  final int finishing;
  final int pressResistance;
  final int defensiveWorkRate;

  // Related Logs & AI Report
  final List<MatchLogModel> matchLogs;
  final AiScoutingModel? aiReport;

  PlayerFullDossier({
    required this.id,
    required this.fullName,
    required this.commonName,
    required this.jerseyNumber,
    required this.primaryPosition,
    required this.clubName,
    required this.nationality,
    required this.age,
    required this.height,
    required this.weight,
    required this.preferredFoot,
    required this.marketValue,
    required this.tacticalArchetype,
    required this.overallRating,
    required this.pace,
    required this.shooting,
    required this.passing,
    required this.dribbling,
    required this.defending,
    required this.physical,
    required this.sprintSpeed,
    required this.visionXT,
    required this.closeDribbling,
    required this.finishing,
    required this.pressResistance,
    required this.defensiveWorkRate,
    required this.matchLogs,
    this.aiReport,
  });

  factory PlayerFullDossier.fromSupabase(Map<String, dynamic> row) {
    final attrs = (row['player_attributes'] as Map<String, dynamic>?) ?? {};
    final logsRaw = (row['player_match_logs'] as List?) ?? [];
    final reportsRaw = (row['ai_scouting_reports'] as List?) ?? [];

    return PlayerFullDossier(
      id: row['id'] ?? '',
      fullName: row['full_name'] ?? '',
      commonName: row['common_name'] ?? '',
      jerseyNumber: row['jersey_number'] ?? 0,
      primaryPosition: row['primary_position'] ?? 'N/A',
      clubName: row['teams']?['name'] ?? 'Free Agent',
      nationality: row['nationality'] ?? '',
      age: row['age'] ?? 0,
      height: '${row['height_cm'] ?? 0} cm',
      weight: '${row['weight_kg'] ?? 0} kg',
      preferredFoot: row['preferred_foot'] ?? 'Right',
      marketValue: '€${((row['market_value_eur'] ?? 0) / 1000000).toStringAsFixed(2)}M',
      tacticalArchetype: row['tactical_archetype'] ?? 'Standard Player',
      overallRating: row['overall_rating'] ?? 75,
      // Attributes
      pace: attrs['pace'] ?? 70,
      shooting: attrs['shooting'] ?? 70,
      passing: attrs['passing'] ?? 70,
      dribbling: attrs['dribbling'] ?? 70,
      defending: attrs['defending'] ?? 70,
      physical: attrs['physical'] ?? 70,
      // Sub-metrics
      sprintSpeed: attrs['sprint_speed'] ?? 75,
      visionXT: attrs['vision_xT'] ?? 75,
      closeDribbling: attrs['close_dribbling'] ?? 75,
      finishing: attrs['finishing'] ?? 70,
      pressResistance: attrs['press_resistance'] ?? 75,
      defensiveWorkRate: attrs['defensive_work_rate'] ?? 60,
      // Collections
      matchLogs: logsRaw.map((m) => MatchLogModel.fromJson(m as Map<String, dynamic>)).toList(),
      aiReport: reportsRaw.isNotEmpty ? AiScoutingModel.fromJson(reportsRaw.first as Map<String, dynamic>) : null,
    );
  }

  /// On-device zero-latency tactical strength summary calculation
  String get derivedTacticalStrength => deriveTacticalStrength(this);

  /// Get on-device computed scouting report (fallback when no API/remote report exists)
  AiScoutingModel get computedScoutingReport {
    if (aiReport != null) return aiReport!;
    return AiScoutingModel(
      strengths: deriveTacticalStrengthsList(this),
      vulnerabilities: deriveVulnerabilities(this),
      pressingTriggers: derivePressingTriggers(this),
      summary: deriveTacticalStrength(this),
    );
  }
}

/// On-device tactical logic functions based on player attributes
String deriveTacticalStrength(PlayerFullDossier p) {
  if (p.dribbling >= 85 && p.pace >= 85) {
    return 'Elite 1v1 transitional winger with high half-space acceleration.';
  } else if (p.passing >= 85 && p.visionXT >= 85) {
    return 'Deep-lying playmaker; controls tempo and unlocks low blocks.';
  } else if (p.defending >= 80 && p.physical >= 80) {
    return 'High-intensity ball-winner dominant in ground duels.';
  } else if (p.shooting >= 80 && p.finishing >= 80) {
    return 'Clinical box finisher with exceptional shot conversion under pressure.';
  }
  return 'Balanced tactical profile supporting unit cohesion.';
}

List<String> deriveTacticalStrengthsList(PlayerFullDossier p) {
  final strengths = <String>[];
  if (p.pace >= 80) strengths.add('High line break acceleration (${p.sprintSpeed} Sprint)');
  if (p.passing >= 80) strengths.add('Key pass vision & progressive carries (xT: ${p.visionXT})');
  if (p.dribbling >= 80) strengths.add('Press resistance & tight-space control (${p.closeDribbling})');
  if (p.defending >= 80) strengths.add('High duel success rate & defensive work rate (${p.defensiveWorkRate}%)');
  if (p.shooting >= 80) strengths.add('Clinical inside-box finishing (${p.finishing})');
  if (p.physical >= 80) strengths.add('Physical aerial dominance & stamina retention');
  if (strengths.isEmpty) {
    strengths.addAll([
      'Solid tactical discipline & positional awareness',
      'Reliable link-up play in build-up phase',
    ]);
  }
  return strengths;
}

List<String> deriveVulnerabilities(PlayerFullDossier p) {
  final vulnerabilities = <String>[];
  if (p.pace < 70) vulnerabilities.add('Susceptible to wide counter-attacks on high defensive line');
  if (p.pressResistance < 70) vulnerabilities.add('Loss of possession under aggressive double-team pressing');
  if (p.physical < 70) vulnerabilities.add('Struggles against physical target strikers');
  if (p.defending < 60) vulnerabilities.add('Occasional delayed tracking back during defensive transitions');
  if (vulnerabilities.isEmpty) {
    vulnerabilities.add('Low vulnerability profile under standard match loads');
  }
  return vulnerabilities;
}

List<String> derivePressingTriggers(PlayerFullDossier p) {
  final triggers = <String>[];
  if (p.pressResistance < 75) triggers.add('Trigger high press when receiving back to goal');
  if (p.preferredFoot == 'Left') triggers.add('Force onto weak right foot when progressing wide');
  if (p.preferredFoot == 'Right') triggers.add('Force onto weak left foot along touchline');
  if (p.passing < 75) triggers.add('Close down central passing lanes early in build-up');
  if (triggers.isEmpty) {
    triggers.add('Apply positional containment rather than over-committing');
  }
  return triggers;
}

class MatchLogModel {
  final String opponent;
  final String competition;
  final String date;
  final double rating;
  final int minutesPlayed;
  final int goals;
  final int assists;
  final String passingAccuracy;
  final String duelsWon;
  final bool isWin;

  MatchLogModel({
    required this.opponent,
    required this.competition,
    required this.date,
    required this.rating,
    required this.minutesPlayed,
    required this.goals,
    required this.assists,
    required this.passingAccuracy,
    required this.duelsWon,
    required this.isWin,
  });

  factory MatchLogModel.fromJson(Map<String, dynamic> json) {
    return MatchLogModel(
      opponent: json['opponent_name'] ?? '',
      competition: json['competition'] ?? '',
      date: json['match_date'] ?? '',
      rating: double.tryParse('${json['rating']}') ?? 6.0,
      minutesPlayed: json['minutes_played'] ?? 90,
      goals: json['goals'] ?? 0,
      assists: json['assists'] ?? 0,
      passingAccuracy: '${json['passing_accuracy_pct'] ?? 80}%',
      duelsWon: json['duels_won'] ?? '0/0',
      isWin: json['is_win'] ?? false,
    );
  }
}

class AiScoutingModel {
  final List<String> strengths;
  final List<String> vulnerabilities;
  final List<String> pressingTriggers;
  final String summary;

  AiScoutingModel({
    required this.strengths,
    required this.vulnerabilities,
    required this.pressingTriggers,
    required this.summary,
  });

  factory AiScoutingModel.fromJson(Map<String, dynamic> json) {
    return AiScoutingModel(
      strengths: List<String>.from(json['key_tactical_strengths'] ?? []),
      vulnerabilities: List<String>.from(json['defensive_vulnerabilities'] ?? []),
      pressingTriggers: List<String>.from(json['pressing_triggers'] ?? []),
      summary: json['counter_measure_summary'] ?? '',
    );
  }
}

