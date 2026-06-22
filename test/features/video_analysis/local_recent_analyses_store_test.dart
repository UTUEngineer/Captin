import 'package:captain/features/video_analysis/data/local_recent_analyses_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LocalRecentAnalysesStore', () {
    test('recordCompleted keeps newest entries first and dedupes video ids',
        () async {
      SharedPreferences.setMockInitialValues({});
      final store = await LocalRecentAnalysesStore.create();

      await store.recordCompleted(videoId: 'a', label: 'First clip');
      await store.recordCompleted(videoId: 'b', label: 'Second clip');
      await store.recordCompleted(videoId: 'a', label: 'First clip updated');

      final entries = await store.loadAll();
      expect(entries, hasLength(2));
      expect(entries.first.videoId, 'a');
      expect(entries.first.label, 'First clip updated');
      expect(entries.last.videoId, 'b');
    });
  });
}
