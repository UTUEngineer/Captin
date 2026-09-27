import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../services/tactical_session_service.dart';

class PdfTacticalReportService {
  PdfTacticalReportService._();
  static final PdfTacticalReportService instance = PdfTacticalReportService._();

  /// توليد وتصدير تقرير تكتيكي كامل
  Future<void> exportAndShareReport({
    required String matchTitle,
    required String opponentTeam,
    required String formation,
    required List<TacticalPlayerModel> players,
    required Map<String, dynamic> aiReport,
    Uint8List? pitchSnapshotImage, // لقطة شاشة من الـ 3D Canvas إذا توفرت
  }) async {
    final doc = pw.Document();

    pw.Font ttfRegular;
    pw.Font ttfBold;

    try {
      final fontData = await rootBundle.load("assets/fonts/Cairo-Regular.ttf");
      final boldFontData = await rootBundle.load("assets/fonts/Cairo-Bold.ttf");
      ttfRegular = pw.Font.ttf(fontData);
      ttfBold = pw.Font.ttf(boldFontData);
    } catch (_) {
      ttfRegular = await PdfGoogleFonts.cairoMedium();
      ttfBold = await PdfGoogleFonts.cairoBold();
    }

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(base: ttfRegular, bold: ttfBold),
        build: (pw.Context context) {
          return pw.Directionality(
            textDirection: pw.TextDirection.rtl,
            child: pw.Container(
              padding: const pw.EdgeInsets.all(24),
              decoration: const pw.BoxDecoration(
                color: PdfColors.white,
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // 1. Header & Title Bar
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'كابتن - التقرير التكتيكي للمباراة',
                            style: pw.TextStyle(
                              font: ttfBold,
                              fontSize: 20,
                              color: PdfColor.fromHex('#0F172A'),
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            'المباراة: $matchTitle | التشكيلة: $formation',
                            style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
                          ),
                        ],
                      ),
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: pw.BoxDecoration(
                          color: PdfColor.fromHex('#10B981'),
                          borderRadius: pw.BorderRadius.circular(6),
                        ),
                        child: pw.Text(
                          'سري وخاص بالفريق',
                          style: pw.TextStyle(font: ttfBold, color: PdfColors.white, fontSize: 10),
                        ),
                      ),
                    ],
                  ),
                  pw.Divider(color: PdfColors.grey300, thickness: 1, height: 20),

                  // 2. Tactical Pitch Visualization (Vector Pitch or Screenshot)
                  pw.Container(
                    height: 220,
                    width: double.infinity,
                    decoration: pw.BoxDecoration(
                      color: PdfColor.fromHex('#1B4332'),
                      borderRadius: pw.BorderRadius.circular(8),
                      border: pw.Border.all(color: PdfColor.fromHex('#2D6A4F'), width: 2),
                    ),
                    child: pitchSnapshotImage != null
                        ? pw.ClipRRect(
                            horizontalRadius: 8,
                            verticalRadius: 8,
                            child: pw.Image(pw.MemoryImage(pitchSnapshotImage), fit: pw.BoxFit.cover),
                          )
                        : pw.CustomPaint(
                            painter: (PdfGraphics canvas, PdfPoint size) {
                              _drawTacticalPitch(canvas, size, players, ttfBold);
                            },
                          ),
                  ),
                  pw.SizedBox(height: 16),

