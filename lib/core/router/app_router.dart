import 'package:captain/features/leagues/presentation/league_detail_screen.dart';
import 'package:captain/features/leagues/presentation/leagues_screen.dart';
import 'package:captain/features/leagues/domain/league.dart';
import 'package:captain/features/export/presentation/export_hub_screen.dart';
import 'package:captain/features/onboarding/presentation/onboarding_screen.dart';
import 'package:captain/features/formations/domain/tactic_board_template.dart';

import 'package:captain/features/formations/presentation/formation_library_screen.dart';

import 'package:captain/features/home/presentation/home_screen.dart';

import 'package:captain/features/home/presentation/splash_screen.dart';

import 'package:captain/features/scouting/presentation/scouting_report_screen.dart';
import 'package:captain/features/settings/presentation/settings_screen.dart';

import 'package:captain/features/tactical_board/presentation/tactical_board_screen.dart';

import 'package:captain/features/training/presentation/drill_templates_screen.dart';
import 'package:captain/features/timeline/presentation/timeline_screen.dart';
import 'package:captain/features/video_analysis/domain/video_processing_args.dart';

import 'package:captain/features/video_analysis/presentation/analyze_video_screen.dart';

import 'package:captain/features/video_analysis/presentation/video_analysis_result_screen.dart';

import 'package:captain/features/video_analysis/presentation/video_calibration_screen.dart';

import 'package:captain/features/video_analysis/presentation/video_processing_screen.dart';

import 'package:captain/screens/captain_main_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

abstract final class AppRoutes {

  static const splash = '/';

  static const home = '/home';

  static const dashboard = '/dashboard';

  static const tacticalBoard = '/tactical-board';

  static const formationLibrary = '/formation-library';

  static const savedBoards = '/saved-boards';

  static const settings = '/settings';

  static const analyzeVideo = '/analyze-video';

  static const analyzeVideoProcessing = '/analyze-video/processing';

  static const scoutingReport = '/scouting-report';

  static const matchTimeline = '/match-timeline';

  static const trainingTemplates = '/training-templates';

  static const exportHub = '/export-hub';

  static const leagues = '/leagues';

  static const onboarding = '/onboarding';

  static String scoutingReportForVideo(String videoId) =>
      '/scouting-report?videoId=$videoId';



  static String videoCalibration(String videoId) =>

      '/analyze-video/$videoId/calibrate';



  static String videoResult(String videoId) =>

      '/analyze-video/$videoId/result';

  static String leagueDetail(int leagueId) => '/leagues/$leagueId';

}



final GoRouter appRouter = GoRouter(

  initialLocation: AppRoutes.splash,

  routes: [

    GoRoute(

      path: AppRoutes.splash,

      builder: (context, state) => const SplashScreen(),

    ),

    GoRoute(

      path: AppRoutes.home,

      builder: (context, state) => const HomeScreen(),

    ),

    GoRoute(

      path: AppRoutes.dashboard,

      builder: (context, state) => const CaptainMainDashboard(),

    ),

    GoRoute(

      path: AppRoutes.tacticalBoard,

      builder: (context, state) => TacticalBoardScreen(

        initialTemplate: state.extra as TacticBoardTemplate?,

      ),

    ),

    GoRoute(

      path: AppRoutes.formationLibrary,

      builder: (context, state) => const FormationLibraryScreen(),

    ),

    GoRoute(

      path: AppRoutes.savedBoards,

      builder: (context, state) => const FormationLibraryScreen(savedOnly: true),

    ),

    GoRoute(

      path: AppRoutes.settings,

      builder: (context, state) => const SettingsScreen(),

    ),

    GoRoute(
      path: AppRoutes.scoutingReport,
      builder: (context, state) => ScoutingReportScreen(
        videoId: state.uri.queryParameters['videoId'],
      ),
    ),

    GoRoute(
      path: AppRoutes.matchTimeline,
      builder: (context, state) => const TimelineScreen(),
    ),

    GoRoute(
      path: AppRoutes.trainingTemplates,
      builder: (context, state) => const DrillTemplatesScreen(),
    ),

    GoRoute(
      path: AppRoutes.onboarding,
      builder: (context, state) => const OnboardingScreen(),
    ),

    GoRoute(
      path: AppRoutes.exportHub,
      builder: (context, state) => const ExportHubScreen(),
    ),

    GoRoute(
      path: AppRoutes.leagues,
      builder: (context, state) => const LeaguesScreen(),
      routes: [
        GoRoute(
          path: ':leagueId',
          builder: (context, state) {
            final league = state.extra as League?;
            if (league != null) {
              return LeagueDetailScreen(league: league);
            }
            final leagueId = int.tryParse(state.pathParameters['leagueId'] ?? '');
            if (leagueId == null) {
              return const Scaffold(
                body: Center(child: Text('League not found')),
              );
            }
            return LeagueByIdScreen(leagueId: leagueId);
          },
        ),
      ],
    ),

    GoRoute(

      path: AppRoutes.analyzeVideo,

      builder: (context, state) => const AnalyzeVideoScreen(),

      routes: [

        GoRoute(

          path: 'processing',

          builder: (context, state) => VideoProcessingScreen(

            args: state.extra! as VideoProcessingArgs,

          ),

        ),

        GoRoute(

          path: ':videoId/calibrate',

          builder: (context, state) => VideoCalibrationScreen(

            videoId: state.pathParameters['videoId']!,

          ),

        ),

        GoRoute(

          path: ':videoId/result',

          builder: (context, state) => VideoAnalysisResultScreen(

            videoId: state.pathParameters['videoId']!,

          ),

        ),

      ],

    ),

  ],

);


