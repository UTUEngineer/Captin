import 'package:cached_network_image/cached_network_image.dart';
import 'package:captain/core/theme/app_colors.dart';
import 'package:captain/features/leagues/application/leagues_providers.dart';
import 'package:captain/features/leagues/domain/league.dart';
import 'package:captain/features/leagues/domain/match_fixture.dart';
import 'package:captain/features/leagues/domain/player.dart';
import 'package:captain/features/leagues/domain/standing.dart';
import 'package:captain/features/leagues/presentation/widgets/fixtures_tab.dart';
import 'package:captain/features/leagues/presentation/widgets/league_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Club page as a bottom sheet: table position, record, form, home/away
/// split, next/last matches and the squad grouped by position.
class TeamDetailSheet extends ConsumerWidget {
  const TeamDetailSheet({
    super.key,
    required this.league,
    required this.teamId,
    required this.teamName,
    required this.teamLogo,
  });

  final League league;
  final int teamId;
  final String teamName;
  final String teamLogo;

  static Future<void> show(
    BuildContext context, {
    required League league,
    required int teamId,
    required String teamName,
    required String teamLogo,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.85,
          maxChildSize: 0.95,
          builder: (context, controller) => PrimaryScrollController(
            controller: controller,
            child: TeamDetailSheet(
              league: league,
              teamId: teamId,
              teamName: teamName,
              teamLogo: teamLogo,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final params = (leagueId: league.id, season: league.season);
    final standings = ref.watch(standingsProvider(params)).value ?? const [];
    final fixtures = ref.watch(fixturesProvider(params)).value ?? const [];
    final squadAsync = ref.watch(teamSquadProvider(teamId));
    final standing = standings.where((s) => s.teamId == teamId).firstOrNull;
    final teamFixtures = fixtures
        .where((f) => f.homeTeam.id == teamId || f.awayTeam.id == teamId)
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    final split = _HomeAwaySplit.from(teamId, teamFixtures);
    final next = teamFixtures.where((f) => f.isUpcoming).firstOrNull;
    final last = teamFixtures.where((f) => f.isFinished).lastOrNull;

    return ListView(
      controller: PrimaryScrollController.of(context),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      children: [
        Row(
          children: [
            TeamCrest(url: teamLogo, name: teamName, size: 56),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    teamName,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    league.nameAr,
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            if (standing != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      '#${standing.rank}',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      '${standing.points} نقطة',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                    ),
                  ],
                ),
              ),
          ],
        ),
        if (standing != null) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: StatTile(label: 'فوز', value: '${standing.win}', accent: AppColors.success)),
              const SizedBox(width: 8),
              Expanded(child: StatTile(label: 'تعادل', value: '${standing.draw}')),
              const SizedBox(width: 8),
              Expanded(child: StatTile(label: 'خسارة', value: '${standing.lose}', accent: AppColors.danger)),
              const SizedBox(width: 8),
              Expanded(
                child: StatTile(
                  label: 'فارق الأهداف',
                  value: standing.goalDifference > 0
                      ? '+${standing.goalDifference}'
                      : '${standing.goalDifference}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text('آخر 5:', style: TextStyle(color: AppColors.textSecondary)),
              const SizedBox(width: 8),
              FormChips(form: standing.form, size: 22),
              const Spacer(),
              if (standing.zone != StandingZone.none)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: zoneColor(standing.zone).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    standing.zone == StandingZone.relegation ? 'منطقة الهبوط' : 'مركز مؤهل',
                    style: TextStyle(color: zoneColor(standing.zone), fontSize: 11),
                  ),
                ),
            ],
          ),
        ],
        if (split.played > 0) ...[
          const SectionTitle('على الأرض وخارجها'),
          _SplitRow(label: 'على أرضه', record: split.home),
          const SizedBox(height: 6),
          _SplitRow(label: 'خارج أرضه', record: split.away),
        ],
        if (next != null) ...[
          const SectionTitle('المباراة القادمة'),
          FixtureCard(fixture: next),
        ],
        if (last != null) ...[
          const SectionTitle('آخر مباراة'),
          FixtureCard(fixture: last),
        ],
        const SectionTitle('قائمة اللاعبين'),
        squadAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Text('$e'),
          data: (squad) {
            if (squad.isEmpty) {
              return Text(
                'قائمة اللاعبين متاحة مع بيانات API-Football المباشرة.',
                style: TextStyle(color: AppColors.textSecondary),
              );
            }
            final byPosition = <String, List<SquadPlayer>>{};
            for (final p in squad) {
              byPosition.putIfAbsent(p.positionAr, () => []).add(p);
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final entry in byPosition.entries) ...[
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 4),
                    child: Text(
                      '${entry.key} (${entry.value.length})',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  for (final p in entry.value)
                    ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: AppColors.surfaceSunken,
                        backgroundImage: p.photo != null && p.photo!.isNotEmpty
                            ? CachedNetworkImageProvider(p.photo!)
                            : null,
                      ),
                      title: Text(p.name),
                      subtitle: p.age == null ? null : Text('${p.age} سنة'),
                      trailing: p.number == null
                          ? null
                          : Text(
                              '${p.number}',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                              ),
                            ),
                    ),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}

class _Record {
  int w = 0, d = 0, l = 0, gf = 0, ga = 0;
  int get played => w + d + l;
  int get points => w * 3 + d;
}

class _HomeAwaySplit {
  _HomeAwaySplit(this.home, this.away);

  final _Record home;
  final _Record away;

  int get played => home.played + away.played;

  factory _HomeAwaySplit.from(int teamId, List<MatchFixture> fixtures) {
    final home = _Record(), away = _Record();
    for (final f in fixtures) {
      if (f.outcome == null) continue;
      final isHome = f.homeTeam.id == teamId;
      final r = isHome ? home : away;
      final scored = isHome ? f.homeGoals! : f.awayGoals!;
      final conceded = isHome ? f.awayGoals! : f.homeGoals!;
      r.gf += scored;
      r.ga += conceded;
      if (scored > conceded) {
        r.w++;
      } else if (scored == conceded) {
        r.d++;
      } else {
        r.l++;
      }
    }
    return _HomeAwaySplit(home, away);
  }
}

class _SplitRow extends StatelessWidget {
  const _SplitRow({required this.label, required this.record});

  final String label;
  final _Record record;

  @override
  Widget build(BuildContext context) {
    final r = record;
    final total = r.played == 0 ? 1 : r.played;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(label, style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800)),
              const Spacer(),
              Text(
                '${r.played} مباراة · ${r.points} نقطة · ${r.gf}:${r.ga}',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 8,
              child: Row(
                children: [
                  Expanded(flex: (r.w * 100 / total).round().clamp(0, 100), child: Container(color: AppColors.success)),
                  Expanded(flex: (r.d * 100 / total).round().clamp(0, 100), child: Container(color: AppColors.textMuted)),
                  Expanded(flex: (r.l * 100 / total).round().clamp(0, 100), child: Container(color: AppColors.danger)),
                  if (r.played == 0) Expanded(child: Container(color: AppColors.surfaceSunken)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
