enum PlayerRole {
  gk(0.05),
  cb(0.15),
  fb(0.25),
  cdm(0.30),
  cm(0.40),
  cam(0.50),
  winger(0.45),
  st(0.35);

  const PlayerRole(this.displacementWeight);

  final double displacementWeight;

  static PlayerRole fromLabel(String? label) {
    if (label == null || label.isEmpty) return PlayerRole.cm;

    final normalized = label.toUpperCase();
    if (normalized == 'GK') return PlayerRole.gk;
    if (normalized == 'CB') return PlayerRole.cb;
    if (normalized.contains('WB') ||
        normalized == 'RB' ||
        normalized == 'LB' ||
        normalized == 'FB') {
      return PlayerRole.fb;
    }
    if (normalized == 'CDM' || normalized == 'DM') return PlayerRole.cdm;
    if (normalized == 'CAM' || normalized == 'AM') return PlayerRole.cam;
    if (normalized == 'RW' ||
        normalized == 'LW' ||
        normalized == 'RM' ||
        normalized == 'LM' ||
        normalized == 'WG') {
      return PlayerRole.winger;
    }
    if (normalized == 'ST' || normalized == 'CF') return PlayerRole.st;
    if (normalized == 'CM') return PlayerRole.cm;

    return PlayerRole.cm;
  }
}
