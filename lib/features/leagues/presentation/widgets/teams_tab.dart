import 'package:captain/core/theme/app_colors.dart';
import 'package:captain/features/leagues/application/leagues_providers.dart';
import 'package:captain/features/leagues/domain/league.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TeamsTab extends ConsumerWidget {
  const TeamsTab({super.key, required this.league});

  final League league;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final params = (leagueId: league.id, season: league.season);
    final async = ref.watch(teamsProvider(params));

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

        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: teams.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final team = teams[index];
            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  CachedNetworkImage(
                    imageUrl: team.logo,
                    width: 40,
                    height: 40,
                    errorWidget: (_, __, ___) =>
                        const Icon(Icons.shield_outlined, size: 40),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          team.nameAr,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        if (team.venue != null)
                          Text(
                            team.venue!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                          ),
                      ],
                    ),
                  ),
                  if (team.founded != null)
                    Text(
                      '${team.founded}',
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
