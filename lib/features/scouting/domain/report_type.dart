enum ReportType {
  playerScouting,
  teamAnalysis,
  opponentBreakdown,
  matchSummary,
}

extension ReportTypeLabels on ReportType {
  String get arabicLabel {
    return switch (this) {
      ReportType.playerScouting => 'استكشاف لاعب',
      ReportType.teamAnalysis => 'تحليل الفريق',
      ReportType.opponentBreakdown => 'تحليل الخصم',
      ReportType.matchSummary => 'ملخص المباراة',
    };
  }

  String get englishLabel {
    return switch (this) {
      ReportType.playerScouting => 'Player scouting',
      ReportType.teamAnalysis => 'Team analysis',
      ReportType.opponentBreakdown => 'Opponent breakdown',
      ReportType.matchSummary => 'Match summary',
    };
  }

  String get apiValue {
    return switch (this) {
      ReportType.playerScouting => 'player_scouting',
      ReportType.teamAnalysis => 'team_analysis',
      ReportType.opponentBreakdown => 'opponent_breakdown',
      ReportType.matchSummary => 'match_summary',
    };
  }
}
