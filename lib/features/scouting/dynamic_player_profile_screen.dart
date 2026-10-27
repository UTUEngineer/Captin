import 'package:captain/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'player_dossier_model.dart';
import 'player_profile_screen.dart';
import 'player_scouting_provider.dart';

class DynamicPlayerProfileScreen extends ConsumerWidget {
  final String playerId;

  const DynamicPlayerProfileScreen({super.key, required this.playerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dossierAsync = ref.watch(playerDossierProvider(playerId));

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F17),
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          'DYNAMIC SCOUTING DOSSIER',
          style: TextStyle(
            letterSpacing: 1.5,
            fontWeight: FontWeight.w900,
            fontSize: 15,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: dossierAsync.when(
        loading: () => Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
                const SizedBox(height: 12),
                Text(
                  'Scouting Load Failure: $err',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.black,
                  ),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry Connection'),
                  onPressed: () => ref.refresh(playerDossierProvider(playerId)),
                ),
              ],
            ),
          ),
        ),
        data: (dossier) {

          final radarAttributes = [
            RadarAttribute(label: 'PAC (${dossier.pace})', value: dossier.pace.toDouble()),
            RadarAttribute(label: 'SHO (${dossier.shooting})', value: dossier.shooting.toDouble()),
            RadarAttribute(label: 'PAS (${dossier.passing})', value: dossier.passing.toDouble()),
            RadarAttribute(label: 'DRI (${dossier.dribbling})', value: dossier.dribbling.toDouble()),
            RadarAttribute(label: 'DEF (${dossier.defending})', value: dossier.defending.toDouble()),
            RadarAttribute(label: 'PHY (${dossier.physical})', value: dossier.physical.toDouble()),
          ];

          return _buildProfileBody(context, dossier, radarAttributes);
        },
      ),
    );
  }

  Widget _buildProfileBody(
    BuildContext context,
    PlayerFullDossier dossier,
    List<RadarAttribute> radar,
  ) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Dynamic Header Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.subtle),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                  child: Text(
                    '#${dossier.jerseyNumber}',
                    style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dossier.fullName,
                        style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${dossier.clubName} • ${dossier.tacticalArchetype}',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${dossier.nationality} • ${dossier.age} y/o • ${dossier.height} • ${dossier.marketValue}',
                        style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                CircleAvatar(
                  backgroundColor: AppColors.primary,
                  radius: 20,
                  child: Text(
                    '${dossier.overallRating}',
                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Radar Painter
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.subtle),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'DYNAMIC FIFA RADAR',
                      style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    Text(
                      'SUPABASE PERSISTED',
                      style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 220,
                  child: CustomPaint(
                    painter: RadarChartPainter(
                      attributes: radar,
                      fillColor: AppColors.primary.withValues(alpha: 0.28),
                      outlineColor: AppColors.primary,
                      webColor: AppColors.border,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // On-Device Scouting Report Card
          Builder(
            builder: (context) {
              final report = dossier.computedScoutingReport;
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.bolt, color: AppColors.primary, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'ON-DEVICE TACTICAL INTEL',
                          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1.1),
                        ),
                        Spacer(),
                        Text(
                          '0ms Latency',
                          style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      report.summary,
                      style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 12),
                    Text('Tactical Strengths:', style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    for (final s in report.strengths)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle, color: AppColors.primary, size: 14),
                            const SizedBox(width: 6),
                            Expanded(child: Text(s, style: TextStyle(color: AppColors.textPrimary, fontSize: 12))),
                          ],
                        ),
                      ),
                    if (report.vulnerabilities.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text('Pressing Triggers / Counter-measures:', style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      for (final trigger in report.pressingTriggers)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: [
                              const Icon(Icons.warning_amber_rounded, color: Colors.orangeAccent, size: 14),
                              const SizedBox(width: 6),
                              Expanded(child: Text(trigger, style: TextStyle(color: AppColors.textPrimary, fontSize: 12))),
                            ],
                          ),
                        ),
                    ],
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 16),

          // Match Logs Section
          if (dossier.matchLogs.isNotEmpty) ...[
            Text(
              'LIVE MATCH LOGS',
              style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 8),
            for (final log in dossier.matchLogs)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.subtle),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('vs ${log.opponent}', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14)),
                        Text('${log.competition} • ${log.date}', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: log.rating >= 8.0 ? AppColors.primary : AppColors.secondary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text('${log.rating}', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}
