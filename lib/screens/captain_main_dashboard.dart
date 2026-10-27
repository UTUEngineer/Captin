import 'package:captain/core/theme/app_colors.dart';
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
          backgroundColor: AppColors.background,
          body: IndexedStack(
            index: currentSectionIndex,
            children: sections,
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: AppColors.background,
              border: Border(top: BorderSide(color: AppColors.subtle, width: 1)),
            ),
            child: NavigationBar(
              backgroundColor: Colors.transparent,
              indicatorColor: AppColors.primary.withValues(alpha: 0.2),
              selectedIndex: currentSectionIndex,
              onDestinationSelected: (index) => _sessionService.switchTab(index),
              destinations: [
                NavigationDestination(
                  icon: Icon(Icons.sports_soccer_outlined, color: AppColors.textSecondary),
                  selectedIcon: Icon(Icons.sports_soccer, color: AppColors.primary),
                  label: '3D Playground',
                ),
                NavigationDestination(
                  icon: Icon(Icons.sync_alt_outlined, color: AppColors.textSecondary),
                  selectedIcon: Icon(Icons.sync_alt, color: AppColors.primary),
                  label: 'Video vs 3D Sync',
                ),
                NavigationDestination(
                  icon: Icon(Icons.analytics_outlined, color: AppColors.textSecondary),
                  selectedIcon: Icon(Icons.analytics, color: AppColors.primary),
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
