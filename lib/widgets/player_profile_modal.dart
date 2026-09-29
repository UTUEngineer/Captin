import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Match History Entry Model
class MatchHistoryEntry {
  final String matchId;
  final String fixture;
  final String date;
  final double rating; // 1.0 - 10.0
  final int minutes;
  final int goals;
  final int assists;
  final bool yellowCard;
  final bool redCard;

  const MatchHistoryEntry({
    required this.matchId,
    required this.fixture,
    required this.date,
    required this.rating,
    required this.minutes,
    required this.goals,
    required this.assists,
    required this.yellowCard,
    required this.redCard,
  });
}

/// Tactical Attributes Breakdown Model
class PlayerAttributes {
  final int pace;
  final int shooting;
  final int passing;
  final int dribbling;
  final int defending;
  final int physical;

  const PlayerAttributes({
    required this.pace,
    required this.shooting,
    required this.passing,
    required this.dribbling,
    required this.defending,
    required this.physical,
  });
}

/// Detailed Player Profile Model
class DetailedPlayerProfile {
  final String id;
  final String name;
  final int number;
  final String role;
  final String team;
  final int age;
  final String dominantFoot; // 'Right' | 'Left'
  final int matchesPlayed;
  final int totalGoals;
  final int totalAssists;
  final double avgRating;
  final int mvpAwards;
  final int yellowCards;
  final int redCards;
  final int totalFouls;
  final int cleanMatchesPercent;
  final PlayerAttributes attributes;
  final List<MatchHistoryEntry> history;

  const DetailedPlayerProfile({
    required this.id,
    required this.name,
    required this.number,
    required this.role,
    required this.team,
    required this.age,
    required this.dominantFoot,
    required this.matchesPlayed,
    required this.totalGoals,
    required this.totalAssists,
    required this.avgRating,
    required this.mvpAwards,
    required this.yellowCards,
    required this.redCards,
    required this.totalFouls,
    required this.cleanMatchesPercent,
    required this.attributes,
    required this.history,
  });
}

/// Default Demo Player Profile
const DetailedPlayerProfile kDefaultPlayerProfile = DetailedPlayerProfile(
  id: 'p8',
  name: 'A. Saadoon',
  number: 10,
  role: 'Attacking Midfielder (CAM)',
  team: 'Az-Zawra\'a SC',
  age: 24,
  dominantFoot: 'Right',
  matchesPlayed: 14,
  totalGoals: 9,
  totalAssists: 11,
  avgRating: 8.85,
  mvpAwards: 5,
  yellowCards: 2,
  redCards: 0,
  totalFouls: 11,
  cleanMatchesPercent: 86,
  attributes: PlayerAttributes(
    pace: 88,
    shooting: 85,
    passing: 92,
    dribbling: 90,
    defending: 64,
    physical: 78,
  ),
  history: [
    MatchHistoryEntry(matchId: 'm1', fixture: 'vs Al-Quwa Al-Jawiya', date: 'Sep 24', rating: 9.2, minutes: 90, goals: 2, assists: 1, yellowCard: false, redCard: false),
    MatchHistoryEntry(matchId: 'm2', fixture: 'vs Al-Shorta SC', date: 'Sep 17', rating: 8.9, minutes: 88, goals: 1, assists: 2, yellowCard: false, redCard: false),
    MatchHistoryEntry(matchId: 'm3', fixture: 'vs Al-Talaba SC', date: 'Sep 10', rating: 7.8, minutes: 90, goals: 0, assists: 1, yellowCard: true, redCard: false),
    MatchHistoryEntry(matchId: 'm4', fixture: 'vs Erbil SC', date: 'Sep 03', rating: 9.4, minutes: 90, goals: 2, assists: 2, yellowCard: false, redCard: false),
    MatchHistoryEntry(matchId: 'm5', fixture: 'vs Al-Najaf FC', date: 'Aug 27', rating: 7.2, minutes: 75, goals: 0, assists: 0, yellowCard: false, redCard: false),
    MatchHistoryEntry(matchId: 'm6', fixture: 'vs Zakho FC', date: 'Aug 20', rating: 8.6, minutes: 90, goals: 1, assists: 1, yellowCard: false, redCard: false),
    MatchHistoryEntry(matchId: 'm7', fixture: 'vs Duhok SC', date: 'Aug 13', rating: 8.8, minutes: 90, goals: 1, assists: 1, yellowCard: true, redCard: false),
  ],
);

