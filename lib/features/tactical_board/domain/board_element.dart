enum BoardElementKind {
  player,
  arrow,
  zone,
  highlight,
  text,
}

class BoardElementKey {
  const BoardElementKey(this.kind, this.id);

  final BoardElementKind kind;
  final String id;

  @override
  bool operator ==(Object other) {
    return other is BoardElementKey && other.kind == kind && other.id == id;
  }

  @override
  int get hashCode => Object.hash(kind, id);
}

extension BoardElementKindX on BoardElementKind {
  bool get supportsColor =>
      this == BoardElementKind.arrow ||
      this == BoardElementKind.zone ||
      this == BoardElementKind.highlight;

  bool get supportsRotation =>
      this == BoardElementKind.arrow || this == BoardElementKind.zone;
}
