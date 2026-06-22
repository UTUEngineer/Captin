class CollaborationSession {
  const CollaborationSession({
    required this.id,
    required this.code,
    required this.hostId,
    this.viewersOnly = false,
  });

  final String id;
  final String code;
  final String hostId;
  final bool viewersOnly;

  CollaborationSession copyWith({
    bool? viewersOnly,
  }) {
    return CollaborationSession(
      id: id,
      code: code,
      hostId: hostId,
      viewersOnly: viewersOnly ?? this.viewersOnly,
    );
  }

  String get joinLink => 'captain://collab/$code';
}
