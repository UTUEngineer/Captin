import React, { useMemo, useRef, useEffect } from 'react';
import * as THREE from 'three';

export function PitchHeatmapOverlay({ points = [] }) {
  const canvasRef = useRef(document.createElement('canvas'));
  const textureRef = useRef();

  const width = 512;
  const height = 340;

  useEffect(() => {
    const canvas = canvasRef.current;
    canvas.width = width;
    canvas.height = height;
    const ctx = canvas.getContext('2d');

    // Clear
    ctx.clearRect(0, 0, width, height);

    // Render radial gaussian density splats
    points.forEach(({ x_norm, y_norm }) => {
      const px = x_norm * width;
      const py = y_norm * height;
      const rad = 32;

      const grad = ctx.createRadialGradient(px, py, 0, px, py, rad);
      grad.addColorStop(0, 'rgba(239, 68, 68, 0.7)');   // Red
      grad.addColorStop(0.4, 'rgba(245, 158, 11, 0.5)'); // Amber
      grad.addColorStop(0.8, 'rgba(16, 185, 129, 0.2)'); // Green
      grad.addColorStop(1, 'rgba(0, 0, 0, 0)');

      ctx.fillStyle = grad;
      ctx.beginPath();
      ctx.arc(px, py, rad, 0, Math.PI * 2);
      ctx.fill();
    });

    if (textureRef.current) {
      textureRef.current.needsUpdate = true;
    }
  }, [points]);

  return (
    <mesh rotation={[-Math.PI / 2, 0, 0]} position={[0, 0.015, 0]}>
      <planeGeometry args={[105, 68]} />
      <meshBasicMaterial transparent opacity={0.8} depthWrite={false}>
        <canvasTexture ref={textureRef} attach="map" image={canvasRef.current} />
      </meshBasicMaterial>
    </mesh>
  );
}

export function PassingCorridorRibbon({ passer, receiver, opponents = [] }) {
  const meshRef = useRef();

  const { geometry, color } = useMemo(() => {
    if (!passer || !receiver) return { geometry: null, color: '#10b981' };

    const pStart = new THREE.Vector3(passer.x, 0.02, passer.z);
    const pEnd = new THREE.Vector3(receiver.x, 0.02, receiver.z);

    const dir = new THREE.Vector3().subVectors(pEnd, pStart);
    const length = dir.length();
    dir.normalize();

    const normal = new THREE.Vector3(-dir.z, 0, dir.x).normalize();
    const wStart = 0.6;
    const wEnd = 2.2;

    // Evaluate Interception Threat
    let maxThreat = 0.0;
    opponents.forEach((opp) => {
      const oppPos = new THREE.Vector3(opp.x, 0.02, opp.z);
      const toOpp = new THREE.Vector3().subVectors(oppPos, pStart);
      const proj = toOpp.dot(dir);

      if (proj > 0 && proj < length) {
        const projPt = pStart.clone().add(dir.clone().multiplyScalar(proj));
        const dist = oppPos.distanceTo(projPt);
        if (dist < 3.5) {
          const threat = (1.0 - dist / 3.5);
          if (threat > maxThreat) maxThreat = threat;
        }
      }
    });

    // Corridor Color
    const corridorColor = maxThreat > 0.6 ? '#ef4444' : maxThreat > 0.3 ? '#f59e0b' : '#10b981';

    // 4 Corner Vertices
    const v1 = pStart.clone().add(normal.clone().multiplyScalar(wStart));
    const v2 = pStart.clone().sub(normal.clone().multiplyScalar(wStart));
    const v3 = pEnd.clone().add(normal.clone().multiplyScalar(wEnd));
    const v4 = pEnd.clone().sub(normal.clone().multiplyScalar(wEnd));

    const vertices = new Float32Array([
      v1.x, v1.y, v1.z,
      v2.x, v2.y, v2.z,
      v3.x, v3.y, v3.z,

      v2.x, v2.y, v2.z,
      v4.x, v4.y, v4.z,
      v3.x, v3.y, v3.z,
    ]);

    const geom = new THREE.BufferGeometry();
    geom.setAttribute('position', new THREE.BufferAttribute(vertices, 3));
    return { geometry: geom, color: corridorColor };
  }, [passer, receiver, opponents]);

  if (!geometry) return null;

  return (
    <mesh ref={meshRef} geometry={geometry}>
      <meshBasicMaterial color={color} transparent opacity={0.45} side={THREE.DoubleSide} depthWrite={false} />
    </mesh>
  );
}
