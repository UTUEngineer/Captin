import 'package:captain/features/collaboration/domain/collaboration_event.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

typedef CollaborationEventHandler = void Function(CollaborationEvent event);

class CollaborationService {
  RealtimeChannel? _channel;
  String? _localSenderId;

  bool get isSubscribed => _channel != null;

  Future<void> subscribe({
    required String sessionId,
    required String senderId,
    required CollaborationEventHandler onEvent,
  }) async {
    await unsubscribe();

    _localSenderId = senderId;
    final client = Supabase.instance.client;
    _channel = client.channel('session:$sessionId');

    for (final type in CollaborationEventType.values) {
      _channel!.onBroadcast(
        event: type.wireName,
        callback: (payload) {
          final event = _parseEvent(type, payload);
          if (event == null) return;
          if (event.senderId == _localSenderId) return;
          onEvent(event);
        },
      );
    }

    _channel!.subscribe();
  }

  Future<void> send(CollaborationEvent event) async {
    final channel = _channel;
    if (channel == null) return;

    await channel.sendBroadcastMessage(
      event: event.type.wireName,
      payload: event.toBroadcastPayload(),
    );
  }

  Future<void> unsubscribe() async {
    final channel = _channel;
    _channel = null;
    _localSenderId = null;
    if (channel == null) return;
    await channel.unsubscribe();
  }

  CollaborationEvent? _parseEvent(
    CollaborationEventType type,
    Map<String, dynamic> payload,
  ) {
    final data = payload['payload'];
    if (data is Map) {
      return CollaborationEvent.fromBroadcast(
        eventName: type.wireName,
        raw: Map<String, dynamic>.from(data),
      );
    }

    return CollaborationEvent.fromBroadcast(
      eventName: type.wireName,
      raw: Map<String, dynamic>.from(payload),
    );
  }
}
