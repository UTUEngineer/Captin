import 'package:http/http.dart' as http;
import 'package:pdf/widgets.dart' as pw;

const _cairoRegularUrl =
    'https://github.com/google/fonts/raw/main/ofl/cairo/static/Cairo-Regular.ttf';

class PdfFontLoader {
  pw.Font? _cachedCairo;

  Future<pw.Font?> loadCairoRegular() async {
    if (_cachedCairo != null) return _cachedCairo;
    try {
      final response = await http.get(Uri.parse(_cairoRegularUrl));
      if (response.statusCode != 200) return null;
      _cachedCairo = pw.Font.ttf(response.bodyBytes.buffer.asByteData());
      return _cachedCairo;
    } catch (_) {
      return null;
    }
  }

  Future<pw.TextStyle> arabicStyle({
    double fontSize = 14,
    pw.FontWeight fontWeight = pw.FontWeight.normal,
  }) async {
    final font = await loadCairoRegular();
    return pw.TextStyle(
      font: font,
      fontSize: fontSize,
      fontWeight: fontWeight,
    );
  }
}
