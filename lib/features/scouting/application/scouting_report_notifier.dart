import 'package:captain/features/scouting/application/scouting_providers.dart';
import 'package:captain/features/scouting/data/scouting_report_repository.dart';
import 'package:captain/features/scouting/domain/match_analysis_data.dart';
import 'package:captain/features/scouting/domain/report_type.dart';
import 'package:captain/features/scouting/domain/scouting_report.dart';
import 'package:captain/features/scouting/domain/scouting_report_failure.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ScoutingReportState {
  const ScoutingReportState({
    this.matchData,
    this.selectedType = ReportType.matchSummary,
    this.report,
    this.isGenerating = false,
    this.isExporting = false,
    this.failure,
    this.statusMessage,
  });

  final MatchAnalysisData? matchData;
  final ReportType selectedType;
  final ScoutingReport? report;
  final bool isGenerating;
  final bool isExporting;
  final ScoutingReportFailure? failure;
  final String? statusMessage;

  ScoutingReportState copyWith({
    MatchAnalysisData? matchData,
    ReportType? selectedType,
    ScoutingReport? report,
    bool? isGenerating,
    bool? isExporting,
    ScoutingReportFailure? failure,
    String? statusMessage,
    bool clearFailure = false,
    bool clearReport = false,
  }) {
    return ScoutingReportState(
      matchData: matchData ?? this.matchData,
      selectedType: selectedType ?? this.selectedType,
      report: clearReport ? null : (report ?? this.report),
      isGenerating: isGenerating ?? this.isGenerating,
      isExporting: isExporting ?? this.isExporting,
      failure: clearFailure ? null : (failure ?? this.failure),
      statusMessage: statusMessage,
    );
  }
}

class ScoutingReportNotifier extends StateNotifier<ScoutingReportState> {
  ScoutingReportNotifier(this._repository) : super(const ScoutingReportState());

  final ScoutingReportRepository _repository;

  void setMatchData(MatchAnalysisData data) {
    state = state.copyWith(matchData: data, clearFailure: true, clearReport: true);
  }

  void selectReportType(ReportType type) {
    state = state.copyWith(selectedType: type, clearFailure: true);
  }

  Future<bool> generateReport() async {
    final data = state.matchData;
    if (data == null) return false;

    state = state.copyWith(
      isGenerating: true,
      clearFailure: true,
      clearReport: true,
      statusMessage: 'جاري إنشاء التقرير…',
    );

    final result = await _repository.generateReport(data, state.selectedType);
    if (result.report != null) {
      state = state.copyWith(
        isGenerating: false,
        report: result.report,
        statusMessage: null,
      );
      return true;
    }

    state = state.copyWith(
      isGenerating: false,
      failure: result.failure,
      statusMessage: null,
    );
    return false;
  }

  Future<ScoutingReport?> exportPdf() async {
    final report = state.report;
    if (report == null) return null;

    state = state.copyWith(isExporting: true, clearFailure: true);
    try {
      final exported = await _repository.exportReportPdf(report);
      state = state.copyWith(isExporting: false, report: exported);
      return exported;
    } catch (error) {
      state = state.copyWith(
        isExporting: false,
        failure: NetworkFailure(error.toString()),
      );
      return null;
    }
  }
}

final scoutingReportProvider =
    StateNotifierProvider.autoDispose<ScoutingReportNotifier, ScoutingReportState>(
  (ref) => ScoutingReportNotifier(ref.watch(scoutingReportRepositoryProvider)),
);