/// Detailed Player Profile & Progression Modal Dialog Component
class PlayerProfileModal extends StatefulWidget {
  final DetailedPlayerProfile? player;
  final VoidCallback? onClose;

  const PlayerProfileModal({
    super.key,
    this.player,
    this.onClose,
  });

  @override
  State<PlayerProfileModal> createState() => _PlayerProfileModalState();
}

class _PlayerProfileModalState extends State<PlayerProfileModal> {
  MatchHistoryEntry? _hoveredMatch;

  @override
  Widget build(BuildContext context) {
    final activePlayer = widget.player ?? kDefaultPlayerProfile;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 880, maxHeight: 720),
        decoration: BoxDecoration(
          color: const Color(0xFF09182D),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: const Color(0xFF06B6D4).withValues(alpha: 0.4)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF06B6D4).withValues(alpha: 0.25),
              blurRadius: 40,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Column(
            children: [
              // 1. Top Header Card
              _buildHeader(activePlayer),

              // 2. Modal Scrollable Body
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Key Performance Metric Cards Strip
                      _buildPerformanceStrip(activePlayer),
                      const SizedBox(height: 20),

                      // Rating Progression & Tactical Attributes Row
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isWide = constraints.maxWidth >= 720;
                          return isWide
                              ? Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 7,
                                      child: _buildProgressionGraphCard(activePlayer),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      flex: 5,
                                      child: _buildAttributesCard(activePlayer),
                                    ),
                                  ],
                                )
                              : Column(
                                  children: [
                                    _buildProgressionGraphCard(activePlayer),
                                    const SizedBox(height: 16),
                                    _buildAttributesCard(activePlayer),
                                  ],
                                );
                        },
                      ),

                      const SizedBox(height: 20),

                      // Disciplinary & Recent Matches Strip Row
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isWide = constraints.maxWidth >= 720;
                          return isWide
                              ? Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 5,
                                      child: _buildDisciplinaryCard(activePlayer),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      flex: 7,
                                      child: _buildRecentMatchesCard(activePlayer),
                                    ),
                                  ],
                                )
                              : Column(
                                  children: [
                                    _buildDisciplinaryCard(activePlayer),
                                    const SizedBox(height: 16),
                                    _buildRecentMatchesCard(activePlayer),
                                  ],
                                );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // Header Component
  // -------------------------------------------------------------
  Widget _buildHeader(DetailedPlayerProfile p) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0C233F), Color(0xFF09182D), Color(0xFF0C233F)],
        ),
        border: Border(bottom: BorderSide(color: Colors.white12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              // Jersey Avatar Badge
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: const Color(0xFFFBBF24),
                  border: Border.all(color: const Color(0xFFFDE68A), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFBBF24).withValues(alpha: 0.4),
                      blurRadius: 16,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '#${p.number}',
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        p.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF06B6D4).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFF06B6D4).withValues(alpha: 0.4)),
                        ),
                        child: Text(
                          p.role,
                          style: const TextStyle(
                            color: Color(0xFF67E8F9),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (p.mvpAwards > 0) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFBBF24).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFFFBBF24).withValues(alpha: 0.4)),
                          ),
                          child: Text(
                            '★ ${p.mvpAwards} MVP Awards',
                            style: const TextStyle(
                              color: Color(0xFFFCD34D),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${p.team} • ${p.age} yrs • ${p.dominantFoot}-Footed',
                    style: const TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
          IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              if (widget.onClose != null) {
                widget.onClose!();
              } else {
                Navigator.of(context).pop();
              }
            },
            icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 20),
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFF0F172A),
              side: const BorderSide(color: Colors.white12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // 1. Key Performance Cards Strip
  // -------------------------------------------------------------
  Widget _buildPerformanceStrip(DetailedPlayerProfile p) {
    final double gPlusPerGame = p.matchesPlayed > 0
        ? (p.totalGoals + p.totalAssists) / p.matchesPlayed
        : 0.0;

    return Row(
      children: [
        Expanded(
          child: _buildMetricTile(
            title: 'MATCH RATING AVG',
            value: p.avgRating.toStringAsFixed(2),
            subtitle: 'Ranked #1 in Squad',
            valueColor: const Color(0xFF10B981),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildMetricTile(
            title: 'GOAL CONTRIBUTIONS',
            valueWidget: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '${p.totalGoals}G ',
                    style: const TextStyle(color: Color(0xFF06B6D4), fontSize: 18, fontWeight: FontWeight.w900, fontFamily: 'monospace'),
                  ),
                  const TextSpan(text: '+ ', style: TextStyle(color: Colors.white38, fontSize: 14)),
                  TextSpan(
                    text: '${p.totalAssists}A',
                    style: const TextStyle(color: Color(0xFF10B981), fontSize: 18, fontWeight: FontWeight.w900, fontFamily: 'monospace'),
                  ),
                ],
              ),
            ),
            subtitle: '${gPlusPerGame.toStringAsFixed(2)} per game',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildMetricTile(
            title: 'SQUAD MATCHES',
            value: '${p.matchesPlayed}',
            subtitle: '100% Starter Record',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildMetricTile(
            title: 'CLEAN DISCIPLINE',
            value: '${p.cleanMatchesPercent}%',
            subtitle: p.redCards == 0 ? 'Zero Red Cards' : '${p.redCards} Red Cards',
            valueColor: const Color(0xFFFCD34D),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricTile({
    required String title,
    String? value,
    Widget? valueWidget,
    required String subtitle,
    Color valueColor = Colors.white,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1F38).withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 4),
          valueWidget ??
              Text(
                value ?? '',
                style: TextStyle(
                  color: valueColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'monospace',
                ),
              ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.white54, fontSize: 10),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // 2. Rating Progression Graph Card (SVG / CustomPaint Sparkline)
  // -------------------------------------------------------------
  Widget _buildProgressionGraphCard(DetailedPlayerProfile p) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1F38).withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'RATING PROGRESSION',
                    style: TextStyle(
                      color: Color(0xFF06B6D4),
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Performance arc across last ${p.history.length} league matches',
                    style: const TextStyle(color: Colors.white38, fontSize: 11),
                  ),
                ],
              ),
              if (_hoveredMatch != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${_hoveredMatch!.rating.toStringAsFixed(1)} Rating',
                      style: const TextStyle(
                        color: Color(0xFF67E8F9),
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'monospace',
                      ),
                    ),
                    Text(
                      _hoveredMatch!.fixture,
                      style: const TextStyle(color: Colors.white38, fontSize: 9),
                    ),
                  ],
                ),
            ],
          ),

          const SizedBox(height: 16),

          // Custom Sparkline Graph View
          SizedBox(
            height: 130,
            width: double.infinity,
            child: CustomPaint(
              painter: SparklineGraphPainter(
                history: p.history,
                hoveredMatch: _hoveredMatch,
                onHoverPoint: (entry) {
                  setState(() => _hoveredMatch = entry);
                },
              ),
            ),
          ),

          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                p.history.isNotEmpty ? p.history.last.date : '',
                style: const TextStyle(color: Colors.white38, fontSize: 9, fontFamily: 'monospace'),
              ),
              const Text(
                'SEASON PROGRESSION',
                style: TextStyle(color: Colors.white24, fontSize: 9, fontWeight: FontWeight.bold),
              ),
              Text(
                p.history.isNotEmpty ? p.history.first.date : '',
                style: const TextStyle(color: Colors.white38, fontSize: 9, fontFamily: 'monospace'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // Tactical Attributes Card
  // -------------------------------------------------------------
  Widget _buildAttributesCard(DetailedPlayerProfile p) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1F38).withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TACTICAL PROFILE ATTRIBUTES',
            style: TextStyle(
              color: Color(0xFF06B6D4),
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          _buildAttributeBar('Pace & Acceleration', p.attributes.pace),
          const SizedBox(height: 8),
          _buildAttributeBar('Shooting & Finishing', p.attributes.shooting),
          const SizedBox(height: 8),
          _buildAttributeBar('Passing & Vision', p.attributes.passing),
          const SizedBox(height: 8),
          _buildAttributeBar('Ball Control & Dribbling', p.attributes.dribbling),
          const SizedBox(height: 8),
          _buildAttributeBar('Defensive Workrate', p.attributes.defending),
          const SizedBox(height: 8),
          _buildAttributeBar('Physicality & Stamina', p.attributes.physical),
        ],
      ),
    );
  }

  Widget _buildAttributeBar(String label, int value) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold),
            ),
            Text(
              '$value',
              style: const TextStyle(
                color: Color(0xFF67E8F9),
                fontSize: 11,
                fontWeight: FontWeight.w900,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          height: 6,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.white12),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: (value / 100).clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                gradient: const LinearGradient(
                  colors: [Color(0xFF06B6D4), Color(0xFF10B981)],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------------------
  // 3. Disciplinary Card
  // -------------------------------------------------------------
  Widget _buildDisciplinaryCard(DetailedPlayerProfile p) {
    final double foulsPerGame = p.matchesPlayed > 0
        ? p.totalFouls / p.matchesPlayed
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1F38).withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'DISCIPLINARY STATUS',
            style: TextStyle(
              color: Color(0xFFFCD34D),
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Fair play and referee bookings log',
            style: TextStyle(color: Colors.white38, fontSize: 11),
          ),
          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 16,
                        height: 22,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFBBF24),
                          borderRadius: BorderRadius.circular(3),
                          border: Border.all(color: const Color(0xFFFDE68A)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${p.yellowCards}',
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900, fontFamily: 'monospace'),
                          ),
                          const Text('YELLOWS', style: TextStyle(color: Colors.white38, fontSize: 8, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 16,
                        height: 22,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE11D48),
                          borderRadius: BorderRadius.circular(3),
                          border: Border.all(color: const Color(0xFFFDA4AF)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${p.redCards}',
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900, fontFamily: 'monospace'),
                          ),
                          const Text('REDS', style: TextStyle(color: Colors.white38, fontSize: 8, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Fouls Committed:', style: TextStyle(color: Colors.white60, fontSize: 11)),
                Text(
                  '${p.totalFouls} (${foulsPerGame.toStringAsFixed(1)} / game)',
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900, fontFamily: 'monospace'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // Recent Matches Card
  // -------------------------------------------------------------
  Widget _buildRecentMatchesCard(DetailedPlayerProfile p) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1F38).withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'RECENT MATCH LOG',
            style: TextStyle(
              color: Color(0xFF06B6D4),
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 150,
            child: ListView.separated(
              itemCount: p.history.length,
              separatorBuilder: (context, idx) => const SizedBox(height: 6),
              itemBuilder: (context, idx) {
                final entry = p.history[idx];
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            entry.date,
                            style: const TextStyle(color: Colors.white38, fontSize: 10, fontFamily: 'monospace'),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            entry.fixture,
                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '(${entry.minutes}\')',
                            style: const TextStyle(color: Colors.white38, fontSize: 9, fontFamily: 'monospace'),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          if (entry.goals > 0 || entry.assists > 0)
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Text(
                                '${entry.goals > 0 ? '⚽ ${entry.goals} ' : ''}${entry.assists > 0 ? '🎯 ${entry.assists}' : ''}',
                                style: const TextStyle(color: Color(0xFF10B981), fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                          if (entry.yellowCard)
                            Container(
                              width: 8,
                              height: 12,
                              margin: const EdgeInsets.only(right: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFBBF24),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          if (entry.redCard)
                            Container(
                              width: 8,
                              height: 12,
                              margin: const EdgeInsets.only(right: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE11D48),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: entry.rating >= 8.5
                                  ? const Color(0xFF10B981).withValues(alpha: 0.2)
                                  : entry.rating >= 7.5
                                      ? const Color(0xFF06B6D4).withValues(alpha: 0.2)
                                      : const Color(0xFF1E293B),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: entry.rating >= 8.5
                                    ? const Color(0xFF10B981)
                                    : entry.rating >= 7.5
                                        ? const Color(0xFF06B6D4)
                                        : Colors.white12,
                              ),
                            ),
                            child: Text(
                              entry.rating.toStringAsFixed(1),
                              style: TextStyle(
                                color: entry.rating >= 8.5
                                    ? const Color(0xFF6EE7B7)
                                    : entry.rating >= 7.5
                                        ? const Color(0xFF67E8F9)
                                        : Colors.white70,
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------
// Custom Painter for Rating Progression Sparkline Curve
// -------------------------------------------------------------
class SparklineGraphPainter extends CustomPainter {
  final List<MatchHistoryEntry> history;
  final MatchHistoryEntry? hoveredMatch;
  final ValueChanged<MatchHistoryEntry>? onHoverPoint;

  SparklineGraphPainter({
    required this.history,
    this.hoveredMatch,
    this.onHoverPoint,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (history.isEmpty) return;

    const double padding = 16.0;
    const double minRating = 5.0;
    const double maxRating = 10.0;

    final double width = size.width - padding * 2;
    final double height = size.height - padding * 2;
    final double stepX = width / (history.length - 1);

    // 1. Grid Lines
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(padding, padding), Offset(size.width - padding, padding), gridPaint);
    canvas.drawLine(Offset(padding, size.height / 2), Offset(size.width - padding, size.height / 2), gridPaint);
    canvas.drawLine(Offset(padding, size.height - padding), Offset(size.width - padding, size.height - padding), gridPaint);

    // 2. Compute Points
    final List<Offset> points = [];
    for (int i = 0; i < history.length; i++) {
      final double x = padding + i * stepX;
      final double normalizedY = (history[i].rating - minRating) / (maxRating - minRating);
      final double y = size.height - padding - normalizedY * height;
      points.add(Offset(x, y));
    }

    // 3. Path & Area
    final linePath = Path();
    final areaPath = Path();

    linePath.moveTo(points.first.dx, points.first.dy);
    areaPath.moveTo(points.first.dx, size.height - padding);
    areaPath.lineTo(points.first.dx, points.first.dy);

    for (int i = 1; i < points.length; i++) {
      final p1 = points[i - 1];
      final p2 = points[i];
      final controlPoint1 = Offset(p1.dx + (p2.dx - p1.dx) / 2, p1.dy);
      final controlPoint2 = Offset(p1.dx + (p2.dx - p1.dx) / 2, p2.dy);
      linePath.cubicTo(controlPoint1.dx, controlPoint1.dy, controlPoint2.dx, controlPoint2.dy, p2.dx, p2.dy);
      areaPath.cubicTo(controlPoint1.dx, controlPoint1.dy, controlPoint2.dx, controlPoint2.dy, p2.dx, p2.dy);
    }

    areaPath.lineTo(points.last.dx, size.height - padding);
    areaPath.close();

    // Area Gradient Fill
    final areaGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFF06B6D4).withValues(alpha: 0.35),
        const Color(0xFF06B6D4).withValues(alpha: 0.0),
      ],
    );

    final areaPaint = Paint()
      ..shader = areaGradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    canvas.drawPath(areaPath, areaPaint);

    // Line Stroke
    final linePaint = Paint()
      ..color = const Color(0xFF06B6D4)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(linePath, linePaint);

    // Data Points
    final dotFillPaint = Paint()
      ..color = const Color(0xFF08172B)
      ..style = PaintingStyle.fill;

    final dotBorderPaint = Paint()
      ..color = const Color(0xFF06B6D4)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final hoveredBorderPaint = Paint()
      ..color = const Color(0xFF38BDF8)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < points.length; i++) {
      final pt = points[i];
      final isHovered = hoveredMatch?.matchId == history[i].matchId;

      canvas.drawCircle(pt, isHovered ? 6 : 4, dotFillPaint);
      canvas.drawCircle(pt, isHovered ? 6 : 4, isHovered ? hoveredBorderPaint : dotBorderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant SparklineGraphPainter oldDelegate) {
    return oldDelegate.history != history || oldDelegate.hoveredMatch != hoveredMatch;
  }
}
