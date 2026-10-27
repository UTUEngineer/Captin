import 'package:captain/core/theme/app_colors.dart';
import 'package:captain/features/leagues/application/leagues_providers.dart';
import 'package:captain/features/leagues/domain/league.dart';
import 'package:captain/features/leagues/domain/match_fixture.dart';
import 'package:captain/features/leagues/presentation/widgets/league_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum _FixtureFilter { results, upcoming, live }

/// Results / upcoming / live matches grouped by round.
class FixturesTab extends ConsumerStatefulWidget {
  const FixturesTab({super.key, required this.league});

  final League league;

  @override
  ConsumerState<FixturesTab> createState() => _FixturesTabState();
}

class _FixturesTabState extends ConsumerState<FixturesTab> {
  _FixtureFilter _filter = _FixtureFilter.upcoming;

  @override
  Widget build(BuildContext context) {
    final params = (leagueId: widget.league.id, season: widget.league.season);
    final async = ref.watch(fixturesProvider(params));
    final live = ref.watch(leaguesLiveDataProvider).value ?? true;

    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Text(
          'خطأ في المباريات: $error',
          style: const TextStyle(color: AppColors.accentRed),
        ),
      ),
      data: (fixtures) {
        final filtered = fixtures.where((f) {
          return switch (_filter) {
            _FixtureFilter.results => f.isFinished,
            _FixtureFilter.upcoming => f.isUpcoming,
            _FixtureFilter.live => f.isLive || f.statusShort == 'HT',
          };
        }).toList()
          ..sort(
            (a, b) => _filter == _FixtureFilter.results
                ? b.date.compareTo(a.date)
                : a.date.compareTo(b.date),
          );

        // Group by round (fallback: by date).
        final groups = <String, List<MatchFixture>>{};
        for (final f in filtered) {
          final key = _roundLabel(f);
          groups.putIfAbsent(key, () => []).add(f);
        }

        return Column(
          children: [
            if (!live) const SampleDataBanner(),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
              child: SegmentedButton<_FixtureFilter>(
                segments: const [
                  ButtonSegment(
                    value: _FixtureFilter.upcoming,
                    label: Text('القادمة'),
                    icon: Icon(Icons.event_outlined, size: 18),
                  ),
                  ButtonSegment(
                    value: _FixtureFilter.results,
                    label: Text('النتائج'),
                    icon: Icon(Icons.scoreboard_outlined, size: 18),
                  ),
                  ButtonSegment(
                    value: _FixtureFilter.live,
                    label: Text('مباشر'),
                    icon: Icon(Icons.sensors_rounded, size: 18),
                  ),
                ],
                selected: {_filter},
                onSelectionChanged: (v) => setState(() => _filter = v.first),
              ),
            ),
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Text(
                        switch (_filter) {
                          _FixtureFilter.live => 'لا توجد مباريات مباشرة الآن.',
                          _FixtureFilter.results => 'لا توجد نتائج بعد.',
                          _FixtureFilter.upcoming => 'لا توجد مباريات قادمة.',
                        },
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
                      children: [
                        for (final entry in groups.entries) ...[
                          SectionTitle(
                            entry.key,
                            trailing: Text(
                              '${entry.value.length} مباريات',
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          for (final f in entry.value) ...[
                            FixtureCard(fixture: f),
                            const SizedBox(height: 8),
                          ],
                        ],
                      ],
                    ),
            ),
          ],
        );
      },
    );
  }

  static String _roundLabel(MatchFixture f) {
    final round = f.round;
    if (round != null && round.isNotEmpty) {
      final number = RegExp(r'(\d+)$').firstMatch(round)?.group(1);
      if (number != null) return 'الجولة $number';
      return round;
    }
    final d = f.date.toLocal();
    return '${d.day}/${d.month}/${d.year}';
  }
}

/// One match row: crests, score / kick-off time, status and venue.
class FixtureCard extends StatelessWidget {
  const FixtureCard({super.key, required this.fixture});

  final MatchFixture fixture;

  @override
  Widget build(BuildContext context) {
    final local = fixture.date.toLocal();
    final time =
        '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
    final date = '${local.day}/${local.month}';
    final hasScore = fixture.homeGoals != null && fixture.awayGoals != null;
    final outcome = fixture.outcome;

    TextStyle teamStyle(bool winner) => TextStyle(
          color: AppColors.textPrimary,
          fontWeight: winner ? FontWeight.w800 : FontWeight.w600,
          fontSize: 13,
        );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: fixture.isLive ? AppColors.danger : AppColors.border,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    TeamCrest(
                      url: fixture.homeTeam.logo,
                      name: fixture.homeTeam.nameAr,
                      size: 28,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        fixture.homeTeam.nameAr,
                        overflow: TextOverflow.ellipsis,
                        style: teamStyle(outcome == 1),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 78,
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: hasScore ? AppColors.surfaceSunken : AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Text(
                      hasScore
                          ? '${fixture.homeGoals} - ${fixture.awayGoals}'
                          : time,
                      textDirection: TextDirection.ltr,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: hasScore ? 18 : 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      fixture.isLive && fixture.elapsed != null
                          ? "${fixture.elapsed}'"
                          : hasScore
                              ? fixture.statusLabelAr
                              : date,
                      style: TextStyle(
                        color: fixture.isLive
                            ? AppColors.danger
                            : AppColors.textSecondary,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        fixture.awayTeam.nameAr,
                        textAlign: TextAlign.end,
                        overflow: TextOverflow.ellipsis,
                        style: teamStyle(outcome == -1),
                      ),
                    ),
                    const SizedBox(width: 8),
                    TeamCrest(
                      url: fixture.awayTeam.logo,
                      name: fixture.awayTeam.nameAr,
                      size: 28,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (fixture.venue != null && fixture.venue!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.stadium_outlined, size: 13, color: AppColors.textMuted),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    fixture.venue!,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
