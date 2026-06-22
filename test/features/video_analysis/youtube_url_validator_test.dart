import 'package:captain/features/video_analysis/domain/youtube_url_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('YoutubeUrlValidator', () {
    test('accepts common youtube url formats', () {
      expect(
        YoutubeUrlValidator.isValid('https://www.youtube.com/watch?v=dQw4w9WgXcQ'),
        isTrue,
      );
      expect(
        YoutubeUrlValidator.isValid('https://youtu.be/dQw4w9WgXcQ'),
        isTrue,
      );
      expect(
        YoutubeUrlValidator.isValid('https://youtube.com/shorts/dQw4w9WgXcQ'),
        isTrue,
      );
    });

    test('rejects invalid urls', () {
      expect(YoutubeUrlValidator.isValid(''), isFalse);
      expect(YoutubeUrlValidator.isValid('https://example.com'), isFalse);
      expect(YoutubeUrlValidator.isValid('not-a-url'), isFalse);
    });
  });
}
