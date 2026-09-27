import React, { useRef } from 'react';
import { useFrame } from '@react-three/fiber';
import { PerspectiveCamera } from '@react-three/drei';
import * as THREE from 'three';

export default function PlayerPOVCamera({
  activePlayer, // { id, x, y, z, rotationY } or null for standard Orbit
  isOrbitMode = true,
}) {
  const cameraRef = useRef();

  const eyeHeight = 1.75;
  const targetLookAt = useRef(new THREE.Vector3());
  const targetCamPos = useRef(new THREE.Vector3());

  useFrame(() => {
    if (!cameraRef.current) return;

    if (activePlayer && !isOrbitMode) {
      // Calculate target camera eye position
      targetCamPos.current.set(
        activePlayer.x,
        (activePlayer.y || 0) + eyeHeight,
        activePlayer.z
      );

      // Compute forward vector based on player orientation
      const facingAngle = activePlayer.rotationY || 0;
      const forwardDist = 20;
      
      targetLookAt.current.set(
        activePlayer.x + Math.sin(facingAngle) * forwardDist,
        (activePlayer.y || 0) + eyeHeight,
        activePlayer.z + Math.cos(facingAngle) * forwardDist
      );

      // Smooth cinematic camera transition
      cameraRef.current.position.lerp(targetCamPos.current, 0.1);
      cameraRef.current.lookAt(targetLookAt.current);
    }
  });

  return (
    <>
      <PerspectiveCamera
        ref={cameraRef}
        makeDefault={!isOrbitMode}
        fov={isOrbitMode ? 45 : 75}
        near={0.1}
        far={500}
        position={[0, 45, 60]}
      />

      {/* Floating HUD overlay when in POV mode */}
      {!isOrbitMode && activePlayer && (
        <group>
          {/* Subtle tactical sightlines / peripheral angle cone */}
          <gridHelper
            args={[30, 6, '#10b981', '#1e293b']}
            position={[activePlayer.x, 0.05, activePlayer.z]}
            rotation={[0, activePlayer.rotationY || 0, 0]}
          />
        </group>
      )}
    </>
  );
}
