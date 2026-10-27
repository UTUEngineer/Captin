/// Position of the match ball on the tactical board (relative 0..1 coords,
/// same space as players).
class BoardBall {
  const BoardBall({required this.x, required this.y});

  final double x;
  final double y;

  BoardBall copyWith({double? x, double? y}) =>
      BoardBall(x: x ?? this.x, y: y ?? this.y);

  Map<String, dynamic> toJson() => {'x': x, 'y': y};

  static BoardBall? fromJson(Object? json) {
    if (json is! Map) return null;
    final x = json['x'];
    final y = json['y'];
    if (x is! num || y is! num) return null;
    return BoardBall(x: x.toDouble(), y: y.toDouble());
  }

  @override
  bool operator ==(Object other) =>
      other is BoardBall && other.x == x && other.y == y;

  @override
  int get hashCode => Object.hash(x, y);
}
