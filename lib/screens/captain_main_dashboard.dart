import 'package:flutter/material.dart';
import '../services/tactical_session_service.dart';
import 'virtual_playground_screen.dart';
import 'video_match_analysis_screen.dart';
import 'league_scouting_screen.dart';

class CaptainMainDashboard extends StatefulWidget {
  const CaptainMainDashboard({super.key});

  @override
  State<CaptainMainDashboard> createState() => _CaptainMainDashboardState();
}

class _CaptainMainDashboardState extends State<CaptainMainDashboard> {
  final _sessionService = TacticalSessionService.instance;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _sessionService,
      builder: (context, _) {
        final currentSectionIndex = _sessionService.activeTabIndex;

        // The 3 Core Sections / Hubs of Captain
        final List<Widget> sections = [
          const VirtualPlaygroundScreen(), // Section 1: 3D Tactical Playground
          const VideoMatchAnalysisScreen(), // Section 2: Video vs 3D Synchronization
          const LeagueScoutingScreen(),     // Section 3: League Fixtures & AI Player Scouting
        ];

        return Scaffold(
          backgroundColor: const Color(0xFF070B14),
          body: IndexedStack(
            index: currentSectionIndex,
            children: sections,
          ),
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              color: Color(0xFF0F172A),
              border: Border(top: BorderSide(color: Colors.white10, width: 1)),
            ),
            child: NavigationBar(
              backgroundColor: Colors.transparent,
              indicatorColor: const Color(0xFF10B981).withValues(alpha: 0.2),
              selectedIndex: currentSectionIndex,
              onDestinationSelected: (index) => _sessionService.switchTab(index),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.sports_soccer_outlined, color: Colors.white60),
                  selectedIcon: Icon(Icons.sports_soccer, color: Color(0xFF10B981)),
                  label: '3D Playground',
                ),
                NavigationDestination(
                  icon: Icon(Icons.sync_alt_outlined, color: Colors.white60),
                  selectedIcon: Icon(Icons.sync_alt, color: Color(0xFF10B981)),
                  label: 'Video vs 3D Sync',
                ),
                NavigationDestination(
                  icon: Icon(Icons.analytics_outlined, color: Colors.white60),
                  selectedIcon: Icon(Icons.analytics, color: Color(0xFF10B981)),
                  label: 'Scouting & Leagues',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
