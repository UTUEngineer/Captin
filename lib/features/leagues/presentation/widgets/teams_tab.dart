import 'package:captain/core/theme/app_colors.dart';
import 'package:captain/features/leagues/application/leagues_providers.dart';
import 'package:captain/features/leagues/domain/league.dart';
import 'package:captain/features/leagues/presentation/widgets/league_widgets.dart';
import 'package:captain/features/leagues/presentation/widgets/team_detail_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Club grid; tap a club for its detail sheet.
class TeamsTab extends ConsumerWidget {
  const TeamsTab({super.key, required this.league});

  final League league;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final params = (leagueId: league.id, season: league.season);
    final async = ref.watch(teamsProvider(params));
    final standings = ref.watch(standingsProvider(params)).value ?? const [];

    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Text(
          'خطأ في الفرق: $error',
          style: const TextStyle(color: AppColors.accentRed),
        ),
      ),
      data: (teams) {
        if (teams.isEmpty) {
          return const Center(child: Text('لا توجد فرق.'));
        }
        final width = MediaQuery.sizeOf(context).width;
        return GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: width > 900 ? 5 : width > 600 ? 4 : 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 0.95,
          ),
          itemCount: teams.length,
          itemBuilder: (context, index) {
            final team = teams[index];
            final standing =
                standings.where((s) => s.teamId == team.id).firstOrNull;
            return InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => TeamDetailSheet.show(
                context,
                league: league,
                teamId: team.id,
                teamName: team.nameAr,
                teamLogo: team.logo,
              ),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TeamCrest(url: team.logo, name: team.nameAr, size: 52),
                    const SizedBox(height: 10),
                    Text(
                      team.nameAr,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (team.venue != null)
                      Text(
                        team.venue!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: AppColors.textMuted, fontSize: 10),
                      ),
                    if (standing != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        '#${standing.rank} · ${standing.points} نقطة',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      FormChips(form: standing.form, size: 14),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
