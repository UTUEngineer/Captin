enum PitchStyle {
  solid,
  striped,
}

extension PitchStyleX on PitchStyle {
  bool get isStriped => this == PitchStyle.striped;

  PitchStyle toggled() => isStriped ? PitchStyle.solid : PitchStyle.striped;
}
