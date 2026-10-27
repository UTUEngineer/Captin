import 'package:captain/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../services/squad_leaderboard_service.dart';
import '../widgets/player_profile_modal.dart';

enum MetricCategory { goals, assists, rating }

/// Squad Leaderboard & Season Rankings Screen Component
class SquadLeaderboardScreen extends ConsumerStatefulWidget {
  final VoidCallback? onBack;

  const SquadLeaderboardScreen({
    super.key,
    this.onBack,
  });

  @override
  ConsumerState<SquadLeaderboardScreen> createState() => _SquadLeaderboardScreenState();
}

class _SquadLeaderboardScreenState extends ConsumerState<SquadLeaderboardScreen> {
  MetricCategory _activeTab = MetricCategory.goals;

  List<LeaderboardPlayer> _sortSquad(List<LeaderboardPlayer> squad) {
    final list = List<LeaderboardPlayer>.from(squad);
    list.sort((a, b) {
      if (_activeTab == MetricCategory.goals) {
        final cmp = b.goals.compareTo(a.goals);
        return cmp != 0 ? cmp : b.avgRating.compareTo(a.avgRating);
      } else if (_activeTab == MetricCategory.assists) {
        final cmp = b.assists.compareTo(a.assists);
        return cmp != 0 ? cmp : b.avgRating.compareTo(a.avgRating);
      } else {
        final cmp = b.avgRating.compareTo(a.avgRating);
        return cmp != 0 ? cmp : b.goals.compareTo(a.goals);
      }
    });
    return list;
  }

  String _getMetricValue(LeaderboardPlayer player) {
    if (_activeTab == MetricCategory.goals) return '${player.goals} Goals';
    if (_activeTab == MetricCategory.assists) return '${player.assists} Assists';
    return '${player.avgRating.toStringAsFixed(2)} Rating';
  }

