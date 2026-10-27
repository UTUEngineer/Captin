import 'package:captain/core/theme/app_colors.dart';
import 'package:captain/features/leagues/application/leagues_providers.dart';
import 'package:captain/features/leagues/domain/league.dart';
import 'package:captain/features/leagues/domain/standing.dart';
import 'package:captain/features/leagues/presentation/widgets/league_widgets.dart';
import 'package:captain/features/leagues/presentation/widgets/team_detail_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Full league table: P W D L GF GA GD Pts, last-5 form and qualification
/// zones. Horizontally scrollable on narrow phones.
class StandingsTab extends ConsumerWidget {
  const StandingsTab({super.key, required this.league});

  final League league;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final params = (leagueId: league.id, season: league.season);
    final async = ref.watch(standingsProvider(params));
    final live = ref.watch(leaguesLiveDataProvider).value ?? true;

    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Text(
          'خطأ في الترتيب: $error',
          style: const TextStyle(color: AppColors.accentRed),
        ),
      ),
      data: (standings) {
        if (standings.isEmpty) {
          return const Center(child: Text('لا يوجد ترتيب متاح.'));
        }
        final zones = standings.map((s) => s.zone).toSet()
          ..remove(StandingZone.none);

        return ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            if (!live) const SampleDataBanner(),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: MediaQuery.sizeOf(context).width - 24,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: IntrinsicWidth(
                    child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _HeaderRow(),
                      for (final s in standings)
                        _StandingRow(
                          standing: s,
                          onTap: () => TeamDetailSheet.show(
                            context,
                            league: league,
                            teamId: s.teamId,
                            teamName: s.teamNameAr,
                            teamLogo: s.teamLogo,
                          ),
                        ),
                    ],
                  ),
                  ),
                ),
              ),
            ),
            if (zones.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                child: Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    for (final z in zones)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: zoneColor(z),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            switch (z) {
                              StandingZone.championsLeague => 'دوري أبطال آسيا للنخبة',
                              StandingZone.continental => 'بطولة قارية',
                              StandingZone.relegation => 'الهبوط',
                              StandingZone.none => '',
                            },
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

const _numW = 34.0;

class _HeaderRow extends StatelessWidget {
  const _HeaderRow();

  @override
  Widget build(BuildContext context) {
    TextStyle style() => TextStyle(
          color: AppColors.textMuted,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        );
    Widget cell(String t, {double w = _numW}) => SizedBox(
          width: w,
          child: Text(t, textAlign: TextAlign.center, style: style()),
        );
    return Container(
      color: AppColors.surfaceSunken,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          const SizedBox(width: 6),
          cell('#', w: 28),
          SizedBox(width: 170, child: Text('الفريق', style: style())),
          cell('لعب'),
          cell('فوز'),
          cell('تعادل'),
          cell('خسارة'),
          cell('له'),
          cell('عليه'),
          cell('±'),
          cell('نقاط', w: 44),
          SizedBox(
            width: 118,
            child: Text('آخر 5', textAlign: TextAlign.center, style: style()),
          ),
        ],
      ),
    );
  }
}

class _StandingRow extends StatelessWidget {
  const _StandingRow({required this.standing, required this.onTap});

  final Standing standing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = standing;
    Widget cell(String t, {double w = _numW, bool bold = false, Color? color}) =>
        SizedBox(
          width: w,
          child: Text(
            t,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: color ?? AppColors.textPrimary,
              fontSize: 13,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        );
    final gd = s.goalDifference;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.border, width: 0.6)),
        ),
        child: Row(
          children: [
            Container(width: 4, height: 26, color: zoneColor(s.zone)),
            const SizedBox(width: 2),
            cell('${s.rank}', w: 28, bold: true),
            SizedBox(
              width: 170,
              child: Row(
                children: [
                  TeamCrest(url: s.teamLogo, name: s.teamNameAr, size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      s.teamNameAr,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            cell('${s.played}'),
            cell('${s.win}'),
            cell('${s.draw}'),
            cell('${s.lose}'),
            cell('${s.goalsFor}'),
            cell('${s.goalsAgainst}'),
            cell(
              gd > 0 ? '+$gd' : '$gd',
              color: gd > 0
                  ? AppColors.success
                  : gd < 0
                      ? AppColors.danger
                      : AppColors.textSecondary,
            ),
            cell('${s.points}', w: 44, bold: true, color: AppColors.primary),
            SizedBox(
              width: 118,
              child: Center(child: FormChips(form: s.form)),
            ),
          ],
        ),
      ),
    );
  }
}
