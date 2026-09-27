// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'كابتن للخطط التكتيكية';

  @override
  String get toolsHeader => 'أدوات التكتيك';

  @override
  String get passTool => 'تمرير';

  @override
  String get runTool => 'تحرك';

  @override
  String get pressZoneTool => 'منطقة ضغط';

  @override
  String get clearBoard => 'مسح الملعب';

  @override
  String get exportPdf => 'تصدير PDF';

  @override
  String distanceCovered(int meters) {
    return 'المسافة: $meters م';
  }
}
