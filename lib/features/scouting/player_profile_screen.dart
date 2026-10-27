import 'package:captain/core/theme/app_colors.dart';
import 'dart:math' as math;
import 'package:flutter/material.dart';

// ==============================================================
// 1. DATA MODELS
// ==============================================================

class PlayerBiometrics {
  final String fullName;
  final String commonName;
  final int jerseyNumber;
  final String primaryPosition;
  final String clubName;
  final String nationality;
  final String age;
  final String height;
  final String weight;
  final String preferredFoot;
  final String marketValue;
  final String contractExpires;
  final String tacticalArchetype;

  const PlayerBiometrics({
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
    required this.contractExpires,
    required this.tacticalArchetype,
  });
}

class RadarAttribute {
  final String label;
  final double value; // 0 - 100

  const RadarAttribute({required this.label, required this.value});
}

class DetailedSubAttribute {
  final String title;
  final int value;
  final Color barColor;

  const DetailedSubAttribute({
    required this.title,
    required this.value,
    this.barColor = AppColors.brand,
  });
}

class MatchPerformanceLog {
  final String opponent;
  final String competition;
  final String date;
  final double rating;
  final int minutesPlayed;
  final int goals;
  final int assists;
  final String passingAccuracy;
  final String duelsWon;
  final bool isCleanSheetOrWin;

  const MatchPerformanceLog({
    required this.opponent,
    required this.competition,
    required this.date,
    required this.rating,
    required this.minutesPlayed,
    required this.goals,
    required this.assists,
    required this.passingAccuracy,
    required this.duelsWon,
    required this.isCleanSheetOrWin,
  });
}

// ==============================================================
// 2. MAIN PLAYER PROFILE SCREEN
// ==============================================================

class PlayerProfileScreen extends StatefulWidget {
  const PlayerProfileScreen({super.key});

  @override
  State<PlayerProfileScreen> createState() => _PlayerProfileScreenState();
}

