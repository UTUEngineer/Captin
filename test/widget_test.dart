import 'package:captain/features/settings/application/app_preferences_notifier.dart';
import 'package:captain/features/settings/domain/app_preferences.dart';
import 'package:captain/main.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class _CompletedOnboardingNotifier extends AppPreferencesNotifier {
  @override
  Future<AppPreferences> build() async {
    return const AppPreferences(onboardingCompleted: true);
  }
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await dotenv.load(fileName: '.env', isOptional: true);
  });

  testWidgets('Captain app launches splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appPreferencesProvider.overrideWith(_CompletedOnboardingNotifier.new),
        ],
        child: const CaptainApp(),
      ),
    );
    await tester.pump();

    // The intro video can't play in tests; it falls through to the splash.
    if (find.text('Skip').evaluate().isNotEmpty ||
        find.text('تخطي').evaluate().isNotEmpty) {
      await tester.tap(find.byType(GestureDetector).first);
    }
    await tester.pump(const Duration(seconds: 4));
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.textContaining('CAPTAIN'), findsWidgets);

    await tester.tap(find.text('دخول التطبيق'));
    await tester.pumpAndSettle();

    expect(find.text('New Tactical Board'), findsOneWidget);
  });
}
