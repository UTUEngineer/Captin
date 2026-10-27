/// Reference pitch coordinates and labels for the four penalty-box corners.
abstract final class StandardPenaltyBoxCalibration {
  /// Penalty-box corners in metres as [distance from goal line,
  /// distance from the right touchline] on a 105 × 68 m pitch
  /// (box: 16.5 m deep, 40.32 m wide, centred on the goal).
  static const pitchCorners = <List<double>>[
    [0.0, 13.84],
    [0.0, 54.16],
    [16.5, 54.16],
    [16.5, 13.84],
  ];

  static const cornerLabels = <String>[
    'Goal-line left',
    'Goal-line right',
    'Box depth right',
    'Box depth left',
  ];

  static const instructionSteps = <String>[
    'Tap the penalty-box corner on the goal line (left).',
    'Tap the penalty-box corner on the goal line (right).',
    'Tap the penalty-box corner on the 18-yard line (right).',
    'Tap the penalty-box corner on the 18-yard line (left).',
  ];
}
