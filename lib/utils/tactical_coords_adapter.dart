import 'package:three_js/three_js.dart' as three;
import '../services/tactical_session_service.dart';

class TacticalCoordsAdapter {
  /// تحويل تشكيلة API-Football إلى كائنات ثلاثية الأبعاد
  static List<TacticalPlayerModel> convertTo3DPlayers({
    required Map<String, dynamic> teamLineupData,
    required bool isHomeTeam,
  }) {
    final List startXI = teamLineupData['startXI'] ?? [];
    final List<TacticalPlayerModel> players = [];

    for (var entry in startXI) {
      final player = entry['player'];
      final String? grid = player['grid']; // مثال: "2:4" أو "1:1"
      final int number = player['number'] ?? 0;
      final String name = player['name'] ?? '';
      final String pos = player['pos'] ?? 'M';

      final coords = _calculatePitchCoordinates(grid, isHomeTeam);

      players.add(
        TacticalPlayerModel(
          id: 'player_${player['id']}',
          name: name,
          number: number,
          position: pos,
          team: isHomeTeam ? 'home' : 'away',
          coords3D: coords,
        ),
      );
    }

    return players;
  }

  static three.Vector3 _calculatePitchCoordinates(String? grid, bool isHome) {
    if (grid == null || !grid.contains(':')) {
      return three.Vector3(isHome ? -15.0 : 15.0, 0, 0);
    }

    final parts = grid.split(':');
    final row = int.tryParse(parts[0]) ?? 1; // خط العرض التكتيكي (1: حارس، 2: دفاع...)
    final col = int.tryParse(parts[1]) ?? 1; // التوزيع العرضي

    // أبعاد الملعب الافتراضية (طول 105، عرض 68)
    // Home يبدأ من اليسار (سالب) نحو اليمين (موجب)
    double x;
    if (isHome) {
      x = -45.0 + ((row - 1) * 11.0);
    } else {
      x = 45.0 - ((row - 1) * 11.0);
    }

    // توزيع اللاعبين عرضياً على محور Z (من -30 إلى +30)
    // بافتراض أقصى عدد على نفس الخط 5 لاعبين
    double z = (col - 3) * 12.0;

    return three.Vector3(x, 0.0, z);
  }
}
