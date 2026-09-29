import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:captain/core/router/app_router.dart';
import '../widgets/system_health_check_dialog.dart';

class CaptainHubScreen extends StatelessWidget {
  const CaptainHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 700;

    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF00E676).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.sports_soccer, color: Color(0xFF00E676)),
            ),
            const SizedBox(width: 12),
            const Text(
              'CAPTAIN TACTICAL SUITE',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.health_and_safety_rounded, color: Color(0xFF06B6D4)),
            tooltip: 'System Health Diagnostics',
            onPressed: () => SystemHealthCheckDialog.show(context),
          ),
          IconButton(
            icon: const Icon(Icons.stadium, color: Color(0xFF00E676)),
            tooltip: '3D Stadium Playground Login',
            onPressed: () => context.push(AppRoutes.stadiumLogin),
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white70),
            tooltip: 'Settings',
            onPressed: () => context.push(AppRoutes.settings),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tactical Command Center',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Select operational mode to proceed',
                style: TextStyle(fontSize: 14, color: Colors.grey[400]),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: isTablet
                    ? Row(
                        children: [
                          Expanded(child: _buildTacticsCard(context)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildPlaygroundCard(context)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildScoutingCard(context)),
                        ],
                      )
                    : ListView(
                        children: [
                          _buildTacticsCard(context),
                          const SizedBox(height: 16),
                          _buildPlaygroundCard(context),
                          const SizedBox(height: 16),
                          _buildScoutingCard(context),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTacticsCard(BuildContext context) {
    return _HubLauncherCard(
      badge: '01',
      title: 'Tactics & Whiteboard',
      subtitle: '2D Board, Drills, Formations & Video Calibration Sync',
      icon: Icons.architecture_rounded,
      accentColor: const Color(0xFF2979FF),
      features: const [
        'Bezier Drill Curves & Training Props',
        'Frame-Synced Match Video to Pitch',
        'Passing Corridors & Heatmap Engine',
      ],
      onTap: () => context.push(AppRoutes.tactics),
    );
  }

  Widget _buildPlaygroundCard(BuildContext context) {
    return _HubLauncherCard(
      badge: '02',
      title: '3D Virtual Playground',
      subtitle: 'First-Person POV, 3D Pitch Orbit & Keyframe Sequences',
      icon: Icons.view_in_ar_rounded,
      accentColor: const Color(0xFF00E676),
      features: const [
        'Be-The-Player (Eye-Level 1.75m POV)',
        'Free 360° Pitch Orbit, Pan & Tilt',
        'Multi-Step Animated Keyframe Engine',
      ],
      onTap: () => context.push(AppRoutes.playground3d),
    );
  }

  Widget _buildScoutingCard(BuildContext context) {
    return _HubLauncherCard(
      badge: '03',
      title: 'Leagues & Player Intel',
      subtitle: 'Global Competitions, Player Profiles & Claude AI Reports',
      icon: Icons.groups_rounded,
      accentColor: const Color(0xFFFF9100),
      features: const [
        'Iraq Stars & European Leagues Data',
        'Player Biometrics, Radar & Heatmaps',
        'UEFA-Grade Claude 3.5 AI Scouting',
      ],
      onTap: () => context.push(AppRoutes.leaguesScouting),
    );
  }
}

class _HubLauncherCard extends StatelessWidget {
  final String badge;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final List<String> features;
  final VoidCallback onTap;

  const _HubLauncherCard({
    required this.badge,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.features,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: accentColor.withValues(alpha: 0.2),
        highlightColor: accentColor.withValues(alpha: 0.08),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF161B22),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'SECTION $badge',
                      style: TextStyle(
                        color: accentColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  Icon(icon, color: accentColor, size: 28),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: TextStyle(color: Colors.grey[400], fontSize: 13, height: 1.3),
              ),
              const SizedBox(height: 14),
              const Divider(color: Color(0xFF30363D), height: 1),
              const SizedBox(height: 12),
              Column(
                children: features
                    .map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle_outline, size: 14, color: accentColor),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                item,
                                style: const TextStyle(color: Color(0xFFC9D1D9), fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Launch Hub',
                      style: TextStyle(
                        color: accentColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_forward_rounded, size: 16, color: accentColor),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
