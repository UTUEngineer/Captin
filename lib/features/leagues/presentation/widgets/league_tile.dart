import 'package:captain/core/router/app_router.dart';
import 'package:captain/core/theme/app_colors.dart';
import 'package:captain/features/leagues/application/leagues_providers.dart';
import 'package:captain/features/leagues/domain/league.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LeagueTile extends StatelessWidget {
  const LeagueTile({
    super.key,
    required this.league,
    required this.onTap,
  });

  final League league;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceElevated,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              CachedNetworkImage(
                imageUrl: league.logo,
                width: 48,
                height: 48,
                placeholder: (_, __) => const SizedBox(
                  width: 48,
                  height: 48,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                errorWidget: (_, __, ___) => const Icon(
                  Icons.sports_soccer,
                  color: AppColors.textSecondary,
                  size: 48,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      league.nameAr,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (league.flag.isNotEmpty)
                          CachedNetworkImage(
                            imageUrl: league.flag,
                            width: 20,
                            height: 14,
                            errorWidget: (_, __, ___) => const SizedBox(),
                          ),
                        const SizedBox(width: 6),
                        Text(
                          league.country,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.pitchGreenLight.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${league.season}',
                  style: const TextStyle(
                    color: AppColors.pitchGreenLight,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_left, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

class LeaguesList extends ConsumerWidget {
  const LeaguesList({
    super.key,
    required this.regionCode,
    required this.isArabic,
  });

  final String regionCode;
  final bool isArabic;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaguesAsync = ref.watch(leaguesByRegionProvider(regionCode));

    return leaguesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            isArabic ? 'خطأ: $error' : 'Error: $error',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.accentRed),
          ),
        ),
      ),
      data: (leagues) {
        if (leagues.isEmpty) {
          return Center(
            child: Text(
              isArabic ? 'لا توجد دوريات.' : 'No leagues found.',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: leagues.length,
          itemBuilder: (context, index) {
            final league = leagues[index];
            return LeagueTile(
              league: league,
              onTap: () => context.push(AppRoutes.leagueDetail(league.id), extra: league),
            );
          },
        );
      },
    );
  }
}
