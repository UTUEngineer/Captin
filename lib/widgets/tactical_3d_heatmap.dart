import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:three_js/three_js.dart' as three;

class Tactical3DHeatmap {
  final int textureWidth;
  final int textureHeight;
  late three.Mesh heatmapMesh;

  Tactical3DHeatmap({
    this.textureWidth = 512,
    this.textureHeight = 340, // 105m x 68m pitch ratio
  }) {
    _initMesh();
  }

  void _initMesh() {
    // Plane geometry matching pitch scale (105 x 68)
    final geom = three.PlaneGeometry(105, 68);
    
    // Transparent overlay material placed slightly above grass (Y = 0.015)
    final mat = three.MeshBasicMaterial()
      ..transparent = true
      ..opacity = 0.75
      ..depthWrite = false;

    heatmapMesh = three.Mesh(geom, mat);
    heatmapMesh.rotation.x = -math.pi / 2;
    heatmapMesh.position.y = 0.015;
    heatmapMesh.name = "tactical_heatmap_overlay";
  }

  /// Generates a gaussian density heatmap from normalized player positions (0.0 -> 1.0)
  Future<void> updateHeatmap(List<Offset> normalizedPositions) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, textureWidth.toDouble(), textureHeight.toDouble()));

    // Clear background to full transparency
    canvas.drawColor(Colors.transparent, BlendMode.clear);

    for (final pos in normalizedPositions) {
      final cx = pos.dx * textureWidth;
      final cy = pos.dy * textureHeight;
      const radius = 38.0;

      // Radial Gaussian gradient: Red (High) -> Yellow -> Cyan -> Transparent
      final gradient = ui.Gradient.radial(
        Offset(cx, cy),
        radius,
        [
          const Color(0xFFFF0000).withValues(alpha: 0.8),
          const Color(0xFFFF9900).withValues(alpha: 0.6),
          const Color(0xFF00FFCC).withValues(alpha: 0.3),
          const Color(0xFF0000FF).withValues(alpha: 0.0),
        ],
        [0.0, 0.4, 0.75, 1.0],
      );

      final paint = Paint()
        ..shader = gradient
        ..blendMode = BlendMode.screen;

      canvas.drawCircle(Offset(cx, cy), radius, paint);
    }

    final picture = recorder.endRecording();
    await picture.toImage(textureWidth, textureHeight);

    // Update ThreeJS texture
    if (heatmapMesh.material is three.MeshBasicMaterial) {
      (heatmapMesh.material as three.MeshBasicMaterial).map?.needsUpdate = true;
    }
  }

  void setVisible(bool visible) {
    heatmapMesh.visible = visible;
  }
}
