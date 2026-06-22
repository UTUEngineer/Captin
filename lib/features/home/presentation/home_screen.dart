import 'package:captain/core/constants/app_constants.dart';
import 'package:captain/core/router/app_router.dart';
import 'package:captain/core/theme/app_colors.dart';
import 'package:captain/features/video_analysis/presentation/widgets/pending_analysis_banner.dart';
import 'package:captain/features/video_analysis/presentation/widgets/recent_analyses_section.dart';
import 'package:captain/shared/widgets/home_action_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.sizeOf(context).height -
                  MediaQuery.paddingOf(context).vertical -
                  64,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.pitchGreen,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.pitchLine, width: 1.5),
                  ),
                  child: const Icon(
                    Icons.sports_soccer,
                    size: 36,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  AppConstants.appName,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Plan, visualize, and share your tactical ideas.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                const PendingAnalysisBanner(),
                const RecentAnalysesSection(),
                const SizedBox(height: 16),
                HomeActionButton(
                  icon: Icons.draw_outlined,
                  label: 'New Tactical Board',
                  subtitle: 'Start a fresh tactical canvas',
                  onTap: () => context.push(AppRoutes.tacticalBoard),
                ),
                const SizedBox(height: 16),
                HomeActionButton(
                  icon: Icons.analytics_outlined,
                  label: 'Analyze Match Video',
                  subtitle: 'Upload or link a clip for player tracking',
                  onTap: () => context.push(AppRoutes.analyzeVideo),
                ),
                const SizedBox(height: 16),
                HomeActionButton(
                  icon: Icons.grid_view_rounded,
                  label: 'Formation Library',
                  subtitle: 'Browse preset formations and tactics',
                  onTap: () => context.push(AppRoutes.formationLibrary),
                ),
                const SizedBox(height: 16),
                HomeActionButton(
                  icon: Icons.folder_open_outlined,
                  label: 'Saved Boards',
                  subtitle: 'Open your saved tactical boards',
                  onTap: () => context.push(AppRoutes.savedBoards),
                ),
                const SizedBox(height: 16),
                HomeActionButton(
                  icon: Icons.auto_awesome,
                  label: 'AI Scouting Report',
                  subtitle: 'Generate an Arabic tactical report with Claude',
                  onTap: () => context.push(AppRoutes.scoutingReport),
                ),
                const SizedBox(height: 16),
                HomeActionButton(
                  icon: Icons.timeline_outlined,
                  label: 'Match Timeline',
                  subtitle: 'Annotate tactical moments across the match',
                  onTap: () => context.push(AppRoutes.matchTimeline),
                ),
                const SizedBox(height: 16),
                HomeActionButton(
                  icon: Icons.public,
                  label: 'Leagues & Live Data',
                  subtitle: 'Iraqi and world standings, fixtures, and teams',
                  onTap: () => context.push(AppRoutes.leagues),
                ),
                const SizedBox(height: 16),
                HomeActionButton(
                  icon: Icons.file_upload_outlined,
                  label: 'Export Hub',
                  subtitle: 'Share boards, reports, training plans, and GIFs',
                  onTap: () => context.push(AppRoutes.exportHub),
                ),
                const SizedBox(height: 16),
                HomeActionButton(
                  icon: Icons.settings_outlined,
                  label: 'Settings',
                  subtitle: 'Manage cached analysis data',
                  onTap: () => context.push(AppRoutes.settings),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
