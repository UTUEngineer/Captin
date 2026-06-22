/// Reference pitch coordinates and labels for the four penalty-box corners.
abstract final class StandardPenaltyBoxCalibration {
  static const pitchCorners = <List<double>>[
    [0.0, 0.0],
    [0.165, 0.0],
    [0.165, 0.105],
    [0.0, 0.105],
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
