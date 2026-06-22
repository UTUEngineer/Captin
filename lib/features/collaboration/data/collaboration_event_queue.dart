import 'dart:convert';

import 'package:captain/features/collaboration/domain/collaboration_event.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _queueStorageKey = 'captain_collaboration_event_queue_v1';

class CollaborationEventQueue {
  CollaborationEventQueue(this._prefs);

  final SharedPreferences _prefs;

  static Future<CollaborationEventQueue> create() async {
    final prefs = await SharedPreferences.getInstance();
    return CollaborationEventQueue(prefs);
  }

  Future<void> enqueue(CollaborationEvent event) async {
    final queue = await _readAll();
    queue.add(_encode(event));
    await _prefs.setString(_queueStorageKey, jsonEncode(queue));
  }

  Future<List<CollaborationEvent>> drain() async {
    final queue = await _readAll();
    if (queue.isEmpty) return const [];

    await _prefs.remove(_queueStorageKey);
    return queue.map(_decode).whereType<CollaborationEvent>().toList();
  }

  Future<int> pendingCount() async => (await _readAll()).length;

  Future<List<Map<String, dynamic>>> _readAll() async {
    final raw = _prefs.getString(_queueStorageKey);
    if (raw == null || raw.isEmpty) return [];
    final decoded = jsonDecode(raw);
    if (decoded is! List) return [];
    return decoded
        .whereType<Map>()
        .map((entry) => Map<String, dynamic>.from(entry))
        .toList();
  }

  Map<String, dynamic> _encode(CollaborationEvent event) {
    return {
      'type': event.type.wireName,
      'senderId': event.senderId,
      'payload': event.payload,
      'timestamp': event.timestamp,
    };
  }

  CollaborationEvent? _decode(Map<String, dynamic> entry) {
    final type = CollaborationEventType.fromWireName(entry['type'] as String? ?? '');
    if (type == null) return null;
    return CollaborationEvent(
      type: type,
      senderId: entry['senderId'] as String? ?? '',
      timestamp: entry['timestamp'] as int? ?? 0,
      payload: Map<String, dynamic>.from(entry['payload'] as Map? ?? {}),
    );
  }
}

final collaborationEventQueueProvider =
    FutureProvider<CollaborationEventQueue>((ref) async {
  return CollaborationEventQueue.create();
});
