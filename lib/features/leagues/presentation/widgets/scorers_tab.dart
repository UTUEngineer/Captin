import 'package:cached_network_image/cached_network_image.dart';
import 'package:captain/core/theme/app_colors.dart';
import 'package:captain/features/leagues/application/leagues_providers.dart';
import 'package:captain/features/leagues/domain/league.dart';
import 'package:captain/features/leagues/domain/player.dart';
import 'package:captain/features/leagues/presentation/widgets/league_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Top scorers / top assists leaderboard (API-Football).
class ScorersTab extends ConsumerStatefulWidget {
  const ScorersTab({super.key, required this.league});

  final League league;

  @override
  ConsumerState<ScorersTab> createState() => _ScorersTabState();
}

class _ScorersTabState extends ConsumerState<ScorersTab> {
  String _kind = 'topscorers';

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(
      leagueLeadersProvider(
        (leagueId: widget.league.id, season: widget.league.season, kind: _kind),
      ),
    );
    final live = ref.watch(leaguesLiveDataProvider).value ?? true;
    final goals = _kind == 'topscorers';

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
          child: SegmentedButton<String>(
            segments: const [
              ButtonSegment(
                value: 'topscorers',
                label: Text('الهدافون'),
                icon: Icon(Icons.sports_soccer_rounded, size: 18),
              ),
              ButtonSegment(
                value: 'topassists',
                label: Text('صناع اللعب'),
                icon: Icon(Icons.assistant_direction_outlined, size: 18),
              ),
            ],
            selected: {_kind},
            onSelectionChanged: (v) => setState(() => _kind = v.first),
          ),
        ),
        Expanded(
          child: async.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('$e')),
            data: (players) {
              if (players.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.leaderboard_outlined,
                            size: 48, color: AppColors.textMuted),
                        const SizedBox(height: 12),
                        Text(
                          live
                              ? 'لا تتوفر إحصائيات الهدافين لهذا الموسم بعد.'
                              : 'قائمة الهدافين متاحة مع بيانات API-Football المباشرة. أضف المفتاح من الإعدادات.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                );
              }
              final top = goals ? players.first.goals : players.first.assists;
              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
                itemCount: players.length,
                separatorBuilder: (_, _) => const SizedBox(height: 6),
                itemBuilder: (context, i) => _LeaderRow(
                  rank: i + 1,
                  stats: players[i],
                  value: goals ? players[i].goals : players[i].assists,
                  maxValue: top == 0 ? 1 : top,
                  unit: goals ? 'هدف' : 'صناعة',
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _LeaderRow extends StatelessWidget {
  const _LeaderRow({
    required this.rank,
    required this.stats,
    required this.value,
    required this.maxValue,
    required this.unit,
  });

  final int rank;
  final PlayerStats stats;
  final int value;
  final int maxValue;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final medal = switch (rank) {
      1 => AppColors.gold,
      2 => const Color(0xFF94A3B8),
      3 => const Color(0xFFB45309),
      _ => AppColors.textMuted,
    };
    final photo = stats.player.photo;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: rank <= 3 ? medal.withValues(alpha: 0.6) : AppColors.border),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 26,
            child: Text(
              '$rank',
              textAlign: TextAlign.center,
              style: TextStyle(color: medal, fontWeight: FontWeight.w900, fontSize: 16),
            ),
          ),
          const SizedBox(width: 6),
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.surfaceSunken,
            backgroundImage: photo != null && photo.isNotEmpty
                ? CachedNetworkImageProvider(photo)
                : null,
            child: photo == null || photo.isEmpty
                ? Icon(Icons.person, color: AppColors.textMuted)
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stats.player.name,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    TeamCrest(
                      url: stats.teamLogo ?? '',
                      name: stats.teamName ?? '',
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        '${stats.teamName ?? ''} · ${stats.appearances} مباراة · تقييم ${stats.rating.toStringAsFixed(1)}',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: value / maxValue,
                    minHeight: 4,
                    backgroundColor: AppColors.surfaceSunken,
                    color: medal == AppColors.textMuted ? AppColors.primary : medal,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            children: [
              Text(
                '$value',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(unit, style: TextStyle(color: AppColors.textMuted, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }
}