  void _showPlayerModal(LeaderboardPlayer player) {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (context) => PlayerProfileModal(
        player: DetailedPlayerProfile(
          id: player.id,
          name: player.name,
          number: player.number,
          role: player.role,
          team: 'Az-Zawra\'a SC',
          age: 24,
          dominantFoot: 'Right',
          matchesPlayed: player.appearances,
          totalGoals: player.goals,
          totalAssists: player.assists,
          avgRating: player.avgRating,
          mvpAwards: player.mvpCount,
          yellowCards: 2,
          redCards: 0,
          totalFouls: 11,
          cleanMatchesPercent: 86,
          attributes: const PlayerAttributes(
            pace: 88,
            shooting: 85,
            passing: 92,
            dribbling: 90,
            defending: 64,
            physical: 78,
          ),
          history: kDefaultPlayerProfile.history,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final asyncSquad = ref.watch(squadLeaderboardProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: asyncSquad.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.info),
          ),
          error: (err, stack) => _buildMainLayout(kDefaultSquadData),
          data: (squad) => _buildMainLayout(squad),
        ),
      ),
    );
  }

  Widget _buildMainLayout(List<LeaderboardPlayer> squad) {
    final sortedSquad = _sortSquad(squad);
    final topThree = sortedSquad.take(3).toList();
    final totalApps = squad.fold<int>(0, (sum, p) => sum + p.appearances);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 900;

        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Bar
              _buildHeader(context),
              const SizedBox(height: 20),

              // Main Leaderboard Content (Podium + Standings Table)
              Expanded(
                child: isWide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Left Column: Podium Standings (Flex 5)
                          Expanded(
                            flex: 5,
                            child: _buildPodiumCard(topThree, totalApps),
                          ),
                          const SizedBox(width: 20),
                          // Right Column: Complete Squad Standings Table (Flex 7)
                          Expanded(
                            flex: 7,
                            child: _buildStandingsTableCard(sortedSquad),
                          ),
                        ],
                      )
                    : SingleChildScrollView(
                        child: Column(
                          children: [
                            SizedBox(
                              height: 480,
                              child: _buildPodiumCard(topThree, totalApps),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              height: 520,
                              child: _buildStandingsTableCard(sortedSquad),
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  // -------------------------------------------------------------
  // Header Component
  // -------------------------------------------------------------
  Widget _buildHeader(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 650;

        return Flex(
          direction: isCompact ? Axis.vertical : Axis.horizontal,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: isCompact ? CrossAxisAlignment.start : CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    if (widget.onBack != null) {
                      widget.onBack!();
                    } else if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/hub');
                    }
                  },
                  icon: Icon(Icons.arrow_back_rounded, color: AppColors.textSecondary, size: 20),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.background,
                    side: BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.info,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'SEASON 2026/27',
                          style: TextStyle(
                            color: AppColors.info,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'SQUAD PERFORMANCE LEADERBOARD',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (isCompact) const SizedBox(height: 14),

            // Tab Controls
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFF0A192F).withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTabButton(
                    category: MetricCategory.goals,
                    label: '⚽ Golden Boot',
                  ),
                  const SizedBox(width: 4),
                  _buildTabButton(
                    category: MetricCategory.assists,
                    label: '🎯 Playmaker',
                  ),
                  const SizedBox(width: 4),
                  _buildTabButton(
                    category: MetricCategory.rating,
                    label: '⭐ Captain\'s MVP',
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTabButton({
    required MetricCategory category,
    required String label,
  }) {
    final isSelected = _activeTab == category;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _activeTab = category);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.info.withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.info : Colors.transparent,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.info.withValues(alpha: 0.3),
                    blurRadius: 12,
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFF67E8F9) : AppColors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // Left Column: Top 3 Visual Podium
  // -------------------------------------------------------------
  Widget _buildPodiumCard(List<LeaderboardPlayer> topThree, int totalApps) {
    final first = topThree.isNotEmpty ? topThree[0] : null;
    final second = topThree.length > 1 ? topThree[1] : null;
    final third = topThree.length > 2 ? topThree[2] : null;

    final String titleText = _activeTab == MetricCategory.goals
        ? 'Top Goalscorers'
        : _activeTab == MetricCategory.assists
            ? 'Assist Leaders'
            : 'Highest Rated Players';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Header Sub-Title
          Column(
            children: [
              const Text(
                'PODIUM STANDINGS',
                style: TextStyle(
                  color: AppColors.info,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                titleText,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),

          // Podium Steps Visual Grid
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 2nd Place (Left)
                if (second != null)
                  Expanded(
                    child: _buildPodiumColumn(
                      player: second,
                      rank: 2,
                      metricText: _getMetricValue(second),
                      pillarHeight: 110,
                      borderColor: AppColors.textSecondary,
                      pillarGradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [AppColors.background, AppColors.surfaceElevated],
                      ),
                      rankTextColor: AppColors.textSecondary,
                    ),
                  ),

                const SizedBox(width: 10),

                // 1st Place (Center - Gold)
                if (first != null)
                  Expanded(
                    child: _buildPodiumColumn(
                      player: first,
                      rank: 1,
                      metricText: _getMetricValue(first),
                      pillarHeight: 145,
                      isGold: true,
                      borderColor: AppColors.gold,
                      pillarGradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          AppColors.gold.withValues(alpha: 0.2),
                          AppColors.gold.withValues(alpha: 0.4),
                        ],
                      ),
                      rankTextColor: AppColors.gold,
                    ),
                  ),

                const SizedBox(width: 10),

                // 3rd Place (Right - Bronze)
                if (third != null)
                  Expanded(
                    child: _buildPodiumColumn(
                      player: third,
                      rank: 3,
                      metricText: _getMetricValue(third),
                      pillarHeight: 85,
                      borderColor: const Color(0xFFB45309),
                      pillarGradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [AppColors.background, Color(0xFF451A03)],
                      ),
                      rankTextColor: const Color(0xFFD97706),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 12),
          // Footer Appearance Note
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              'Ratings calibrated across $totalApps squad appearances.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumColumn({
    required LeaderboardPlayer player,
    required int rank,
    required String metricText,
    required double pillarHeight,
    required Color borderColor,
    required Gradient pillarGradient,
    required Color rankTextColor,
    bool isGold = false,
  }) {
    return GestureDetector(
      onTap: () => _showPlayerModal(player),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
        if (isGold)
          const Padding(
            padding: EdgeInsets.only(bottom: 2),
            child: Text('👑', style: TextStyle(fontSize: 20)),
          ),

        // Player Jersey Avatar
        Container(
          width: isGold ? 48 : 40,
          height: isGold ? 48 : 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isGold ? AppColors.gold : AppColors.surfaceElevated,
            border: Border.all(color: borderColor, width: 2),
            boxShadow: isGold
                ? [
                    BoxShadow(
                      color: AppColors.gold.withValues(alpha: 0.5),
                      blurRadius: 16,
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              '#${player.number}',
              style: TextStyle(
                color: isGold ? const Color(0xFF0F172A) : AppColors.textPrimary,
                fontWeight: FontWeight.w900,
                fontSize: isGold ? 15 : 13,
              ),
            ),
          ),
        ),

        const SizedBox(height: 6),

        // Player Name
        Text(
          player.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isGold ? AppColors.textPrimary : AppColors.textSecondary,
            fontSize: isGold ? 12 : 11,
            fontWeight: FontWeight.w900,
          ),
        ),

        // Metric Value Badge
        Text(
          metricText,
          style: TextStyle(
            color: isGold ? AppColors.gold : const Color(0xFF67E8F9),
            fontSize: 11,
            fontWeight: FontWeight.w900,
          ),
        ),

        const SizedBox(height: 8),

        // Animated Pillar Box
        AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
          height: pillarHeight,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: pillarGradient,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            border: Border(
              top: BorderSide(color: borderColor, width: 2),
              left: BorderSide(color: borderColor.withValues(alpha: 0.3)),
              right: BorderSide(color: borderColor.withValues(alpha: 0.3)),
            ),
            boxShadow: isGold
                ? [
                    BoxShadow(
                      color: AppColors.gold.withValues(alpha: 0.2),
                      blurRadius: 20,
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              '$rank',
              style: TextStyle(
                color: rankTextColor,
                fontSize: isGold ? 26 : 20,
                fontWeight: FontWeight.w900,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ),
      ],
      ),
    );
  }

  // -------------------------------------------------------------
  // Right Column: Complete Squad Standings Table
  // -------------------------------------------------------------
  Widget _buildStandingsTableCard(List<LeaderboardPlayer> sortedSquad) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Table Card Subheader
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'COMPLETE SQUAD STANDINGS',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'All registered squad players across verified match shifts',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
                ),
                child: Text(
                  '${sortedSquad.length} Players',
                  style: const TextStyle(
                    color: Color(0xFF67E8F9),
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Table Columns Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 36,
                  child: Text(
                    'RANK',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 9, fontWeight: FontWeight.w900),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Text(
                    'PLAYER',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 9, fontWeight: FontWeight.w900),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'APPS',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textMuted, fontSize: 9, fontWeight: FontWeight.w900),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'G / A',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textMuted, fontSize: 9, fontWeight: FontWeight.w900),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'AVG RATING',
                    textAlign: TextAlign.right,
                    style: TextStyle(color: AppColors.textMuted, fontSize: 9, fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Scrollable Player Standings Rows
          Expanded(
            child: ListView.separated(
              itemCount: sortedSquad.length,
              separatorBuilder: (context, index) => const SizedBox(height: 6),
              itemBuilder: (context, index) {
                final player = sortedSquad[index];
                final rank = index + 1;
                final bool isFirst = rank == 1;
                final bool isTopThree = rank <= 3;

                return GestureDetector(
                  onTap: () => _showPlayerModal(player),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isFirst
                          ? AppColors.gold.withValues(alpha: 0.1)
                          : isTopThree
                              ? AppColors.info.withValues(alpha: 0.08)
                              : Colors.black26,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isFirst
                            ? AppColors.gold.withValues(alpha: 0.4)
                            : isTopThree
                                ? AppColors.info.withValues(alpha: 0.3)
                                : Colors.white.withValues(alpha: 0.05),
                      ),
                    ),
                    child: Row(
                      children: [
                        // Rank Icon / Number
                        SizedBox(
                          width: 36,
                          child: Text(
                            rank == 1
                                ? '🥇'
                                : rank == 2
                                    ? '🥈'
                                    : rank == 3
                                        ? '🥉'
                                        : '#$rank',
                            style: TextStyle(
                              color: isTopThree ? AppColors.textPrimary : AppColors.textMuted,
                              fontSize: rank <= 3 ? 14 : 11,
                              fontWeight: FontWeight.w900,
                              fontFamily: rank > 3 ? 'monospace' : null,
                            ),
                          ),
                        ),

                        // Player Identity (Jersey Number, Name & Role)
                        Expanded(
                          flex: 4,
                          child: Row(
                            children: [
                              Container(
                                width: 26,
                                height: 26,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.surfaceElevated,
                                  border: Border.all(
                                    color: isFirst ? AppColors.gold : AppColors.info.withValues(alpha: 0.5),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    '${player.number}',
                                    style: TextStyle(
                                      color: isFirst ? AppColors.gold : const Color(0xFF67E8F9),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      player.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    Text(
                                      player.role,
                                      style: TextStyle(
                                        color: AppColors.textMuted,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Appearances
                        Expanded(
                          flex: 2,
                          child: Text(
                            '${player.appearances}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),

                        // Goals & Assists
                        Expanded(
                          flex: 2,
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: '${player.goals}',
                                  style: const TextStyle(
                                    color: Color(0xFF67E8F9),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                                TextSpan(
                                  text: ' / ',
                                  style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                                ),
                                TextSpan(
                                  text: '${player.assists}',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Average Rating
                        Expanded(
                          flex: 2,
                          child: Text(
                            player.avgRating.toStringAsFixed(2),
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              color: player.avgRating >= 8.0
                                  ? AppColors.primary
                                  : const Color(0xFF67E8F9),
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                      ],
                    ),
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
