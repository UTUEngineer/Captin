enum PitchOrientation {
  vertical,
  horizontal,
}

extension PitchOrientationX on PitchOrientation {
  bool get isVertical => this == PitchOrientation.vertical;

  PitchOrientation toggled() =>
      isVertical ? PitchOrientation.horizontal : PitchOrientation.vertical;
}
