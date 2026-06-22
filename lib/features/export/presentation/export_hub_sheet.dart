import 'dart:typed_data';

import 'package:captain/core/theme/app_colors.dart';
import 'package:captain/features/export/application/export_hub_providers.dart';
import 'package:captain/features/export/domain/export_hub_context.dart';
import 'package:captain/features/export/presentation/widgets/share_link_sheet.dart';
import 'package:captain/features/scouting/application/scouting_report_notifier.dart';
import 'package:captain/features/settings/application/app_preferences_notifier.dart';
import 'package:captain/features/tactical_board/application/board_export_service.dart';
import 'package:captain/features/tactical_board/application/tactical_board_notifier.dart';
import 'package:captain/features/timeline/application/timeline_providers.dart';
import 'package:captain/features/training/application/training_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class ExportHubSheet extends ConsumerStatefulWidget {
  const ExportHubSheet({
    super.key,
    required this.boardState,
    required this.canvasSize,
    required this.title,
    this.fullScreen = false,
  });

  final TacticalBoardState boardState;
  final Size canvasSize;
  final String title;
  final bool fullScreen;

  static Future<void> show(
    BuildContext context, {
    required TacticalBoardState boardState,
    required Size canvasSize,
    required String title,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: ExportHubSheet(
          boardState: boardState,
          canvasSize: canvasSize,
          title: title,
        ),
      ),
    );
  }

  @override
  ConsumerState<ExportHubSheet> createState() => _ExportHubSheetState();
}

