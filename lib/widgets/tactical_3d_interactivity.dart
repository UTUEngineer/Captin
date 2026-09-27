import 'package:flutter/material.dart';
import 'package:three_js/three_js.dart' as three;

class Tactical3DInteractivity {
  final three.Camera camera;
  final three.Scene scene;
  final GlobalKey canvasKey;
  final List<three.Object3D> interactiveObjects; // Players and Ball meshes

  final three.Raycaster _raycaster = three.Raycaster();
  final three.Vector2 _mouse = three.Vector2.zero();
  final three.Plane _groundPlane = three.Plane(three.Vector3(0, 1, 0), 0); // Y=0 plane
  final three.Vector3 _intersectionPoint = three.Vector3.zero();

  three.Object3D? selectedObject;
  bool isDragging = false;
  
  // Normalized pitch bounds (FIFA pitch ratio: 105m x 68m scaled)
  final double pitchLimitX = 52.5;
  final double pitchLimitZ = 34.0;

  Tactical3DInteractivity({
    required this.camera,
    required this.scene,
    required this.canvasKey,
    required this.interactiveObjects,
  });

  /// Converts screen touch position to Normalized Device Coordinates (NDC) [-1, 1]
  void _updateRaycaster(Offset globalPosition) {
    final RenderBox? renderBox = canvasKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final localPosition = renderBox.globalToLocal(globalPosition);
    final size = renderBox.size;

    _mouse.x = (localPosition.dx / size.width) * 2 - 1;
    _mouse.y = -(localPosition.dy / size.height) * 2 + 1;

    _raycaster.setFromCamera(_mouse, camera);
  }

  /// On Pointer Down: Detect if a player/ball was tapped
  bool onPointerDown(Offset globalPosition) {
    _updateRaycaster(globalPosition);

    final intersects = _raycaster.intersectObjects(interactiveObjects, true);

    if (intersects.isNotEmpty) {
      // Find the top-level parent interactive node
      three.Object3D hit = intersects.first.object!;
      while (hit.parent != null && !interactiveObjects.contains(hit)) {
        hit = hit.parent!;
      }

      selectedObject = hit;
      isDragging = true;
      _highlightSelection(selectedObject!, true);
      return true; // Lock orbit controls
    }

    return false;
  }

  /// On Pointer Move: Drag selected object across XZ ground plane
  void onPointerMove(Offset globalPosition) {
    if (!isDragging || selectedObject == null) return;

    _updateRaycaster(globalPosition);

    // Cast ray against infinite ground plane
    final hit = _raycaster.ray.intersectPlane(_groundPlane, _intersectionPoint);
    if (hit != null) {
      // Clamp position within pitch boundaries
      final clampedX = _intersectionPoint.x.clamp(-pitchLimitX, pitchLimitX);
      final clampedZ = _intersectionPoint.z.clamp(-pitchLimitZ, pitchLimitZ);

      selectedObject!.position.x = clampedX;
      selectedObject!.position.z = clampedZ;
    }
  }

  /// On Pointer Up: Release selection and unlock camera
  void onPointerUp() {
    if (selectedObject != null) {
      _highlightSelection(selectedObject!, false);
    }
    selectedObject = null;
    isDragging = false;
  }

  void _highlightSelection(three.Object3D obj, bool highlight) {
    obj.traverse((child) {
      if (child is three.Mesh && child.material is three.MeshStandardMaterial) {
        final mat = child.material as three.MeshStandardMaterial;
        mat.emissive = highlight ? three.Color.fromHex32(0x333333) : three.Color.fromHex32(0x000000);
      }
    });
  }
}
