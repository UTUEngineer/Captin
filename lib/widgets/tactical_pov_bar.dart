import 'package:flutter/material.dart';
import 'tactical_pov_camera_controller.dart';

Widget buildPovControlBar({
  required TacticalPovCameraController povController,
  required VoidCallback onStateChanged,
}) {
  final isPov = povController.mode == CameraMode.firstPersonPov;

  return Positioned(
    top: 20,
    right: 20,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPov ? Icons.visibility : Icons.videocam,
            size: 18,
            color: isPov ? const Color(0xFF10B981) : Colors.white70,
          ),
          const SizedBox(width: 8),
          Text(
            isPov
                ? "Player POV: #${povController.attachedPlayer?.name ?? ''}"
                : "Tactical Orbit View",
            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 12),
          if (isPov)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white12,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                minimumSize: Size.zero,
              ),
              onPressed: () {
                povController.exitToOrbitView();
                onStateChanged();
              },
              child: const Text("Exit POV", style: TextStyle(fontSize: 11)),
            ),
        ],
      ),
    ),
  );
}
