// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Captain Tactics';

  @override
  String get toolsHeader => 'Tactical Tools';

  @override
  String get passTool => 'Pass';

  @override
  String get runTool => 'Run';

  @override
  String get pressZoneTool => 'Press Zone';

  @override
  String get clearBoard => 'Clear Pitch';

  @override
  String get exportPdf => 'Export PDF';

  @override
  String distanceCovered(int meters) {
    return 'Distance: ${meters}m';
  }
}