                  // 3. AI Scouting Insights Grid
                  pw.Text(
                    'تحليل الذكاء الاصطناعي ونقاط الاستهداف التكتيكي (Claude AI):',
                    style: pw.TextStyle(font: ttfBold, fontSize: 13, color: PdfColor.fromHex('#0F172A')),
                  ),
                  pw.SizedBox(height: 8),

                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // ثغرة الخصم
                      pw.Expanded(
                        child: _buildInsightCard(
                          title: 'الثغرة الدفاعية المستهدفة',
                          content: aiReport['team_vulnerability'] ?? 'الاستفادة من المساحات عند التراجع البطيء للأظهرة.',
                          borderColor: PdfColor.fromHex('#EF4444'),
                          bgColor: PdfColor.fromHex('#FEF2F2'),
                          fontBold: ttfBold,
                        ),
                      ),
                      pw.SizedBox(width: 12),
                      // نقطة قوة الخصم
                      pw.Expanded(
                        child: _buildInsightCard(
                          title: 'مصدر الخطورة الأساسي',
                          content: aiReport['team_strength'] ?? 'البناء المباشر والكرات الطولية خلف خط الدفاع.',
                          borderColor: PdfColor.fromHex('#F59E0B'),
                          bgColor: PdfColor.fromHex('#FFFBEB'),
                          fontBold: ttfBold,
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 12),

                  // الخطة المقترحة والضغط العالي
                  _buildInsightCard(
                    title: 'استراتيجية المدرب والخطة المضادة المقترحة',
                    content: "${aiReport['recommended_counter_strategy'] ?? ''}\n"
                        "اللاعب المستهدف بالضغط المباشر: ${aiReport['key_player_to_press']?['name'] ?? ''} - ${aiReport['key_player_to_press']?['reason'] ?? ''}",
                    borderColor: PdfColor.fromHex('#10B981'),
                    bgColor: PdfColor.fromHex('#ECFDF5'),
                    fontBold: ttfBold,
                  ),

                  pw.Spacer(),

                  // Footer Note
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('تم إنشاء التقرير بواسطة منظومة Captain التكتيكية 3D', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey500)),
                      pw.Text('تاريخ الإعداد: ${DateTime.now().toString().split(' ')[0]}', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey500)),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );

    // معاينة أو طباعة ومشاركة الملف
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
      name: 'Captain_Report_${opponentTeam.replaceAll(' ', '_')}.pdf',
    );
  }

  // بطاقة مخصصة لتنسيق نصوص الذكاء الاصطناعي داخل الملف
  static pw.Widget _buildInsightCard({
    required String title,
    required String content,
    required PdfColor borderColor,
    required PdfColor bgColor,
    required pw.Font fontBold,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: bgColor,
        borderRadius: pw.BorderRadius.circular(6),
        border: pw.Border.all(color: borderColor, width: 1),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(title, style: pw.TextStyle(font: fontBold, fontSize: 10, color: borderColor)),
          pw.SizedBox(height: 4),
          pw.Text(content, style: const pw.TextStyle(fontSize: 9, color: PdfColors.black, height: 1.3)),
        ],
      ),
    );
  }

  // رسم خطوط الملعب ومواقع اللاعبين فيكتورياً مباشرة على الـ PDF
  static void _drawTacticalPitch(PdfGraphics canvas, PdfPoint size, List<TacticalPlayerModel> players, pw.Font font) {
    canvas.setColor(PdfColor.fromHex('#2D6A4F'));
    canvas.setLineWidth(1.5);

    // خطوط الملعب الخارجية
    canvas.drawRect(8, 8, size.x - 16, size.y - 16);
    canvas.strokePath();

    // خط المنتصف ودائرة الوسط
    canvas.drawLine(size.x / 2, 8, size.x / 2, size.y - 8);
    canvas.strokePath();
    canvas.drawEllipse(size.x / 2, size.y / 2, 35, 35);
    canvas.strokePath();

    // رسم اللاعبين
    for (final p in players) {
      // تحويل الإحداثيات الثلاثية الأبعاد إلى إحداثيات السطح على المستند
      final double normalizedX = (p.coords3D.x + 52.5) / 105.0;
      final double normalizedZ = (p.coords3D.z + 34.0) / 68.0;

      final double px = 8 + (normalizedX * (size.x - 16));
      final double py = 8 + (normalizedZ * (size.y - 16));

      // دائرة اللاعب
      canvas.setColor(p.team == 'home' ? PdfColor.fromHex('#2563EB') : PdfColor.fromHex('#DC2626'));
      canvas.drawEllipse(px, py, 6, 6);
      canvas.fillPath();

      canvas.setColor(PdfColors.white);
      canvas.drawEllipse(px, py, 6, 6);
      canvas.strokePath();
    }
  }
}
