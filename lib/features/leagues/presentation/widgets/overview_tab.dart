import 'package:captain/core/theme/app_colors.dart';
import 'package:captain/features/leagues/application/leagues_providers.dart';
import 'package:captain/features/leagues/domain/league.dart';
import 'package:captain/features/leagues/domain/match_fixture.dart';
import 'package:captain/features/leagues/domain/standing.dart';
import 'package:captain/features/leagues/presentation/widgets/fixtures_tab.dart';
import 'package:captain/features/leagues/presentation/widgets/league_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Season snapshot: key numbers, leaders, best attack / defence, recent
/// results and next matches.
class OverviewTab extends ConsumerWidget {
  const OverviewTab({super.key, required this.league, required this.onOpenTab});

  final League league;
  final ValueChanged<int> onOpenTab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final params = (leagueId: league.id, season: league.season);
    final standingsAsync = ref.watch(standingsProvider(params));
    final fixturesAsync = ref.watch(fixturesProvider(params));
    final live = ref.watch(leaguesLiveDataProvider).value ?? true;

    if (standingsAsync.isLoading || fixturesAsync.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    final standings = standingsAsync.value ?? const <Standing>[];
    final fixtures = fixturesAsync.value ?? const <MatchFixture>[];
    final stats = LeagueSeasonStats.from(standings, fixtures);

    final recent = fixtures.where((f) => f.isFinished).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    final upcoming = fixtures.where((f) => f.isUpcoming || f.isLive).toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
      children: [
        if (!live) const SampleDataBanner(),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: MediaQuery.sizeOf(context).width > 700 ? 4 : 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 1.7,
          children: [
            StatTile(
              label: 'مباريات لعبت',
              value: '${stats.matchesPlayed}/${fixtures.length}',
              icon: Icons.sports_soccer_rounded,
            ),
            StatTile(
              label: 'إجمالي الأهداف',
              value: '${stats.totalGoals}',
              icon: Icons.sports_score_rounded,
              accent: AppColors.gold,
            ),
            StatTile(
              label: 'معدل الأهداف للمباراة',
              value: stats.goalsPerMatch.toStringAsFixed(2),
              icon: Icons.trending_up_rounded,
              accent: AppColors.info,
            ),
            StatTile(
              label: 'فوز / تعادل / خسارة الأرض',
              value:
                  '${stats.homeWinPct.round()}% · ${stats.drawPct.round()}% · ${stats.awayWinPct.round()}%',
              icon: Icons.home_rounded,
              accent: AppColors.secondary,
            ),
          ],
        ),
        if (standings.isNotEmpty) ...[
          SectionTitle(
            'المتصدر',
            trailing: TextButton(
              onPressed: () => onOpenTab(1),
              child: const Text('الترتيب الكامل'),
            ),
          ),
          _LeaderCard(standing: standings.first),
          const SizedBox(height: 8),
          Row(
            children: [
              if (stats.bestAttack != null)
                Expanded(
                  child: _MiniTeamStat(
                    title: 'أقوى هجوم',
                    standing: stats.bestAttack!,
                    value: '${stats.bestAttack!.goalsFor} هدف',
                    color: AppColors.success,
                  ),
                ),
              const SizedBox(width: 8),
              if (stats.bestDefence != null)
                Expanded(
                  child: _MiniTeamStat(
                    title: 'أقوى دفاع',
                    standing: stats.bestDefence!,
                    value: '${stats.bestDefence!.goalsAgainst} مستقبلة',
                    color: AppColors.secondary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (stats.inForm != null)
            _MiniTeamStat(
              title: 'الأفضل مستوى (آخر 5)',
              standing: stats.inForm!,
              value: '',
              color: AppColors.gold,
              trailing: FormChips(form: stats.inForm!.form),
            ),
        ],
        if (upcoming.isNotEmpty) ...[
          SectionTitle(
            'المباريات القادمة',
            trailing: TextButton(
              onPressed: () => onOpenTab(2),
              child: const Text('الكل'),
            ),
          ),
          for (final f in upcoming.take(4)) ...[
            FixtureCard(fixture: f),
            const SizedBox(height: 8),
          ],
        ],
        if (recent.isNotEmpty) ...[
          const SectionTitle('آخر النتائج'),
          for (final f in recent.take(4)) ...[
            FixtureCard(fixture: f),
            const SizedBox(height: 8),
          ],
        ],
      ],
    );
  }
}

/// Aggregates computed from the table and fixtures.
class LeagueSeasonStats {
  const LeagueSeasonStats({
    required this.matchesPlayed,
    required this.totalGoals,
    required this.homeWins,
    required this.draws,
    required this.awayWins,
    this.bestAttack,
    this.bestDefence,
    this.inForm,
  });

  factory LeagueSeasonStats.from(
    List<Standing> standings,
    List<MatchFixture> fixtures,
  ) {
    final finished = fixtures.where((f) => f.outcome != null).toList();
    var goals = 0, home = 0, draw = 0, away = 0;
    for (final f in finished) {
      goals += f.homeGoals! + f.awayGoals!;
      switch (f.outcome) {
        case 1:
          home++;
        case 0:
          draw++;
        default:
          away++;
      }
    }
    Standing? maxBy(int Function(Standing) score) => standings.isEmpty
        ? null
        : standings.reduce((a, b) => score(b) > score(a) ? b : a);
    int formScore(Standing s) => s.form.split('').fold(
          0,
          (sum, c) => sum + (c == 'W' ? 3 : c == 'D' ? 1 : 0),
        );
    return LeagueSeasonStats(
      matchesPlayed: finished.length,
      totalGoals: goals,
      homeWins: home,
      draws: draw,
      awayWins: away,
      bestAttack: maxBy((s) => s.goalsFor),
      bestDefence: maxBy((s) => -s.goalsAgainst),
      inForm: standings.any((s) => s.form.isNotEmpty) ? maxBy(formScore) : null,
    );
  }

  final int matchesPlayed;
  final int totalGoals;
  final int homeWins;
  final int draws;
  final int awayWins;
  final Standing? bestAttack;
  final Standing? bestDefence;
  final Standing? inForm;

  double get goalsPerMatch =>
      matchesPlayed == 0 ? 0 : totalGoals / matchesPlayed;
  double _pct(int v) => matchesPlayed == 0 ? 0 : v * 100 / matchesPlayed;
  double get homeWinPct => _pct(homeWins);
  double get drawPct => _pct(draws);
  double get awayWinPct => _pct(awayWins);
}

class _LeaderCard extends StatelessWidget {
  const _LeaderCard({required this.standing});

  final Standing standing;

  @override
  Widget build(BuildContext context) {
    final s = standing;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.22),
            AppColors.surfaceElevated,
          ],
          begin: AlignmentDirectional.centerStart,
          end: AlignmentDirectional.centerEnd,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          TeamCrest(url: s.teamLogo, name: s.teamNameAr, size: 52),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.teamNameAr,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${s.win} فوز · ${s.draw} تعادل · ${s.lose} خسارة',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
                const SizedBox(height: 6),
                FormChips(form: s.form),
              ],
            ),
          ),
          Column(
            children: [
              Text(
                '${s.points}',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text('نقطة', style: TextStyle(color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniTeamStat extends StatelessWidget {
  const _MiniTeamStat({
    required this.title,
    required this.standing,
    required this.value,
    required this.color,
    this.trailing,
  });

  final String title;
  final Standing standing;
  final String value;
  final Color color;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 36,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 10),
          TeamCrest(url: standing.teamLogo, name: standing.teamNameAr, size: 28),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                Text(
                  standing.teamNameAr,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (value.isNotEmpty)
                  Text(value, style: TextStyle(color: color, fontSize: 12)),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