class _PlayerProfileScreenState extends State<PlayerProfileScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  final PlayerBiometrics _player = const PlayerBiometrics(
    fullName: 'Ali Jasim El-Aibi',
    commonName: 'Ali Jasim',
    jerseyNumber: 10,
    primaryPosition: 'LW / CAM',
    clubName: 'Al-Zawraa SC / Iraq Stars League',
    nationality: 'Iraq 🇮🇶',
    age: '22',
    height: '178 cm',
    weight: '72 kg',
    preferredFoot: 'Right (4★ Weak Foot)',
    marketValue: '€2.50M',
    contractExpires: 'June 2028',
    tacticalArchetype: 'Inverted Playmaker / Half-Space Penetrator',
  );

  final List<RadarAttribute> _radarStats = const [
    RadarAttribute(label: 'PAC (88)', value: 88),
    RadarAttribute(label: 'SHO (82)', value: 82),
    RadarAttribute(label: 'PAS (86)', value: 86),
    RadarAttribute(label: 'DRI (91)', value: 91),
    RadarAttribute(label: 'DEF (44)', value: 44),
    RadarAttribute(label: 'PHY (76)', value: 76),
  ];

  final List<DetailedSubAttribute> _subAttributes = [
    DetailedSubAttribute(title: 'Sprint Speed & Acceleration', value: 89, barColor: AppColors.primary),
    DetailedSubAttribute(title: 'Vision & Key Passes (xT Impact)', value: 88, barColor: AppColors.primary),
    DetailedSubAttribute(title: 'Close Dribbling in Tight Spaces', value: 93, barColor: AppColors.primary),
    DetailedSubAttribute(title: 'Finishing & Shot Power', value: 81, barColor: AppColors.secondary),
    DetailedSubAttribute(title: 'Press Resistance & Turn Rate', value: 90, barColor: AppColors.primary),
    DetailedSubAttribute(title: 'Defensive Work Rate & Tracking', value: 52, barColor: AppColors.accentOrange),
  ];

  final List<MatchPerformanceLog> _matchHistory = const [
    MatchPerformanceLog(
      opponent: 'Al-Shorta SC',
      competition: 'Iraq Stars League',
      date: 'Sep 21, 2026',
      rating: 8.6,
      minutesPlayed: 90,
      goals: 1,
      assists: 1,
      passingAccuracy: '89%',
      duelsWon: '8/11',
      isCleanSheetOrWin: true,
    ),
    MatchPerformanceLog(
      opponent: 'Al-Quwa Al-Jawiya',
      competition: 'Iraq Stars League',
      date: 'Sep 14, 2026',
      rating: 7.9,
      minutesPlayed: 85,
      goals: 0,
      assists: 2,
      passingAccuracy: '84%',
      duelsWon: '6/9',
      isCleanSheetOrWin: true,
    ),
    MatchPerformanceLog(
      opponent: 'Al-Nassr',
      competition: 'AFC Champions League Elite',
      date: 'Aug 29, 2026',
      rating: 7.4,
      minutesPlayed: 78,
      goals: 1,
      assists: 0,
      passingAccuracy: '81%',
      duelsWon: '5/10',
      isCleanSheetOrWin: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F17),
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          'SCOUTING DOSSIER #${_player.jerseyNumber}',
          style: TextStyle(
            letterSpacing: 1.5,
            fontWeight: FontWeight.w900,
            fontSize: 15,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.share_outlined, color: AppColors.textSecondary),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.picture_as_pdf_outlined, color: AppColors.primary),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPlayerHeaderCard(),
            _buildBiometricGrid(),
            const SizedBox(height: 12),
            _buildTabSection(),
          ],
        ),
      ),
    );
  }

  // --- Header Hero Card ---
  Widget _buildPlayerHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.subtle)),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar with Jersey & Overall Badge
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 82,
                    height: 82,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 2.5),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1E283D), Color(0xFF0F1522)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Icon(Icons.person, size: 54, color: AppColors.textSecondary),
                  ),
                  Positioned(
                    bottom: -4,
                    right: -4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        '86',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 18),
              // Name, Position, Team
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            _player.commonName,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.secondary.withValues(alpha: 0.5)),
                          ),
                          child: Text(
                            _player.primaryPosition,
                            style: const TextStyle(
                              color: AppColors.secondary,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _player.clubName,
                      style: const TextStyle(color: Color(0xFF90A4AE), fontSize: 13),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _player.tacticalArchetype,
                        style: const TextStyle(
                          color: AppColors.gold,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Biometrics Quick-Stat Row ---
  Widget _buildBiometricGrid() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      color: const Color(0xFF0F1522),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _bioCell('AGE', _player.age),
          _bioDivider(),
          _bioCell('HEIGHT', _player.height),
          _bioDivider(),
          _bioCell('WEIGHT', _player.weight),
          _bioDivider(),
          _bioCell('FOOT', 'Right'),
          _bioDivider(),
          _bioCell('VALUE', _player.marketValue, highlight: true),
        ],
      ),
    );
  }

  Widget _bioCell(String title, String val, {bool highlight = false}) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          val,
          style: TextStyle(
            color: highlight ? AppColors.primary : AppColors.textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _bioDivider() {
    return Container(height: 22, width: 1, color: AppColors.border);
  }

  // --- Tab Bar Navigation & Content ---
  Widget _buildTabSection() {
    return Column(
      children: [
        Container(
          color: AppColors.surface,
          child: TabBar(
            controller: _tabController,
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            tabs: const [
              Tab(icon: Icon(Icons.radar, size: 18), text: 'Radar & Attributes'),
              Tab(icon: Icon(Icons.history_toggle_off, size: 18), text: 'Match Logs'),
              Tab(icon: Icon(Icons.psychology, size: 18), text: 'AI Scouting Report'),
            ],
          ),
        ),
        SizedBox(
          height: 520,
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildRadarAndAttributesTab(),
              _buildHistoricalMatchesTab(),
              _buildAiScoutingTab(),
            ],
          ),
        ),
      ],
    );
  }

  // --- TAB 1: RADAR & DETAILED ATTRIBUTES ---
  Widget _buildRadarAndAttributesTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.subtle),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'FIFA TACTICAL RADAR ATTRIBUTES',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      letterSpacing: 1.1,
                    ),
                  ),
                  Text(
                    'ELITE TIER (86 OVR)',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 230,
                width: double.infinity,
                child: CustomPaint(
                  painter: RadarChartPainter(
                    attributes: _radarStats,
                    fillColor: AppColors.primary.withValues(alpha: 0.28),
                    outlineColor: AppColors.primary,
                    webColor: AppColors.border,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Granular Sub-Metrics
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.subtle),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TACTICAL SUB-METRICS',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 16),
              ..._subAttributes.map((sub) => _buildAttributeProgressRow(sub)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAttributeProgressRow(DetailedSubAttribute sub) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(sub.title, style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              Text(
                '${sub.value}',
                style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: sub.value / 100.0,
              backgroundColor: Colors.white.withValues(alpha: 0.06),
              valueColor: AlwaysStoppedAnimation<Color>(sub.barColor),
              minHeight: 5,
            ),
          ),
        ],
      ),
    );
  }

  // --- TAB 2: HISTORICAL MATCH PERFORMANCE LOGS ---
  Widget _buildHistoricalMatchesTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _matchHistory.length,
      itemBuilder: (context, index) {
        final match = _matchHistory[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.subtle),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'vs ${match.opponent}',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${match.competition} • ${match.date}',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: match.rating >= 8.0
                          ? AppColors.primary
                          : match.rating >= 7.0
                              ? AppColors.secondary
                              : Colors.amber,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      match.rating.toStringAsFixed(1),
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Divider(color: AppColors.subtle, height: 1),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _matchStatCell('MINS', '${match.minutesPlayed}’'),
                  _matchStatCell('GOALS', '${match.goals}'),
                  _matchStatCell('ASSISTS', '${match.assists}'),
                  _matchStatCell('PASS ACC', match.passingAccuracy),
                  _matchStatCell('DUELS', match.duelsWon),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _matchStatCell(String title, String stat) {
    return Column(
      children: [
        Text(title, style: TextStyle(color: AppColors.textMuted, fontSize: 10)),
        const SizedBox(height: 4),
        Text(
          stat,
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 12),
        ),
      ],
    );
  }

  // --- TAB 3: CLAUDE 3.5 AI SCOUTING DOSSIER ---
  Widget _buildAiScoutingTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.accentOrange.withValues(alpha: 0.4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.accentOrange.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.psychology, color: AppColors.accentOrange, size: 20),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'CLAUDE 3.5 SONNET SCOUTING REPORT',
                    style: TextStyle(
                      color: AppColors.accentOrange,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      letterSpacing: 1.1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                'Key Tactical Strengths',
                style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 6),
              Text(
                '• Exceptional half-space acceleration and 1v1 dribbling success rate (71%).\n'
                '• Progressive ball carry of 14.8m per 90, creating passing angles for underlapping full-backs.\n'
                '• Direct ball striking on cut-backs into the top-right bin.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.4),
              ),
              const SizedBox(height: 14),
              const Text(
                'Defensive Vulnerabilities & Press Triggers',
                style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 6),
              Text(
                '• Slow recovery sprint when turnover occurs during high transition phases.\n'
                '• Vulnerable to double-teams against physical center-backs pushing him wide onto his weak foot.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.4),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ==============================================================
// 3. FIFA/EA FC STYLE RADAR CUSTOM PAINTER
// ==============================================================

class RadarChartPainter extends CustomPainter {
  final List<RadarAttribute> attributes;
  final Color fillColor;
  final Color outlineColor;
  final Color webColor;

  RadarChartPainter({
    required this.attributes,
    required this.fillColor,
    required this.outlineColor,
    required this.webColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (attributes.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2.7;
    final sides = attributes.length;
    final angleStep = (2 * math.pi) / sides;

    // Draw concentric polygon webs (levels: 25%, 50%, 75%, 100%)
    final webPaint = Paint()
      ..color = webColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (int step = 1; step <= 4; step++) {
      final r = (radius / 4) * step;
      final webPath = Path();
      for (int i = 0; i < sides; i++) {
        final angle = i * angleStep - math.pi / 2;
        final x = center.dx + r * math.cos(angle);
        final y = center.dy + r * math.sin(angle);
        if (i == 0) {
          webPath.moveTo(x, y);
        } else {
          webPath.lineTo(x, y);
        }
      }
      webPath.close();
      canvas.drawPath(webPath, webPaint);
    }

    // Draw Spokes from center to vertices
    for (int i = 0; i < sides; i++) {
      final angle = i * angleStep - math.pi / 2;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      canvas.drawLine(center, Offset(x, y), webPaint);
    }

    // Compute player stat polygon
    final polyPath = Path();
    final polyPoints = <Offset>[];

    for (int i = 0; i < sides; i++) {
      final angle = i * angleStep - math.pi / 2;
      final normalizedValue = (attributes[i].value / 100.0).clamp(0.0, 1.0);
      final r = radius * normalizedValue;
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);
      final pt = Offset(x, y);
      polyPoints.add(pt);

      if (i == 0) {
        polyPath.moveTo(x, y);
      } else {
        polyPath.lineTo(x, y);
      }
    }
    polyPath.close();

    // Fill player polygon
    canvas.drawPath(polyPath, Paint()..color = fillColor..style = PaintingStyle.fill);

    // Outline player polygon
    canvas.drawPath(
      polyPath,
      Paint()
        ..color = outlineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2,
    );

    // Draw vertex dots
    final dotPaint = Paint()..color = Colors.white..style = PaintingStyle.fill;
    for (final pt in polyPoints) {
      canvas.drawCircle(pt, 3.5, dotPaint);
      canvas.drawCircle(pt, 5.0, Paint()..color = outlineColor..style = PaintingStyle.stroke..strokeWidth = 1.2);
    }

    // Render outer labels
    for (int i = 0; i < sides; i++) {
      final angle = i * angleStep - math.pi / 2;
      final labelR = radius + 22.0;
      final lx = center.dx + labelR * math.cos(angle);
      final ly = center.dy + labelR * math.sin(angle);

      final textSpan = TextSpan(
        text: attributes[i].label,
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      );
      final tp = TextPainter(text: textSpan, textDirection: TextDirection.ltr)..layout();
      tp.paint(canvas, Offset(lx - tp.width / 2, ly - tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant RadarChartPainter oldDelegate) => true;
}
