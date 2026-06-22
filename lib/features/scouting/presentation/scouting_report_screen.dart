import 'package:captain/core/theme/app_colors.dart';
import 'package:captain/core/services/haptic_service.dart';
import 'package:captain/core/services/haptic_patterns.dart';
import 'package:captain/features/scouting/application/scouting_providers.dart';
import 'package:captain/features/scouting/application/scouting_report_notifier.dart';
import 'package:captain/features/scouting/domain/match_analysis_data.dart';
import 'package:captain/features/scouting/domain/scouting_report_failure.dart';
import 'package:captain/features/scouting/domain/report_type.dart';
import 'package:captain/features/scouting/presentation/widgets/claude_api_key_dialog.dart';
import 'package:captain/features/scouting/presentation/widgets/key_findings_section.dart';
import 'package:captain/features/scouting/presentation/widgets/player_ratings_chart.dart';
import 'package:captain/features/scouting/presentation/widgets/report_type_selector.dart';
import 'package:captain/features/scouting/presentation/widgets/tactical_board_spinner.dart';
import 'package:captain/features/video_analysis/application/recent_analyses_providers.dart';
import 'package:captain/features/video_analysis/data/local_analysis_result_cache.dart';
import 'package:captain/features/video_analysis/domain/recent_video_analysis.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';

class ScoutingReportScreen extends ConsumerStatefulWidget {
  const ScoutingReportScreen({
    super.key,
    this.videoId,
  });

  final String? videoId;

  @override
  ConsumerState<ScoutingReportScreen> createState() =>
      _ScoutingReportScreenState();
}

class _ScoutingReportScreenState extends ConsumerState<ScoutingReportScreen> {
  var _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    if (_initialized) return;
    _initialized = true;

    final configured = await ref.read(claudeApiKeyConfiguredProvider.future);
    if (!configured && mounted) {
      await ClaudeApiKeyDialog.show(context);
    }

    if (widget.videoId != null) {
      await _loadVideo(widget.videoId!);
    }
  }

  Future<void> _loadVideo(String videoId) async {
    final cache = await ref.read(localAnalysisResultCacheProvider.future);
    final result = await cache.load(videoId);
    if (!mounted) return;

    if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No cached analysis found for this video.'),
        ),
      );
      return;
    }

    final recent = ref.read(recentAnalysesProvider).valueOrNull ?? const [];
    final label = recent
        .where((entry) => entry.videoId == videoId)
        .map((entry) => entry.label)
        .firstOrNull;

    ref.read(scoutingReportProvider.notifier).setMatchData(
          MatchAnalysisData.fromAnalysisResult(
            result,
            matchLabel: label,
          ),
        );
  }

  Future<void> _generateReport() async {
    final configured = await ref.read(claudeApiKeyConfiguredProvider.future);
    if (!configured && mounted) {
      final saved = await ClaudeApiKeyDialog.show(context);
      if (saved != true) return;
    }

    final success =
        await ref.read(scoutingReportProvider.notifier).generateReport();
    if (success && mounted) {
      await reportGeneratedHaptic(ref.read(hapticServiceProvider));
    }
  }

  Future<void> _exportPdf() async {
    final exported =
        await ref.read(scoutingReportProvider.notifier).exportPdf();
    final path = exported?.exportedPdfPath;
    if (path == null) return;
    await Share.shareXFiles([XFile(path)], text: 'Captain scouting report');
  }

  Future<void> _shareText() async {
    final report = ref.read(scoutingReportProvider).report;
    if (report == null) return;
    await Share.share(report.arabicContent);
  }

  String _failureMessage(ScoutingReportFailure failure) {
    return switch (failure) {
      MissingApiKeyFailure() => 'يرجى إعداد مفتاح Claude API أولاً.',
      RateLimitFailure() => 'تم تجاوز حد الطلبات. حاول مرة أخرى بعد قليل.',
      NetworkFailure(:final message) => 'خطأ في الشبكة: $message',
      ParseFailure(:final message) => 'تعذر قراءة رد التقرير: $message',
      ServerFailure(:final message) => 'خطأ من الخادم: $message',
    };
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(scoutingReportProvider);
    final recentAsync = ref.watch(recentAnalysesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'تقرير استكشاف',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Claude API key',
            onPressed: () => ClaudeApiKeyDialog.show(context),
            icon: const Icon(Icons.key_outlined),
          ),
        ],
      ),
      body: state.matchData == null
          ? _MatchPicker(
              recentAsync: recentAsync,
              onSelect: _loadVideo,
            )
          : _ReportBody(
              state: state,
              onTypeSelected:
                  ref.read(scoutingReportProvider.notifier).selectReportType,
              onGenerate: _generateReport,
              onExportPdf: _exportPdf,
              onShare: _shareText,
              failureMessage: state.failure == null
                  ? null
                  : _failureMessage(state.failure!),
            ),
    );
  }
}

