import 'dart:math';

import 'package:captain/features/collaboration/domain/collaboration_event.dart';
import 'package:captain/features/collaboration/domain/session_code.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('session code', () {
    test('generateSessionCode uses ABC-123 format', () {
      final code = generateSessionCode(random: Random(42));
      expect(isValidSessionCode(code), isTrue);
      expect(code, contains('-'));
    });

    test('normalizeSessionCode uppercases input', () {
      expect(normalizeSessionCode('abc-123'), 'ABC-123');
    });

    test('isValidSessionCode rejects malformed codes', () {
      expect(isValidSessionCode('ABC123'), isFalse);
      expect(isValidSessionCode('AB-1234'), isFalse);
    });
  });

  group('CollaborationEvent', () {
    test('fromBroadcast parses player move payload', () {
      final event = CollaborationEvent.fromBroadcast(
        eventName: 'player_moved',
        raw: {
          'senderId': 'user-1',
          'timestamp': 1700000000000,
          'playerId': 'p1',
          'x': 0.42,
          'y': 0.58,
        },
      );

      expect(event, isNotNull);
      expect(event!.type, CollaborationEventType.playerMoved);
      expect(event.payload['playerId'], 'p1');
    });

    test('fromBroadcast parses annotation payload', () {
      final event = CollaborationEvent.fromBroadcast(
        eventName: 'annotation_added',
        raw: {
          'senderId': 'user-2',
          'timestamp': 100,
          'kind': 'arrow',
          'data': {'id': 'a1'},
        },
      );

      expect(event, isNotNull);
      expect(
        annotationKindFromWire(event!.payload['kind'] as String),
        CollaborationAnnotationKind.arrow,
      );
    });
  });
}
