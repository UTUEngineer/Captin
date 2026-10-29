import 'package:captain/core/constants/app_constants.dart';

import 'package:captain/core/presentation/app_shell.dart';
import 'package:captain/core/router/app_router.dart';
import 'package:captain/core/router/deep_link_listener.dart';

import 'package:captain/core/theme/app_colors.dart';
import 'package:captain/core/theme/app_theme.dart';
import 'package:captain/core/theme/palette_scope.dart';
import 'package:captain/l10n/app_localizations.dart';

import 'package:captain/features/settings/application/app_preferences_notifier.dart';
import 'package:captain/features/settings/domain/app_preferences.dart';
import 'package:captain/features/settings/domain/app_language.dart';

import 'package:flutter/material.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:supabase_flutter/supabase_flutter.dart';



Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env', isOptional: true);



  await Supabase.initialize(
    url: 'https://woagzfxxggfpexgbmobw.supabase.co',
    anonKey: 'sb_publishable_lQfwj3bvIHPl7bMfSF_mvw_Y5GsOXTX',
  );



  runApp(const ProviderScope(child: CaptainApp()));

}



class CaptainApp extends ConsumerWidget {

  const CaptainApp({super.key});



  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefsAsync = ref.watch(appPreferencesProvider);
    final prefs = prefsAsync.value ?? const AppPreferences();

    final palette = AppTheme.paletteFor(
      prefs.themeVariant,
      platformBrightness: MediaQuery.platformBrightnessOf(context),
    );
    AppColors.apply(palette);
    final theme = AppTheme.fromPalette(palette);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      locale: prefs.language.locale,
      supportedLocales: AppLanguage.values.map((l) => l.locale).toList(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: theme,
      darkTheme: theme,
      themeMode: palette.isDark ? ThemeMode.dark : ThemeMode.light,
      routerConfig: appRouter,
      builder: (context, child) => PaletteScope(
        palette: palette,
        child: DeepLinkListener(
          child: AppShell(
            prefs: prefs,
            child: child,
          ),
        ),
      ),
    );
  }
}


