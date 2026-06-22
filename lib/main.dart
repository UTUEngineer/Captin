import 'package:captain/core/config/app_config.dart';

import 'package:captain/core/constants/app_constants.dart';

import 'package:captain/core/presentation/app_shell.dart';
import 'package:captain/core/router/app_router.dart';

import 'package:captain/core/theme/app_theme.dart';

import 'package:captain/features/settings/application/app_preferences_notifier.dart';

import 'package:captain/features/settings/domain/app_language.dart';

import 'package:flutter/material.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:supabase_flutter/supabase_flutter.dart';



Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env', isOptional: true);



  if (AppConfig.isSupabaseConfigured) {

    await Supabase.initialize(

      url: AppConfig.supabaseUrl,

      publishableKey: AppConfig.supabaseAnonKey,

    );

  }



  runApp(const ProviderScope(child: CaptainApp()));

}



class CaptainApp extends ConsumerWidget {

  const CaptainApp({super.key});



  @override

  Widget build(BuildContext context, WidgetRef ref) {

    final prefsAsync = ref.watch(appPreferencesProvider);



    return prefsAsync.when(

      loading: () => MaterialApp(

        debugShowCheckedModeBanner: false,

        home: Scaffold(

          backgroundColor: ThemeData.dark().scaffoldBackgroundColor,

          body: const Center(child: CircularProgressIndicator()),

        ),

      ),

      error: (error, _) => MaterialApp(

        debugShowCheckedModeBanner: false,

        home: Scaffold(body: Center(child: Text('$error'))),

      ),

      data: (prefs) {

        return MaterialApp.router(

          title: AppConstants.appName,

          debugShowCheckedModeBanner: false,

          locale: prefs.language.locale,

          supportedLocales: AppLanguage.values.map((l) => l.locale).toList(),

          localizationsDelegates: const [

            GlobalMaterialLocalizations.delegate,

            GlobalWidgetsLocalizations.delegate,

            GlobalCupertinoLocalizations.delegate,

          ],

          theme: AppTheme.themeFor(prefs.themeVariant),

          darkTheme: AppTheme.themeFor(prefs.themeVariant),

          themeMode: ThemeMode.dark,

          routerConfig: appRouter,

          builder: (context, child) => AppShell(
            prefs: prefs,
            child: child,
          ),

        );

      },

    );

  }

}


