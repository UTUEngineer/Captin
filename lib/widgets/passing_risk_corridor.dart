import 'dart:math' as math;
import 'dart:typed_data';
import 'package:three_js/three_js.dart' as three;

class PassingRiskCorridor {
  late three.Mesh corridorMesh;
  final double pitchScaleX = 105.0;
  final double pitchScaleZ = 68.0;

  PassingRiskCorridor() {
    final geom = three.BufferGeometry();
    final mat = three.MeshBasicMaterial()
      ..color = three.Color.fromHex32(0x10B981)
      ..transparent = true
      ..opacity = 0.45
      ..side = three.DoubleSide
      ..depthWrite = false;

    corridorMesh = three.Mesh(geom, mat);
    corridorMesh.position.y = 0.02; // Placed above heatmap
  }

  /// Evaluates passing risk and rebuilds the 3D polygon ribbon
  void evaluateAndRenderPass({
    required three.Vector3 passerPos,
    required three.Vector3 receiverPos,
    required List<three.Vector3> opponentPositions,
  }) {
    // 1. Calculate pass vector and corridor width
    final passDir = receiverPos.clone().sub(passerPos);
    final passDist = passDir.length;
    passDir.normalize();

    // Normal vector perpendicular to pass trajectory on XZ plane
    final normal = three.Vector3(-passDir.z, 0, passDir.x).normalize();
    const halfWidthStart = 0.6; // Passer cone width
    const halfWidthEnd = 2.4;   // Receiver expanding reception cone

    // 2. Calculate Opposition Interception Risk (0.0 = Safe, 1.0 = Highly Dangerous)
    double riskScore = 0.0;

    for (final opp in opponentPositions) {
      // Vector from passer to opponent
      final toOpp = opp.clone().sub(passerPos);
      final projection = toOpp.dot(passDir);

      // Check if opponent is along the pass segment
      if (projection > 0 && projection < passDist) {
        final projectedPoint = passerPos.clone().add(passDir.clone().scale(projection));
        final perpDistance = opp.distanceTo(projectedPoint);

        // Within 3.5 meters of pass trajectory
        if (perpDistance < 3.5) {
          final factor = (1.0 - (perpDistance / 3.5)) * (1.0 - (projection / passDist) * 0.3);
          riskScore = math.max(riskScore, factor);
        }
      }
    }

    // 3. Update Material Color Based on Risk
    // Safe: Emerald Green (#10B981) -> Risky: Amber (#F59E0B) -> Intercepted: Red (#EF4444)
    final colorHex = riskScore > 0.65
        ? 0xEF4444
        : riskScore > 0.3
            ? 0xF59E0B
            : 0x10B981;

    (corridorMesh.material as three.MeshBasicMaterial).color = three.Color.fromHex32(colorHex);

    // 4. Construct 4-Point Trapezoid Ribbon Geometry
    final p1 = passerPos.clone().add(normal.clone().scale(halfWidthStart));
    final p2 = passerPos.clone().sub(normal.clone().scale(halfWidthStart));
    final p3 = receiverPos.clone().add(normal.clone().scale(halfWidthEnd));
    final p4 = receiverPos.clone().sub(normal.clone().scale(halfWidthEnd));

    final vertices = Float32List.fromList([
      p1.x, 0.02, p1.z,
      p2.x, 0.02, p2.z,
      p3.x, 0.02, p3.z,

      p2.x, 0.02, p2.z,
      p4.x, 0.02, p4.z,
      p3.x, 0.02, p3.z,
    ]);

    final geom = three.BufferGeometry();
    geom.setAttribute(three.Attribute.position, three.Float32BufferAttribute(vertices, 3));
    corridorMesh.geometry?.dispose();
    corridorMesh.geometry = geom;
    corridorMesh.visible = true;
  }

  void hide() {
    corridorMesh.visible = false;
  }
}
