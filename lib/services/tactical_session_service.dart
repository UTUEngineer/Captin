import 'package:flutter/foundation.dart';
import 'package:three_js/three_js.dart' as three;

class TacticalPlayerModel {
  final String id;
  final String name;
  final int number;
  final String position; // "GK", "DEF", "MID", "FWD"
  final String team; // "home" | "away"
  three.Vector3 coords3D; // X, Y (0), Z
  final List<String> strengths;
  final List<String> weaknesses;

  TacticalPlayerModel({
    required this.id,
    required this.name,
    required this.number,
    required this.position,
    required this.team,
    required this.coords3D,
    this.strengths = const [],
    this.weaknesses = const [],
  });
}

class TacticalSessionService extends ChangeNotifier {
  TacticalSessionService._();
  static final TacticalSessionService instance = TacticalSessionService._();

  // Active Lineups loaded across Hub 1 & Hub 2
  List<TacticalPlayerModel> activePlayers = [];
  String? activeMatchTitle;
  String? activeFormation;
  int activeTabIndex = 0;

  /// Loads an opposition/league squad from Hub 3 directly into Hub 1 & 2
  void importSquadToTactics({
    required String matchTitle,
    required String formation,
    required List<TacticalPlayerModel> squad,
  }) {
    activeMatchTitle = matchTitle;
    activeFormation = formation;
    activePlayers = List.from(squad);
    
    // Switch to 3D Playground (Hub 1)
    activeTabIndex = 0;
    notifyListeners();
  }

  void switchTab(int index) {
    activeTabIndex = index;
    notifyListeners();
  }

  void updatePlayerPosition(String id, three.Vector3 newPos) {
    final idx = activePlayers.indexWhere((p) => p.id == id);
    if (idx != -1) {
      activePlayers[idx].coords3D = newPos;
      notifyListeners();
    }
  }
}
