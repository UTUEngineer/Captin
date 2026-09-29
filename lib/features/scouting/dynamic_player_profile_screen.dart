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
        backgroundColor: const Color(0xFF131926),
        elevation: 0,
        title: const Text(
          'DYNAMIC SCOUTING DOSSIER',
          style: TextStyle(
            letterSpacing: 1.5,
            fontWeight: FontWeight.w900,
            fontSize: 15,
            color: Colors.white,
          ),
        ),
      ),
      body: dossierAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFF00E676)),
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
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00E676),
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
              color: const Color(0xFF131926),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: const Color(0xFF00E676).withValues(alpha: 0.2),
                  child: Text(
                    '#${dossier.jerseyNumber}',
                    style: const TextStyle(color: Color(0xFF00E676), fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dossier.fullName,
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${dossier.clubName} • ${dossier.tacticalArchetype}',
                        style: const TextStyle(color: Colors.white60, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${dossier.nationality} • ${dossier.age} y/o • ${dossier.height} • ${dossier.marketValue}',
                        style: const TextStyle(color: Color(0xFF00E676), fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                CircleAvatar(
                  backgroundColor: const Color(0xFF00E676),
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
              color: const Color(0xFF131926),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'DYNAMIC FIFA RADAR',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    Text(
                      'SUPABASE PERSISTED',
                      style: TextStyle(color: Color(0xFF00E676), fontWeight: FontWeight.bold, fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 220,
                  child: CustomPaint(
                    painter: RadarChartPainter(
                      attributes: radar,
                      fillColor: const Color(0xFF00E676).withValues(alpha: 0.28),
                      outlineColor: const Color(0xFF00E676),
                      webColor: Colors.white12,
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
                  color: const Color(0xFF131926),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF00E676).withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.bolt, color: Color(0xFF00E676), size: 18),
                        SizedBox(width: 8),
                        Text(
                          'ON-DEVICE TACTICAL INTEL',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1.1),
                        ),
                        Spacer(),
                        Text(
                          '0ms Latency',
                          style: TextStyle(color: Color(0xFF00E676), fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      report.summary,
                      style: const TextStyle(color: Color(0xFF00E676), fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 12),
                    const Text('Tactical Strengths:', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    for (final s in report.strengths)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle, color: Color(0xFF00E676), size: 14),
                            const SizedBox(width: 6),
                            Expanded(child: Text(s, style: const TextStyle(color: Colors.white, fontSize: 12))),
                          ],
                        ),
                      ),
                    if (report.vulnerabilities.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      const Text('Pressing Triggers / Counter-measures:', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      for (final trigger in report.pressingTriggers)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: [
                              const Icon(Icons.warning_amber_rounded, color: Colors.orangeAccent, size: 14),
                              const SizedBox(width: 6),
                              Expanded(child: Text(trigger, style: const TextStyle(color: Colors.white, fontSize: 12))),
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
            const Text(
              'LIVE MATCH LOGS',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 8),
            for (final log in dossier.matchLogs)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF131926),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('vs ${log.opponent}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                        Text('${log.competition} • ${log.date}', style: const TextStyle(color: Colors.white38, fontSize: 11)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: log.rating >= 8.0 ? const Color(0xFF00E676) : const Color(0xFF2979FF),
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
