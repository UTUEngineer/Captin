import 'package:captain/core/theme/app_colors.dart';
import 'package:captain/features/leagues/application/leagues_providers.dart';
import 'package:captain/features/leagues/domain/league.dart';
import 'package:captain/features/leagues/domain/match_fixture.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FixturesTab extends ConsumerWidget {
  const FixturesTab({super.key, required this.league});

  final League league;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final params = (leagueId: league.id, season: league.season);
    final async = ref.watch(fixturesProvider(params));

    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Text(
          'خطأ في المباريات: $error',
          style: const TextStyle(color: AppColors.accentRed),
        ),
      ),
      data: (fixtures) {
        if (fixtures.isEmpty) {
          return const Center(child: Text('لا توجد مباريات.'));
        }

        final sorted = [...fixtures]..sort((a, b) => a.date.compareTo(b.date));

        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: sorted.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) => _FixtureCard(fixture: sorted[index]),
        );
      },
    );
  }
}

class _FixtureCard extends StatelessWidget {
  const _FixtureCard({required this.fixture});

  final MatchFixture fixture;

  @override
  Widget build(BuildContext context) {
    final local = fixture.date.toLocal();
    final dateLabel =
        '${local.day}/${local.month} ${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
    final scoreLabel = fixture.homeGoals != null && fixture.awayGoals != null
        ? '${fixture.homeGoals} - ${fixture.awayGoals}'
        : '–';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(dateLabel, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              Text(
                fixture.statusLabelAr,
                style: TextStyle(
                  color: fixture.isLive ? AppColors.accentOrange : AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: fixture.isLive ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _TeamLine(teamName: fixture.homeTeam.nameAr, logoUrl: fixture.homeTeam.logo)),
              Text(
                scoreLabel,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: _TeamLine(
                  teamName: fixture.awayTeam.nameAr,
                  logoUrl: fixture.awayTeam.logo,
                  alignEnd: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TeamLine extends StatelessWidget {
  const _TeamLine({
    required this.teamName,
    required this.logoUrl,
    this.alignEnd = false,
  });

  final String teamName;
  final String logoUrl;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    final logo = CachedNetworkImage(
      imageUrl: logoUrl,
      width: 24,
      height: 24,
      errorWidget: (_, __, ___) => const Icon(Icons.shield_outlined, size: 24),
    );
    final name = Flexible(
      child: Text(
        teamName,
        overflow: TextOverflow.ellipsis,
        textAlign: alignEnd ? TextAlign.end : TextAlign.start,
      ),
    );

    return Row(
      mainAxisAlignment: alignEnd ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: alignEnd ? [name, const SizedBox(width: 8), logo] : [logo, const SizedBox(width: 8), name],
    );
  }
}