class _ExportHubSheetState extends ConsumerState<ExportHubSheet>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  var _quality = ExportQuality.standard;
  var _format = ExportFileFormat.png;
  var _isExporting = false;
  var _gifProgress = 0;
  var _gifTotal = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: ExportTab.values.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _format = switch (ExportTab.values[_tabController.index]) {
            ExportTab.videoClip => ExportFileFormat.gif,
            ExportTab.fullReport || ExportTab.trainingPlan => ExportFileFormat.pdf,
            ExportTab.boardSnapshot => ExportFileFormat.png,
          };
        });
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prefs = ref.read(appPreferencesProvider).value;
      if (prefs != null && mounted) {
        setState(() {
          _quality = prefs.defaultExportQuality;
          _format = prefs.defaultExportFormat;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  ExportHubContext _buildContext() {
    final scouting = ref.read(scoutingReportProvider);
    final timeline = ref.read(timelineControllerProvider(defaultMatchId));
    return ExportHubContext(
      boardState: widget.boardState,
      canvasSize: widget.canvasSize,
      title: widget.title,
      trainingState: ref.read(trainingProvider),
      scoutingReport: scouting.report,
      timeline: timeline.timeline,
    );
  }

  Future<void> _runExport({required bool share}) async {
    if (_isExporting) return;
    setState(() {
      _isExporting = true;
      _gifProgress = 0;
      _gifTotal = 0;
    });

    try {
      final exportContext = _buildContext();
      final hub = ref.read(exportHubServiceProvider);
      final boardExport = ref.read(boardExportServiceProvider);
      final tab = ExportTab.values[_tabController.index];
      final baseName = widget.title;
      late Uint8List bytes;
      late String extension;
      late bool isPdf;

      switch (tab) {
        case ExportTab.boardSnapshot:
          if (_format == ExportFileFormat.pdf) {
            bytes = await hub.exportBoardPdf(
              context: context,
              exportContext: exportContext,
              quality: _quality,
            );
            extension = 'pdf';
            isPdf = true;
          } else {
            bytes = await hub.captureBoardImage(
              context: context,
              exportContext: exportContext,
              quality: _quality,
            );
            extension = 'png';
            isPdf = false;
          }
        case ExportTab.fullReport:
          bytes = await hub.exportFullReportPdf(
            context: context,
            exportContext: exportContext,
            quality: _quality,
          );
          extension = 'pdf';
          isPdf = true;
        case ExportTab.trainingPlan:
          bytes = await hub.exportTrainingPlanPdf(
            context: context,
            exportContext: exportContext,
            quality: _quality,
          );
          extension = 'pdf';
          isPdf = true;
        case ExportTab.videoClip:
          final gifService = ref.read(gifExportServiceProvider);
          bytes = await gifService.buildBoardGif(
            context: context,
            boardState: widget.boardState,
            canvasSize: widget.canvasSize,
            trainingState: exportContext.trainingState?.isTrainingMode == true
                ? exportContext.trainingState
                : null,
            onProgress: (completed, total) {
              if (mounted) {
                setState(() {
                  _gifProgress = completed;
                  _gifTotal = total;
                });
              }
            },
          );
          extension = 'gif';
          isPdf = false;
      }

      final filename = exportFilename(baseName: baseName, extension: extension);
      if (share) {
        final file = await boardExport.writeTempFile(
          bytes: bytes,
          filename: filename,
        );
        await boardExport.shareFile(file: file, subject: baseName);
      } else {
        final path = await boardExport.saveToDevice(
          bytes: bytes,
          filename: filename,
          isPdf: isPdf,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Saved to $path')),
          );
        }
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  void _openShareLink() {
    final codec = ref.read(boardStateCodecProvider);
    final link = codec.encodeShareLink(_buildContext().toBoardTemplate());
    ShareLinkSheet.show(context, link: link);
  }

  @override
  Widget build(BuildContext context) {
    final tab = ExportTab.values[_tabController.index];
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!widget.fullScreen) ...[
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        ],
        Padding(
          padding: EdgeInsets.fromLTRB(20, widget.fullScreen ? 0 : 16, 20, 0),
          child: Text(
            'Export Hub',
            style: GoogleFonts.cairo(
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            for (final item in ExportTab.values) Tab(text: item.label),
          ],
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (tab != ExportTab.videoClip) ...[
                  Text('Quality', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  SegmentedButton<ExportQuality>(
                    segments: [
                      for (final quality in ExportQuality.values)
                        ButtonSegment(
                          value: quality,
                          label: Text(quality.label),
                        ),
                    ],
                    selected: {_quality},
                    onSelectionChanged: (value) {
                      setState(() => _quality = value.first);
                    },
                  ),
                  const SizedBox(height: 16),
                ],
                if (tab == ExportTab.boardSnapshot) ...[
                  Text('Format', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  SegmentedButton<ExportFileFormat>(
                    segments: const [
                      ButtonSegment(
                        value: ExportFileFormat.png,
                        label: Text('PNG'),
                      ),
                      ButtonSegment(
                        value: ExportFileFormat.pdf,
                        label: Text('PDF'),
                      ),
                    ],
                    selected: {_format},
                    onSelectionChanged: (value) {
                      setState(() => _format = value.first);
                    },
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: _isExporting ? null : _openShareLink,
                    icon: const Icon(Icons.qr_code_2_outlined),
                    label: const Text('Share board link + QR'),
                  ),
                  const SizedBox(height: 16),
                ],
                if (tab == ExportTab.videoClip)
                  Text(
                    'Creates a 5-second GIF at 10fps from animated board frames.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                if (tab == ExportTab.fullReport)
                  Text(
                    'Combines board, scouting report, stats, training, and timeline when available.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                if (tab == ExportTab.trainingPlan)
                  Text(
                    'Requires training mode with props or paths on the board.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                const Spacer(),
                if (_isExporting && tab == ExportTab.videoClip)
                  Column(
                    children: [
                      LinearProgressIndicator(
                        value: _gifTotal == 0 ? null : _gifProgress / _gifTotal,
                      ),
                      const SizedBox(height: 8),
                      Text('Encoding frame $_gifProgress / $_gifTotal'),
                      const SizedBox(height: 16),
                    ],
                  )
                else if (_isExporting)
                  const Center(child: CircularProgressIndicator())
                else
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _runExport(share: true),
                          icon: const Icon(Icons.ios_share_outlined),
                          label: const Text('Share'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () => _runExport(share: false),
                          icon: const Icon(Icons.download_outlined),
                          label: const Text('Save'),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ],
    );

    if (widget.fullScreen) {
      return content;
    }

    return SafeArea(
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.72,
        child: content,
      ),
    );
  }
}
