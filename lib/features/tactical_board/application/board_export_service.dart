import 'dart:io';
import 'dart:ui' as ui;

import 'package:captain/features/training/application/training_notifier.dart';
import 'package:captain/features/tactical_board/application/tactical_board_notifier.dart';
import 'package:captain/features/tactical_board/presentation/widgets/exportable_pitch_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

const boardExportPixelRatio = 3.0;

class BoardExportService {
  Future<Uint8List> captureBoardImage({
    required BuildContext context,
    required TacticalBoardState boardState,
    required Size canvasSize,
    TrainingState? trainingState,
    double pixelRatio = boardExportPixelRatio,
  }) async {
    final repaintKey = GlobalKey();
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => Positioned(
        left: -20000,
        top: -20000,
        child: ExportablePitchView(
          repaintKey: repaintKey,
          boardState: boardState,
          constraints: canvasSize,
          trainingState: trainingState,
        ),
      ),
    );

    overlay.insert(entry);
    await Future<void>.delayed(Duration.zero);
    await WidgetsBinding.instance.endOfFrame;

    try {
      final boundary = repaintKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) {
        throw StateError('Could not find export boundary.');
      }

      final image = await boundary.toImage(pixelRatio: pixelRatio);
      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw StateError('Failed to encode PNG.');
      }
      return byteData.buffer.asUint8List();
    } finally {
      entry.remove();
    }
  }

  Future<Uint8List> buildPdf({
    required Uint8List boardImage,
    required String title,
    required DateTime date,
  }) async {
    final document = pw.Document();
    final formattedDate =
        '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

    document.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(28),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                title,
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                formattedDate,
                style: const pw.TextStyle(fontSize: 12),
              ),
              pw.SizedBox(height: 16),
              pw.Expanded(
                child: pw.Center(
                  child: pw.Image(
                    pw.MemoryImage(boardImage),
                    fit: pw.BoxFit.contain,
                  ),
                ),
              ),
              pw.SizedBox(height: 16),
              pw.Text(
                'Notes',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Container(
                height: 72,
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey400),
                ),
              ),
            ],
          );
        },
      ),
    );

    return Uint8List.fromList(await document.save());
  }

  Future<File> writeTempFile({
    required Uint8List bytes,
    required String filename,
  }) async {
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/$filename');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  Future<void> shareFile({
    required File file,
    required String subject,
  }) async {
    await Share.shareXFiles(
      [XFile(file.path)],
      subject: subject,
    );
  }

  Future<String> saveToDevice({
    required Uint8List bytes,
    required String filename,
    required bool isPdf,
  }) async {
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      if (isPdf) {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/$filename');
        await file.writeAsBytes(bytes, flush: true);
        return file.path;
      }

      await _ensureGalleryAccess();
      await Gal.putImageBytes(bytes, name: filename);
      return filename;
    }

    final directory =
        await getDownloadsDirectory() ?? await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$filename');
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  Future<void> _ensureGalleryAccess() async {
    if (await Gal.hasAccess()) return;

    await Gal.requestAccess();
    if (!await Gal.hasAccess()) {
      throw StateError(
        'Photo library access denied. Enable it in system settings to save images.',
      );
    }
  }
}

String exportFilename({
  required String baseName,
  required String extension,
}) {
  final sanitized = baseName
      .replaceAll(RegExp(r'[\\/:*?"<>|]'), '_')
      .replaceAll(RegExp(r'\s+'), '_')
      .toLowerCase();
  final stamp = DateTime.now().millisecondsSinceEpoch;
  return '${sanitized.isEmpty ? 'tactical_board' : sanitized}_$stamp.$extension';
}