class _MatchPicker extends StatelessWidget {
  const _MatchPicker({
    required this.recentAsync,
    required this.onSelect,
  });

  final AsyncValue<List<RecentVideoAnalysis>> recentAsync;
  final Future<void> Function(String videoId) onSelect;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'اختر تحليلاً مكتملاً',
            style: GoogleFonts.cairo(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 8),
          Text(
            'أكمل تحليل فيديو أولاً، ثم ارجع هنا لإنشاء تقرير AI.',
            style: GoogleFonts.cairo(color: AppColors.textSecondary),
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: recentAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('$error')),
              data: (entries) {
                if (entries.isEmpty) {
                  return Center(
                    child: Text(
                      'لا توجد تحليلات محفوظة بعد.',
                      style: GoogleFonts.cairo(color: AppColors.textSecondary),
                      textDirection: TextDirection.rtl,
                    ),
                  );
                }
                return ListView.separated(
                  itemCount: entries.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    return ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: AppColors.border),
                      ),
                      tileColor: AppColors.surfaceElevated,
                      title: Text(entry.label),
                      subtitle: Text(entry.videoId),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => onSelect(entry.videoId),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportBody extends StatelessWidget {
  const _ReportBody({
    required this.state,
    required this.onTypeSelected,
    required this.onGenerate,
    required this.onExportPdf,
    required this.onShare,
    required this.failureMessage,
  });

  final ScoutingReportState state;
  final ValueChanged<ReportType> onTypeSelected;
  final Future<void> Function() onGenerate;
  final Future<void> Function() onExportPdf;
  final Future<void> Function() onShare;
  final String? failureMessage;

  @override
  Widget build(BuildContext context) {
    if (state.isGenerating) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const TacticalBoardSpinner(),
            const SizedBox(height: 20),
            Text(
              state.statusMessage ?? 'جاري إنشاء التقرير…',
              style: GoogleFonts.cairo(color: AppColors.textSecondary),
              textDirection: TextDirection.rtl,
            ),
          ],
        ),
      );
    }

    final report = state.report;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: ReportTypeSelector(
            selectedType: state.selectedType,
            onSelected: onTypeSelected,
          ),
        ),
        if (failureMessage != null)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Material(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      failureMessage!,
                      style: GoogleFonts.cairo(color: AppColors.accentRed),
                      textDirection: TextDirection.rtl,
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: onGenerate,
                      child: const Text('إعادة المحاولة'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        Expanded(
          child: report == null
              ? Center(
                  child: FilledButton.icon(
                    onPressed: onGenerate,
                    icon: const Icon(Icons.auto_awesome),
                    label: Text(
                      'إنشاء التقرير',
                      style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        report.arabicContent,
                        style: GoogleFonts.cairo(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          height: 1.7,
                        ),
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.right,
                      ),
                      const SizedBox(height: 24),
                      KeyFindingsSection(findings: report.keyFindings),
                      const SizedBox(height: 24),
                      PlayerRatingsChart(ratings: report.playerRatings),
                      if (report.tacticalNotes.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        Text(
                          'ملاحظات تكتيكية',
                          style: GoogleFonts.cairo(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          report.tacticalNotes,
                          style: GoogleFonts.cairo(color: AppColors.textSecondary),
                          textDirection: TextDirection.rtl,
                          textAlign: TextAlign.right,
                        ),
                      ],
                    ],
                  ),
                ),
        ),
        if (report != null)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: state.isExporting ? null : onExportPdf,
                      icon: state.isExporting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.picture_as_pdf_outlined),
                      label: const Text('تصدير PDF'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: onShare,
                      icon: const Icon(Icons.share_outlined),
                      label: const Text('مشاركة'),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    if (!iterator.moveNext()) return null;
    return iterator.current;
  }
}
