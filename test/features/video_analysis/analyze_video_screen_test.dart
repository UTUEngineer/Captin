import 'package:captain/core/network/result.dart';
import 'package:captain/features/video_analysis/application/backend_availability_provider.dart';
import 'package:captain/features/video_analysis/application/video_analysis_providers.dart';
import 'package:captain/features/video_analysis/domain/video_analysis_repository.dart';
import 'package:captain/features/video_analysis/presentation/analyze_video_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _HealthyRepository implements VideoAnalysisRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<Result<bool>> checkBackendHealth() async => const Success(true);

  @override
  Future<Result<bool>> checkAnalysisQuota() async => const Success(true);
}

class _UnavailableRepository implements VideoAnalysisRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<Result<bool>> checkBackendHealth() async => const Success(false);

  @override
  Future<Result<bool>> checkAnalysisQuota() async => const Success(true);
}

void main() {
  testWidgets('AnalyzeVideoScreen shows upload and youtube tabs', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          videoAnalysisRepositoryProvider.overrideWithValue(_HealthyRepository()),
        ],
        child: const MaterialApp(home: AnalyzeVideoScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Analyze Match Video'), findsOneWidget);
    expect(find.text('Upload video'), findsOneWidget);
    expect(find.text('YouTube link'), findsOneWidget);
    expect(find.text('Start analysis'), findsOneWidget);
    expect(find.textContaining('several minutes'), findsOneWidget);

    final startButton = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Start analysis'),
    );
    expect(startButton.onPressed, isNull);
  });

  testWidgets('Start analysis enables after valid youtube url', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          videoAnalysisRepositoryProvider.overrideWithValue(_HealthyRepository()),
        ],
        child: const MaterialApp(home: AnalyzeVideoScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('YouTube link'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextField),
      'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
    );
    await tester.pumpAndSettle();

    final startButton = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Start analysis'),
    );
    expect(startButton.onPressed, isNotNull);
  });

  testWidgets('AnalyzeVideoScreen disables start when backend unavailable',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          videoAnalysisRepositoryProvider
              .overrideWithValue(_UnavailableRepository()),
        ],
        child: const MaterialApp(home: AnalyzeVideoScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Video analysis is unavailable'), findsOneWidget);

    await tester.tap(find.text('YouTube link'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextField),
      'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
    );
    await tester.pumpAndSettle();

    final startButton = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Start analysis'),
    );
    expect(startButton.onPressed, isNull);
  });
}
