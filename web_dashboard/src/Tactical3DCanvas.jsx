import React, { useState } from 'react';
import { Canvas } from '@react-three/fiber';
import { OrbitControls, Text } from '@react-three/drei';
import PlayerPOVCamera from './PlayerPOVCamera';
import { PitchHeatmapOverlay, PassingCorridorRibbon } from './TacticalAnalyticsOverlays';

function InteractivePlayer({ id, number, position, color, onSelectPlayer }) {
  const handlePointerDown = (e) => {
    e.stopPropagation();
    onSelectPlayer();
  };

  return (
    <group
      position={position}
      onPointerDown={handlePointerDown}
    >
      {/* 3D Player Indicator / Low-Poly Mesh */}
      <mesh castShadow position={[0, 0.9, 0]}>
        <cylinderGeometry args={[0.3, 0.3, 1.8, 16]} />
        <meshStandardMaterial color={color} roughness={0.3} />
      </mesh>

      {/* Floating Shirt Number */}
      <Text
        position={[0, 2.2, 0]}
        fontSize={0.4}
        color="white"
        anchorX="center"
        anchorY="middle"
      >
        {number}
      </Text>
    </group>
  );
}

export default function Tactical3DCanvas({ players = [] }) {
  const [activePovPlayer, setActivePovPlayer] = useState(null);
  const [showHeatmap, setShowHeatmap] = useState(true);
  const [showCorridor, setShowCorridor] = useState(true);

  const defaultPlayers = players.length > 0 ? players : [
    { id: '1', number: 1, x: -45, z: 0, team: 'home', rotationY: 0 },
    { id: '2', number: 4, x: -25, z: -15, team: 'home', rotationY: 0.2 },
    { id: '3', number: 5, x: -25, z: 15, team: 'home', rotationY: -0.2 },
    { id: '4', number: 8, x: 0, z: -10, team: 'home', rotationY: 0.5 },
    { id: '5', number: 10, x: 25, z: 0, team: 'away', rotationY: 3.14 },
    { id: '6', number: 9, x: 35, z: 12, team: 'away', rotationY: 2.8 },
  ];

  // Normalized positions for heatmap (0.0 -> 1.0)
  const heatmapPoints = defaultPlayers.map(p => ({
    x_norm: (p.x + 52.5) / 105.0,
    y_norm: (p.z + 34.0) / 68.0,
  }));

  const passer = defaultPlayers.find(p => p.number === 8);
  const receiver = defaultPlayers.find(p => p.number === 9);
  const opponents = defaultPlayers.filter(p => p.team === 'away');

  const isOrbitMode = activePovPlayer === null;

  return (
    <div className="w-full h-[600px] bg-slate-950 rounded-2xl overflow-hidden border border-slate-800 relative">
      {/* Floating Controls Overlay */}
      <div className="absolute top-4 right-4 z-10 flex items-center gap-3 bg-slate-900/90 border border-slate-700/60 px-4 py-2 rounded-xl backdrop-blur-md text-white text-xs font-semibold shadow-lg">
        <button
          onClick={() => setShowHeatmap(!showHeatmap)}
          className={`px-2.5 py-1 rounded-lg border transition-colors ${showHeatmap ? 'bg-amber-500/20 border-amber-500/50 text-amber-300' : 'bg-slate-800 border-slate-700 text-slate-400'}`}
        >
          Heatmap
        </button>
        <button
          onClick={() => setShowCorridor(!showCorridor)}
          className={`px-2.5 py-1 rounded-lg border transition-colors ${showCorridor ? 'bg-emerald-500/20 border-emerald-500/50 text-emerald-300' : 'bg-slate-800 border-slate-700 text-slate-400'}`}
        >
          Pass Corridor
        </button>

        <span className="flex items-center gap-2 border-l border-slate-700 pl-3">
          <span className={`w-2 h-2 rounded-full ${!isOrbitMode ? 'bg-emerald-400 animate-pulse' : 'bg-sky-400'}`} />
          {!isOrbitMode ? `Player POV (#${activePovPlayer.number})` : 'Tactical Orbit View'}
        </span>
        {!isOrbitMode && (
          <button
            onClick={() => setActivePovPlayer(null)}
            className="px-2.5 py-1 bg-slate-800 hover:bg-slate-700 text-slate-200 rounded-lg border border-slate-600 transition-colors"
          >
            Exit POV
          </button>
        )}
      </div>

      <Canvas shadows>
        <PlayerPOVCamera
          activePlayer={activePovPlayer}
          isOrbitMode={isOrbitMode}
        />

        <ambientLight intensity={0.6} />
        <directionalLight
          position={[30, 50, 30]}
          intensity={1.2}
          castShadow
          shadow-mapSize={[2048, 2048]}
        />

        {/* Pitch Surface */}
        <mesh receiveShadow rotation={[-Math.PI / 2, 0, 0]} position={[0, 0, 0]}>
          <planeGeometry args={[105, 68]} />
          <meshStandardMaterial color="#1b4332" roughness={0.8} />
        </mesh>

        {/* Line Markings & Center Circle */}
        <gridHelper args={[105, 20, '#ffffff', '#2d6a4f']} rotation={[0, 0, 0]} />

        {/* Analytics Overlays */}
        {showHeatmap && <PitchHeatmapOverlay points={heatmapPoints} />}
        {showCorridor && passer && receiver && (
          <PassingCorridorRibbon passer={passer} receiver={receiver} opponents={opponents} />
        )}

        {/* Players */}
        {defaultPlayers.map((p) => (
          <InteractivePlayer
            key={p.id}
            id={p.id}
            number={p.number}
            position={[p.x, 0, p.z]}
            color={p.team === 'home' ? '#2563eb' : '#dc2626'}
            onSelectPlayer={() => setActivePovPlayer(p)}
          />
        ))}

        <OrbitControls enabled={isOrbitMode} maxPolarAngle={Math.PI / 2.1} />
      </Canvas>
    </div>
  );
}
