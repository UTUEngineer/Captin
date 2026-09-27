import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class TacticalPdfExporter {
  static Future<void> generateAndShareTacticalReport({
    required Uint8List pitchImageBytes,
    required String matchTitle,        // مثال: "الكلاسيكو - تحليل الشوط الأول"
    required String coachName,         // اسم الكابتن/المحلل
    required String formationName,     // التشكيلة: "4-3-3"
    required List<String> tacticalNotes,// الملاحظات التكتيكية
  }) async {
    final pdf = pw.Document();

    // تحميل خط عربي مخصص (مثل Tajawal) لدعم اللغة العربية في الـ PDF
    final fontArabic = await PdfGoogleFonts.tajawalMedium();
    final fontArabicBold = await PdfGoogleFonts.tajawalBold();

    final pitchImage = pw.MemoryImage(pitchImageBytes);

    // بناء صفحة التقرير التكتيكي
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(
          base: fontArabic,
          bold: fontArabicBold,
        ),
        build: (pw.Context context) {
          return pw.Directionality(
            textDirection: pw.TextDirection.rtl, // دعم الكتابة من اليمين لليسار
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // A. الهيدر العلوي للتقرير (Header Panel)
                pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.blueGrey900,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            matchTitle,
                            style: pw.TextStyle(
                              color: PdfColors.white,
                              fontSize: 18,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            "المحلل التكتيكي: $coachName  |  التشكيلة: $formationName",
                            style: const pw.TextStyle(
                              color: PdfColors.blueGrey200,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                      pw.Text(
                        "CAPTAIN 3D",
                        style: pw.TextStyle(
                          color: PdfColors.amber400,
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                pw.SizedBox(height: 15),

                // B. كادر الصورة السينمائية للـ 3D Pitch
                pw.Container(
                  height: 320,
                  width: double.infinity,
                  decoration: pw.BoxDecoration(
                    borderRadius: pw.BorderRadius.circular(8),
                    border: pw.Border.all(color: PdfColors.grey400, width: 1),
                  ),
                  child: pw.ClipRRect(
                    horizontalRadius: 8,
                    verticalRadius: 8,
                    child: pw.Image(pitchImage, fit: pw.BoxFit.cover),
                  ),
                ),

                pw.SizedBox(height: 15),

                // C. قسم الملاحظات التكتيكية وتوجيهات الفريق
                pw.Text(
                  "الملاحظات والتوجيهات التكتيكية:",
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blueGrey900,
                  ),
                ),
                pw.SizedBox(height: 8),

                pw.Expanded(
                  child: pw.Container(
                    width: double.infinity,
                    padding: const pw.EdgeInsets.all(12),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.grey100,
                      borderRadius: pw.BorderRadius.circular(8),
                      border: pw.Border.all(color: PdfColors.grey300),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: tacticalNotes.map((note) {
                        return pw.Padding(
                          padding: const pw.EdgeInsets.only(bottom: 6),
                          child: pw.Row(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text("• ", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                              pw.Expanded(
                                child: pw.Text(
                                  note,
                                  style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey900),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                // D. الفوتر السفلي (Footer)
                pw.Divider(color: PdfColors.grey300),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      "تم التصدير بواسطة منصة Captain Tactical Suite",
                      style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
                    ),
                    pw.Text(
                      "الصفحة 1 من 1",
                      style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );

    // فتح نافذة الطباعة والمشاركة المستعرضة (Print / Save / Share)
    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'Captain_Tactical_Report_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
  }
}
