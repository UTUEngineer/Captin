import 'dart:typed_data';

import 'package:captain/features/export/data/pdf_font_loader.dart';
import 'package:captain/features/export/domain/export_hub_context.dart';
import 'package:captain/features/scouting/domain/report_type.dart';
import 'package:captain/features/tactical_board/application/board_export_service.dart';
import 'package:captain/features/timeline/domain/timeline_event.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class ExportHubService {
  ExportHubService({
    BoardExportService? boardExportService,
    PdfFontLoader? fontLoader,
  })  : _boardExport = boardExportService ?? BoardExportService(),
        _fontLoader = fontLoader ?? PdfFontLoader();

  final BoardExportService _boardExport;
  final PdfFontLoader _fontLoader;

  Future<Uint8List> captureBoardImage({
    required BuildContext context,
    required ExportHubContext exportContext,
    ExportQuality quality = ExportQuality.standard,
  }) {
    return _boardExport.captureBoardImage(
      context: context,
      boardState: exportContext.boardState,
      canvasSize: exportContext.canvasSize,
      trainingState: exportContext.trainingState?.isTrainingMode == true
          ? exportContext.trainingState
          : null,
      pixelRatio: quality.pixelRatio,
    );
  }

  Future<Uint8List> exportBoardPdf({
    required BuildContext context,
    required ExportHubContext exportContext,
    ExportQuality quality = ExportQuality.standard,
  }) async {
    final png = await captureBoardImage(
      context: context,
      exportContext: exportContext,
      quality: quality,
    );
    return _boardExport.buildPdf(
      boardImage: png,
      title: exportContext.title,
      date: DateTime.now(),
    );
  }

  Future<Uint8List> exportTrainingPlanPdf({
    required BuildContext context,
    required ExportHubContext exportContext,
    ExportQuality quality = ExportQuality.standard,
  }) async {
    final training = exportContext.trainingState;
    if (training == null || !training.isTrainingMode) {
      throw StateError('Enable training mode to export a training plan.');
    }

    final png = await captureBoardImage(
      context: context,
      exportContext: exportContext,
      quality: quality,
    );
    final arabic = await _fontLoader.arabicStyle(fontSize: 16);
    final arabicBold = await _fontLoader.arabicStyle(
      fontSize: 20,
      fontWeight: pw.FontWeight.bold,
    );

    final document = pw.Document();
    document.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(28),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(training.sessionName, style: arabicBold),
              pw.SizedBox(height: 8),
              pw.Text(
                'عدد اللاعبين المقترح: ${training.props.length.clamp(4, 22)} • '
                'المسارات: ${training.paths.length} • '
                'الأدوات: ${training.props.length}',
                style: arabic,
                textDirection: pw.TextDirection.rtl,
              ),
              if (training.notes.isNotEmpty) ...[
                pw.SizedBox(height: 8),
                pw.Text(
                  training.notes,
                  style: arabic,
                  textDirection: pw.TextDirection.rtl,
                ),
              ],
              pw.SizedBox(height: 16),
              pw.Expanded(
                child: pw.Center(
                  child: pw.Image(
                    pw.MemoryImage(png),
                    fit: pw.BoxFit.contain,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    return Uint8List.fromList(await document.save());
  }

  Future<Uint8List> exportFullReportPdf({
    required BuildContext context,
    required ExportHubContext exportContext,
    ExportQuality quality = ExportQuality.standard,
  }) async {
    final png = await captureBoardImage(
      context: context,
      exportContext: exportContext,
      quality: quality,
    );
    final arabic = await _fontLoader.arabicStyle(fontSize: 14);
    final arabicBold = await _fontLoader.arabicStyle(
      fontSize: 18,
      fontWeight: pw.FontWeight.bold,
    );
    final document = pw.Document();
    final now = DateTime.now();

    document.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(exportContext.title, style: pw.TextStyle(fontSize: 22)),
            pw.SizedBox(height: 12),
            pw.Expanded(
              child: pw.Center(
                child: pw.Image(pw.MemoryImage(png), fit: pw.BoxFit.contain),
              ),
            ),
          ],
        ),
      ),
    );

    final report = exportContext.scoutingReport;
    if (report != null) {
      document.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (context) => [
            pw.Text(
              report.reportType.arabicLabel,
              style: arabicBold,
              textDirection: pw.TextDirection.rtl,
            ),
            pw.SizedBox(height: 12),
            pw.Text(
              report.arabicContent,
              style: arabic,
              textDirection: pw.TextDirection.rtl,
            ),
            if (report.keyFindings.isNotEmpty) ...[
              pw.SizedBox(height: 16),
              pw.Text('Key findings', style: arabicBold),
              for (final finding in report.keyFindings)
                pw.Bullet(text: finding, style: arabic),
            ],
          ],
        ),
      );
    }

    final analysis = exportContext.analysisResult;
    if (analysis != null && analysis.players.isNotEmpty) {
      document.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (context) => [
            pw.Text('Player statistics', style: pw.TextStyle(fontSize: 18)),
            pw.SizedBox(height: 12),
            pw.Table.fromTextArray(
              headers: const ['Track', 'Distance km', 'Sprints', 'Max km/h'],
              data: analysis.players
                  .map(
                    (player) => [
                      '${player.trackId}',
                      player.distanceKm.toStringAsFixed(2),
                      '${player.sprintCount}',
                      player.maxSpeedKmh.toStringAsFixed(1),
                    ],
                  )
                  .toList(),
            ),
          ],
        ),
      );
    }

    final training = exportContext.trainingState;
    if (training != null &&
        training.isTrainingMode &&
        (training.props.isNotEmpty || training.paths.isNotEmpty)) {
      document.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4.landscape,
          build: (context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                training.sessionName,
                style: arabicBold,
                textDirection: pw.TextDirection.rtl,
              ),
              pw.SizedBox(height: 12),
              pw.Expanded(
                child: pw.Center(
                  child: pw.Image(pw.MemoryImage(png), fit: pw.BoxFit.contain),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final timeline = exportContext.timeline;
    if (timeline != null && timeline.events.isNotEmpty) {
      document.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (context) => [
            pw.Text('Match timeline', style: pw.TextStyle(fontSize: 18)),
            pw.SizedBox(height: 12),
            pw.Table.fromTextArray(
              headers: const ['Time', 'Type', 'Description'],
              data: timeline.events
                  .map(
                    (event) => [
                      event.formattedTime,
                      event.type.arabicLabel,
                      event.description.isEmpty
                          ? (event.playerName ?? '')
                          : event.description,
                    ],
                  )
                  .toList(),
            ),
            pw.SizedBox(height: 8),
            pw.Text('Generated $now', style: const pw.TextStyle(fontSize: 10)),
          ],
        ),
      );
    }

    return Uint8List.fromList(await document.save());
  }
}
