import 'package:captain/features/tactical_board/application/board_export_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('exportFilename', () {
    test('sanitizes unsafe characters and lowercases', () {
      final filename = exportFilename(
        baseName: '4-3-3 High Press / Away',
        extension: 'png',
      );

      expect(filename, startsWith('4-3-3_high_press___away_'));
      expect(filename, endsWith('.png'));
      expect(filename, isNot(contains('/')));
      expect(filename, isNot(contains(' ')));
    });

    test('falls back when name is empty after sanitization', () {
      final filename = exportFilename(
        baseName: '',
        extension: 'pdf',
      );

      expect(filename, startsWith('tactical_board_'));
      expect(filename, endsWith('.pdf'));
    });
  });
}
