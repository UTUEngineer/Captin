import 'package:captain/features/formations/domain/tactic_board_template.dart';
import 'package:captain/features/scouting/domain/scouting_report.dart';
import 'package:captain/features/tactical_board/application/tactical_board_notifier.dart';
import 'package:captain/features/timeline/domain/match_timeline.dart';
import 'package:captain/features/training/application/training_notifier.dart';
import 'package:captain/features/video_analysis/domain/analysis_result.dart';
import 'package:flutter/material.dart';

enum ExportTab {
  boardSnapshot('Board Snapshot'),
  fullReport('Full Report'),
  trainingPlan('Training Plan'),
  videoClip('Video Clip');

  const ExportTab(this.label);
  final String label;
}

enum ExportFileFormat {
  png('PNG Image'),
  pdf('PDF Document'),
  gif('Animated GIF');

  const ExportFileFormat(this.label);
  final String label;
}

enum ExportQuality {
  draft('Draft', pixelRatio: 1.5),
  standard('Standard', pixelRatio: 2.5),
  print('Print', pixelRatio: 3.5);

  const ExportQuality(this.label, {required this.pixelRatio});
  final String label;
  final double pixelRatio;
}

class ExportHubContext {
  const ExportHubContext({
    required this.boardState,
    required this.canvasSize,
    required this.title,
    this.trainingState,
    this.scoutingReport,
    this.timeline,
    this.analysisResult,
  });

  final TacticalBoardState boardState;
  final Size canvasSize;
  final String title;
  final TrainingState? trainingState;
  final ScoutingReport? scoutingReport;
  final MatchTimeline? timeline;
  final AnalysisResult? analysisResult;

  TacticBoardTemplate toBoardTemplate() {
    return TacticBoardTemplate(
      id: 'export-${DateTime.now().millisecondsSinceEpoch}',
      name: title,
      updatedAt: DateTime.now(),
      formation: boardState.selectedFormation,
      orientation: boardState.orientation,
      pitchStyle: boardState.pitchStyle,
      players: boardState.players.map((player) => player.copyWith()).toList(),
      arrows: boardState.arrows.map((arrow) => arrow.copyWith()).toList(),
      zones: boardState.zones.map((zone) => zone.copyWith()).toList(),
      highlights:
          boardState.highlights.map((circle) => circle.copyWith()).toList(),
      textAnnotations: boardState.textAnnotations
          .map((note) => note.copyWith())
          .toList(),
    );
  }
}
