enum CollaborationEventType {
  playerMoved('player_moved'),
  annotationAdded('annotation_added'),
  formationChanged('formation_changed'),
  cursorMoved('cursor_moved'),
  collaboratorJoined('collaborator_joined'),
  collaboratorLeft('collaborator_left'),
  viewersOnlyChanged('viewers_only_changed'),
  ping('ping');

  const CollaborationEventType(this.wireName);

  final String wireName;

  static CollaborationEventType? fromWireName(String name) {
    for (final type in CollaborationEventType.values) {
      if (type.wireName == name) return type;
    }
    return null;
  }
}

class CollaborationEvent {
  const CollaborationEvent({
    required this.type,
    required this.senderId,
    required this.timestamp,
    required this.payload,
  });

  final CollaborationEventType type;
  final String senderId;
  final int timestamp;
  final Map<String, dynamic> payload;

  Map<String, dynamic> toBroadcastPayload() {
    return {
      'senderId': senderId,
      'timestamp': timestamp,
      ...payload,
    };
  }

  static CollaborationEvent? fromBroadcast({
    required String eventName,
    required Map<String, dynamic> raw,
  }) {
    final type = CollaborationEventType.fromWireName(eventName);
    if (type == null) return null;

    final senderId = raw['senderId'];
    final timestamp = raw['timestamp'];
    if (senderId is! String || timestamp is! num) return null;

    final payload = Map<String, dynamic>.from(raw)
      ..remove('senderId')
      ..remove('timestamp');

    return CollaborationEvent(
      type: type,
      senderId: senderId,
      timestamp: timestamp.toInt(),
      payload: payload,
    );
  }
}

enum CollaborationAnnotationKind {
  arrow,
  zone,
  highlight,
  text,
}

extension CollaborationAnnotationKindWire on CollaborationAnnotationKind {
  String get wireName => name;
}

CollaborationAnnotationKind? annotationKindFromWire(String value) {
  for (final kind in CollaborationAnnotationKind.values) {
    if (kind.name == value) return kind;
  }
  return null;
}
