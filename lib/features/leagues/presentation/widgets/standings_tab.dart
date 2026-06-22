import 'package:captain/core/theme/app_colors.dart';
import 'package:captain/features/leagues/application/leagues_providers.dart';
import 'package:captain/features/leagues/domain/league.dart';
import 'package:captain/features/leagues/domain/standing.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StandingsTab extends ConsumerWidget {
  const StandingsTab({super.key, required this.league});

  final League league;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final params = (leagueId: league.id, season: league.season);
    final async = ref.watch(standingsProvider(params));

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

        return Column(
          children: [
            _StandingsHeader(),
            Expanded(
              child: ListView.builder(
                itemCount: standings.length,
                itemBuilder: (context, index) =>
                    _StandingRow(standing: standings[index], index: index),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _StandingsHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: AppColors.surfaceElevated,
      child: const Row(
        children: [
          SizedBox(
            width: 30,
            child: Text('#', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          ),
          Expanded(
            child: Text('الفريق', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          ),
          SizedBox(
            width: 30,
            child: Text('ل', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          ),
          SizedBox(
            width: 30,
            child: Text('ف', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          ),
          SizedBox(
            width: 30,
            child: Text('خ', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          ),
          SizedBox(
            width: 40,
            child: Text('نقاط', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

class _StandingRow extends StatelessWidget {
  const _StandingRow({required this.standing, required this.index});

  final Standing standing;
  final int index;

  @override
  Widget build(BuildContext context) {
    final isTop3 = index < 3;
    final isRelegation = index >= 13;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
        color: isTop3
            ? AppColors.pitchGreenLight.withValues(alpha: 0.08)
            : isRelegation
                ? AppColors.accentRed.withValues(alpha: 0.08)
                : Colors.transparent,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Text(
              '${index + 1}',
              style: TextStyle(
                color: isTop3 ? AppColors.pitchGreenLight : AppColors.textSecondary,
                fontWeight: isTop3 ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          CachedNetworkImage(
            imageUrl: standing.teamLogo,
            width: 24,
            height: 24,
            errorWidget: (_, __, ___) => const Icon(Icons.shield_outlined, size: 24),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              standing.teamNameAr,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
            ),
          ),
          SizedBox(
            width: 30,
            child: Text(
              '${standing.played}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textPrimary),
            ),
          ),
          SizedBox(
            width: 30,
            child: Text(
              '${standing.win}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textPrimary),
            ),
          ),
          SizedBox(
            width: 30,
            child: Text(
              '${standing.lose}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textPrimary),
            ),
          ),
          SizedBox(
            width: 40,
            child: Text(
              '${standing.points}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
