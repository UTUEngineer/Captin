import 'package:captain/core/theme/app_colors.dart';
import 'package:captain/features/tactical_board/application/board_export_service.dart';
import 'package:captain/features/tactical_board/application/tactical_board_notifier.dart';
import 'package:captain/features/training/application/training_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ExportAction {
  sharePng,
  sharePdf,
  savePng,
  savePdf,
}

class ExportBottomSheet extends ConsumerStatefulWidget {
  const ExportBottomSheet({
    super.key,
    required this.boardState,
    required this.canvasSize,
    required this.templateName,
  });

  final TacticalBoardState boardState;
  final Size canvasSize;
  final String templateName;

  static Future<void> show(
    BuildContext context, {
    required TacticalBoardState boardState,
    required Size canvasSize,
    required String templateName,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => ExportBottomSheet(
        boardState: boardState,
        canvasSize: canvasSize,
        templateName: templateName,
      ),
    );
  }

  @override
  ConsumerState<ExportBottomSheet> createState() =>
      _ExportBottomSheetState();
}

class _ExportBottomSheetState extends ConsumerState<ExportBottomSheet> {
  final _exportService = BoardExportService();
  var _isExporting = false;

  Future<void> _runExport(ExportAction action) async {
    if (_isExporting) return;
    setState(() => _isExporting = true);

    try {
      final trainingState = ref.read(trainingProvider);
      final pngBytes = await _exportService.captureBoardImage(
        context: context,
        boardState: widget.boardState,
        canvasSize: widget.canvasSize,
        trainingState: trainingState.isTrainingMode ? trainingState : null,
      );
      final now = DateTime.now();
      final title = widget.templateName;

      switch (action) {
        case ExportAction.sharePng:
          final file = await _exportService.writeTempFile(
            bytes: pngBytes,
            filename: exportFilename(baseName: title, extension: 'png'),
          );
          await _exportService.shareFile(file: file, subject: title);
        case ExportAction.savePng:
          final path = await _exportService.saveToDevice(
            bytes: pngBytes,
            filename: exportFilename(baseName: title, extension: 'png'),
            isPdf: false,
          );
          if (mounted) {
            _showMessage('Image saved to $path');
          }
        case ExportAction.sharePdf:
          final pdfBytes = await _exportService.buildPdf(
            boardImage: pngBytes,
            title: title,
            date: now,
          );
          final file = await _exportService.writeTempFile(
            bytes: pdfBytes,
            filename: exportFilename(baseName: title, extension: 'pdf'),
          );
          await _exportService.shareFile(file: file, subject: title);
        case ExportAction.savePdf:
          final pdfBytes = await _exportService.buildPdf(
            boardImage: pngBytes,
            title: title,
            date: now,
          );
          final path = await _exportService.saveToDevice(
            bytes: pdfBytes,
            filename: exportFilename(baseName: title, extension: 'pdf'),
            isPdf: true,
          );
          if (mounted) {
            _showMessage('PDF saved to $path');
          }
      }
    } catch (error) {
      if (mounted) {
        _showMessage('Export failed: $error');
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
            const SizedBox(height: 16),
            Text(
              'Export Board',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Share or save the current tactical board as PNG or PDF.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            if (_isExporting)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              )
            else ...[
              ListTile(
                leading: const Icon(Icons.ios_share_outlined),
                title: const Text('Share PNG'),
                onTap: () => _runExport(ExportAction.sharePng),
              ),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf_outlined),
                title: const Text('Share PDF'),
                onTap: () => _runExport(ExportAction.sharePdf),
              ),
              ListTile(
                leading: const Icon(Icons.download_outlined),
                title: const Text('Save PNG to device'),
                onTap: () => _runExport(ExportAction.savePng),
              ),
              ListTile(
                leading: const Icon(Icons.save_alt_outlined),
                title: const Text('Save PDF to device'),
                onTap: () => _runExport(ExportAction.savePdf),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
