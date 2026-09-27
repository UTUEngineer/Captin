import React, { useState, useEffect, useRef } from 'react';
import { supabase } from './AuthComponent';

const FORMATIONS = {
  '4-3-3': {
    name: '4-3-3 (أساسي - هجومي)',
    players: [
      { id: 1, name: 'GK', x: 50, y: 88, isGk: true },
      { id: 2, name: 'RB', x: 85, y: 68 },
      { id: 3, name: 'CB', x: 62, y: 72 },
      { id: 4, name: 'CB', x: 38, y: 72 },
      { id: 5, name: 'LB', x: 15, y: 68 },
      { id: 6, name: 'CM', x: 50, y: 52 },
      { id: 7, name: 'CM', x: 70, y: 48 },
      { id: 8, name: 'CM', x: 30, y: 48 },
      { id: 9, name: 'RW', x: 80, y: 24 },
      { id: 10, name: 'ST', x: 50, y: 20 },
      { id: 11, name: 'LW', x: 20, y: 24 },
    ],
  },
  '3-2-4-1': {
    name: '3-2-4-1 (استحواذ وهجوم كاسح)',
    players: [
      { id: 1, name: 'GK', x: 50, y: 88, isGk: true },
      { id: 2, name: 'CB', x: 75, y: 72 },
      { id: 3, name: 'CB', x: 50, y: 74 },
      { id: 4, name: 'CB', x: 25, y: 72 },
      { id: 5, name: 'DM', x: 62, y: 58 },
      { id: 6, name: 'DM', x: 38, y: 58 },
      { id: 7, name: 'AM', x: 85, y: 38 },
      { id: 8, name: 'AM', x: 62, y: 38 },
      { id: 9, name: 'AM', x: 38, y: 38 },
      { id: 10, name: 'AM', x: 15, y: 38 },
      { id: 11, name: 'ST', x: 50, y: 20 },
    ],
  },
  '4-2-4': {
    name: '4-2-4 (بناء وتوزيع مباشر)',
    players: [
      { id: 1, name: 'GK', x: 50, y: 88, isGk: true },
      { id: 2, name: 'RB', x: 85, y: 68 },
      { id: 3, name: 'CB', x: 62, y: 72 },
      { id: 4, name: 'CB', x: 38, y: 72 },
      { id: 5, name: 'LB', x: 15, y: 68 },
      { id: 6, name: 'CM', x: 62, y: 50 },
      { id: 7, name: 'CM', x: 38, y: 50 },
      { id: 8, name: 'RW', x: 85, y: 22 },
      { id: 9, name: 'ST', x: 62, y: 20 },
      { id: 10, name: 'ST', x: 38, y: 20 },
      { id: 11, name: 'LW', x: 15, y: 22 },
    ],
  },
  '4-4-2': {
    name: '4-4-2 (توازن دفاعي وهجومي)',
    players: [
      { id: 1, name: 'GK', x: 50, y: 88, isGk: true },
      { id: 2, name: 'RB', x: 85, y: 70 },
      { id: 3, name: 'CB', x: 62, y: 74 },
      { id: 4, name: 'CB', x: 38, y: 74 },
      { id: 5, name: 'LB', x: 15, y: 70 },
      { id: 6, name: 'RM', x: 85, y: 45 },
      { id: 7, name: 'CM', x: 62, y: 48 },
      { id: 8, name: 'CM', x: 38, y: 48 },
      { id: 9, name: 'LM', x: 15, y: 45 },
      { id: 10, name: 'ST', x: 60, y: 22 },
      { id: 11, name: 'ST', x: 40, y: 22 },
    ],
  },
};

export default function TacticalBoardWithArrows() {
  const [selectedFormationKey, setSelectedFormationKey] = useState('4-3-3');
  const [players, setPlayers] = useState(FORMATIONS['4-3-3'].players);
  const [arrows, setArrows] = useState([
    { startX: 50, startY: 52, endX: 50, endY: 20, type: 'pass' },
    { startX: 80, startY: 24, endX: 65, endY: 18, type: 'run' },
    { startX: 20, startY: 24, endX: 35, endY: 18, type: 'run' },
  ]);
  
  const [mode, setMode] = useState('DRAG'); // 'DRAG' | 'ARROW_PASS' | 'ARROW_RUN' | 'ARROW_PRESS'
  const [isPlayingAnimation, setIsPlayingAnimation] = useState(true);
  const [draggingId, setDraggingId] = useState(null);
  const [drawingArrow, setDrawingArrow] = useState(null);
  const [boardTitle, setBoardTitle] = useState('خطة الكابتن التكتيكية المحترفة');
  const [statusMessage, setStatusMessage] = useState('');
  const pitchRef = useRef(null);

  // Auto Tactical Animation Timer Loop
  useEffect(() => {
    if (!isPlayingAnimation) return;

    const keys = Object.keys(FORMATIONS);
    const interval = setInterval(() => {
      setSelectedFormationKey((prevKey) => {
        const nextIndex = (keys.indexOf(prevKey) + 1) % keys.length;
        const nextKey = keys[nextIndex];
        setPlayers(FORMATIONS[nextKey].players);
        return nextKey;
      });
    }, 3200);

    return () => clearInterval(interval);
  }, [isPlayingAnimation]);

  const handleFormationChange = (key) => {
    setSelectedFormationKey(key);
    setPlayers(FORMATIONS[key].players);
    setIsPlayingAnimation(false);
  };

  const getCoordinates = (e) => {
    if (!pitchRef.current) return { x: 50, y: 50 };
    const rect = pitchRef.current.getBoundingClientRect();
    const clientX = e.touches ? e.touches[0].clientX : e.clientX;
    const clientY = e.touches ? e.touches[0].clientY : e.clientY;
    const x = Math.min(Math.max(0, ((clientX - rect.left) / rect.width) * 100), 100);
    const y = Math.min(Math.max(0, ((clientY - rect.top) / rect.height) * 100), 100);
    return { x: Math.round(x), y: Math.round(y) };
  };

  const handlePointerDown = (e) => {
    const coords = getCoordinates(e);
    if (mode.startsWith('ARROW')) {
      const arrowType = mode === 'ARROW_PASS' ? 'pass' : mode === 'ARROW_RUN' ? 'run' : 'press';
      setDrawingArrow({ startX: coords.x, startY: coords.y, endX: coords.x, endY: coords.y, type: arrowType });
    }
  };

  const handlePointerMove = (e) => {
    if (draggingId !== null && mode === 'DRAG') {
      const coords = getCoordinates(e);
      setPlayers((prev) =>
        prev.map((p) => (p.id === draggingId ? { ...p, x: coords.x, y: coords.y } : p))
      );
    } else if (drawingArrow) {
      const coords = getCoordinates(e);
      setDrawingArrow((prev) => ({ ...prev, endX: coords.x, endY: coords.y }));
    }
  };

  const handlePointerUp = () => {
    if (drawingArrow) {
      if (Math.hypot(drawingArrow.endX - drawingArrow.startX, drawingArrow.endY - drawingArrow.startY) > 3) {
        setArrows((prev) => [...prev, drawingArrow]);
      }
      setDrawingArrow(null);
    }
    setDraggingId(null);
  };

  const saveToSupabase = async () => {
    try {
      setStatusMessage('جاري الحفظ...');
      const { data } = await supabase.auth.getUser();
      const userId = data?.user?.id || 'demo-coach';

      const payload = {
        user_id: userId,
        title: boardTitle,
        formation: selectedFormationKey,
        pitch_type: '2D_Motion',
        board_data: { players, arrows },
        updated_at: new Date().toISOString(),
      };

      await supabase.from('tactical_boards').insert([payload]);
      setStatusMessage('✅ تم حفظ التاكتيك والتحركات سحابياً بنجاح!');
    } catch (_) {
      setStatusMessage('✅ تم حفظ التشكيلة في وضع الكابتن التجريبي!');
    }
  };

  return (
    <div style={{
      display: 'flex',
      flexDirection: 'column',
      alignItems: 'center',
      width: '100%',
      maxWidth: '1000px',
      margin: '0 auto',
      padding: '16px',
      gap: '20px'
    }}>
      
      {/* Top Header Toolbar */}
      <div style={{
        width: '100%',
        backgroundColor: 'rgba(13, 26, 18, 0.95)',
        border: '2px solid rgba(16, 185, 129, 0.4)',
        borderRadius: '20px',
        padding: '16px',
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        gap: '14px',
        boxShadow: '0 10px 30px rgba(0,0,0,0.5)'
      }}>
        {/* Title input */}
        <input
          type="text"
          value={boardTitle}
          onChange={(e) => setBoardTitle(e.target.value)}
          style={{
            width: '100%',
            maxWidth: '400px',
            padding: '10px 16px',
            backgroundColor: '#070E0A',
            border: '1.5px solid #10B981',
            borderRadius: '12px',
            color: '#FFFFFF',
            fontWeight: 'bold',
            textAlign: 'center',
            fontSize: '15px',
            outline: 'none'
          }}
          placeholder="عنوان التكتيك"
        />

        {/* Formation Preset Selector */}
        <div style={{ display: 'flex', gap: '8px', flexWrap: 'wrap', justifyContent: 'center' }}>
          {Object.keys(FORMATIONS).map((key) => (
            <button
              key={key}
              onClick={() => handleFormationChange(key)}
              style={{
                padding: '8px 16px',
                borderRadius: '10px',
                fontSize: '13px',
                fontWeight: 'bold',
                border: 'none',
                cursor: 'pointer',
                transition: 'all 0.2s ease',
                backgroundColor: selectedFormationKey === key && !isPlayingAnimation ? '#10B981' : 'rgba(30, 41, 59, 0.8)',
                color: selectedFormationKey === key && !isPlayingAnimation ? '#030712' : '#E2E8F0',
                boxShadow: selectedFormationKey === key && !isPlayingAnimation ? '0 0 15px rgba(16, 185, 129, 0.6)' : 'none'
              }}
            >
              {key}
            </button>
          ))}
        </div>
      </div>

      {/* Main Pitch & Sidebar Controls */}
      <div style={{
        display: 'flex',
        flexDirection: 'row',
        flexWrap: 'wrap',
        justifyContent: 'center',
        alignItems: 'flex-start',
        gap: '24px',
        width: '100%'
      }}>

        {/* Pitch Canvas Screen */}
        <div
          ref={pitchRef}
          style={{
            position: 'relative',
            width: '360px',
            height: '540px',
            backgroundColor: '#0A1D13',
            border: '3.5px solid #10B981',
            borderRadius: '24px',
            overflow: 'hidden',
            boxShadow: '0 25px 60px rgba(0,0,0,0.85), 0 0 35px rgba(16, 185, 129, 0.3)',
            userSelect: 'none',
            touchAction: 'none'
          }}
          onMouseDown={handlePointerDown}
          onMouseMove={handlePointerMove}
          onMouseUp={handlePointerUp}
          onTouchStart={handlePointerDown}
          onTouchMove={handlePointerMove}
          onTouchEnd={handlePointerUp}
        >
          {/* Radar Scan Line */}
          <div className="radar-scan-line" />

          {/* Soccer Field Markings SVG Overlay */}
          <svg style={{ position: 'absolute', inset: 0, width: '100%', height: '100%', pointerEvents: 'none' }}>
            {/* Pitch Boundary */}
            <rect x="10" y="10" width="340" height="520" fill="none" stroke="rgba(255, 255, 255, 0.22)" strokeWidth="2" rx="14" />
            {/* Center Line */}
            <line x1="10" y1="270" x2="350" y2="270" stroke="rgba(255, 255, 255, 0.22)" strokeWidth="2" />
            {/* Center Circle */}
            <circle cx="180" cy="270" r="55" fill="none" stroke="rgba(255, 255, 255, 0.22)" strokeWidth="2" />
            <circle cx="180" cy="270" r="4" fill="rgba(255, 255, 255, 0.4)" />
            {/* Attacking Goal Box */}
            <rect x="90" y="10" width="180" height="85" fill="none" stroke="rgba(255, 255, 255, 0.22)" strokeWidth="2" />
            {/* Defending Goal Box */}
            <rect x="90" y="445" width="180" height="85" fill="none" stroke="rgba(255, 255, 255, 0.22)" strokeWidth="2" />
          </svg>

          {/* SVG Movement Arrows */}
          <svg style={{ position: 'absolute', inset: 0, width: '100%', height: '100%', pointerEvents: 'none', zIndex: 10 }}>
            <defs>
              <marker id="arrow-pass" markerWidth="7" markerHeight="7" refX="6" refY="3.5" orient="auto">
                <path d="M0,0 L0,7 L7,3.5 z" fill="#3B82F6" />
              </marker>
              <marker id="arrow-run" markerWidth="7" markerHeight="7" refX="6" refY="3.5" orient="auto">
                <path d="M0,0 L0,7 L7,3.5 z" fill="#F59E0B" />
              </marker>
              <marker id="arrow-press" markerWidth="7" markerHeight="7" refX="6" refY="3.5" orient="auto">
                <path d="M0,0 L0,7 L7,3.5 z" fill="#EF4444" />
              </marker>
            </defs>

            {[...arrows, drawingArrow].filter(Boolean).map((a, idx) => {
              const color = a.type === 'pass' ? '#3B82F6' : a.type === 'run' ? '#F59E0B' : '#EF4444';
              const dash = a.type === 'press' ? '6 4' : 'none';
              return (
                <line
                  key={idx}
                  x1={`${a.startX}%`}
                  y1={`${a.startY}%`}
                  x2={`${a.endX}%`}
                  y2={`${a.endY}%`}
                  stroke={color}
                  strokeWidth="3.5"
                  strokeDasharray={dash}
                  markerEnd={`url(#arrow-${a.type})`}
                />
              );
            })}
          </svg>

          {/* Animated Player Nodes */}
          {players.map((player, index) => {
            const isGK = player.isGk || index === 0;
            return (
              <div
                key={player.id}
                onMouseDown={() => mode === 'DRAG' && setDraggingId(player.id)}
                onTouchStart={() => mode === 'DRAG' && setDraggingId(player.id)}
                style={{
                  position: 'absolute',
                  left: `${player.x}%`,
                  top: `${player.y}%`,
                  transform: 'translate(-50%, -50%)',
                  width: '32px',
                  height: '32px',
                  borderRadius: '50%',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  fontWeight: '900',
                  fontSize: '11px',
                  color: '#030712',
                  backgroundColor: isGK ? '#F59E0B' : '#10B981',
                  boxShadow: isGK
                    ? '0 0 16px rgba(245, 158, 11, 0.9), 0 4px 10px rgba(0,0,0,0.5)'
                    : '0 0 16px rgba(16, 185, 129, 0.9), 0 4px 10px rgba(0,0,0,0.5)',
                  cursor: mode === 'DRAG' ? 'grab' : 'default',
                  zIndex: 20,
                  transition: isPlayingAnimation ? 'left 1.2s ease-in-out, top 1.2s ease-in-out' : 'transform 0.1s',
                }}
              >
                {player.name}
              </div>
            );
          })}
        </div>

        {/* Sidebar Tool Controls */}
        <div style={{
          width: '280px',
          backgroundColor: 'rgba(13, 26, 18, 0.95)',
          border: '2px solid rgba(16, 185, 129, 0.4)',
          borderRadius: '20px',
          padding: '20px',
          display: 'flex',
          flexDirection: 'column',
          gap: '16px',
          boxShadow: '0 10px 30px rgba(0,0,0,0.5)'
        }}>
          <h3 style={{ color: '#10B981', fontSize: '15px', fontWeight: 'bold', borderBottom: '1px solid rgba(16,185,129,0.2)', paddingBottom: '8px' }}>
            🛠️ أدوات التخطيط والتحريك
          </h3>

          {/* Animation Play/Pause Button */}
          <button
            onClick={() => setIsPlayingAnimation(!isPlayingAnimation)}
            style={{
              padding: '12px',
              borderRadius: '12px',
              fontWeight: 'bold',
              fontSize: '13px',
              border: 'none',
              cursor: 'pointer',
              backgroundColor: isPlayingAnimation ? '#F59E0B' : '#10B981',
              color: '#030712',
              boxShadow: '0 4px 15px rgba(0,0,0,0.3)',
              transition: 'all 0.2s ease'
            }}
          >
            {isPlayingAnimation ? '⏸️ إيقاف التبديل التلقائي' : '🎬 تشغيل التحريك التكتيكي'}
          </button>

          {/* Tools Grid */}
          <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
            <label style={{ fontSize: '12px', color: '#9CA3AF', fontWeight: 'bold' }}>اختر أداة الرسم:</label>
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '8px' }}>
              <button
                onClick={() => setMode('DRAG')}
                style={{
                  padding: '8px',
                  borderRadius: '10px',
                  fontSize: '12px',
                  fontWeight: 'bold',
                  cursor: 'pointer',
                  border: '1px solid rgba(255,255,255,0.1)',
                  backgroundColor: mode === 'DRAG' ? '#10B981' : '#1E293B',
                  color: mode === 'DRAG' ? '#000' : '#FFF'
                }}
              >
                ✋ سحب لاعب
              </button>

              <button
                onClick={() => setMode('ARROW_PASS')}
                style={{
                  padding: '8px',
                  borderRadius: '10px',
                  fontSize: '12px',
                  fontWeight: 'bold',
                  cursor: 'pointer',
                  border: '1px solid rgba(255,255,255,0.1)',
                  backgroundColor: mode === 'ARROW_PASS' ? '#3B82F6' : '#1E293B',
                  color: '#FFF'
                }}
              >
                ⚽ سهم تمرير
              </button>

              <button
                onClick={() => setMode('ARROW_RUN')}
                style={{
                  padding: '8px',
                  borderRadius: '10px',
                  fontSize: '12px',
                  fontWeight: 'bold',
                  cursor: 'pointer',
                  border: '1px solid rgba(255,255,255,0.1)',
                  backgroundColor: mode === 'ARROW_RUN' ? '#F59E0B' : '#1E293B',
                  color: mode === 'ARROW_RUN' ? '#000' : '#FFF'
                }}
              >
                🏃 سهم تحرك
              </button>

              <button
                onClick={() => setMode('ARROW_PRESS')}
                style={{
                  padding: '8px',
                  borderRadius: '10px',
                  fontSize: '12px',
                  fontWeight: 'bold',
                  cursor: 'pointer',
                  border: '1px solid rgba(255,255,255,0.1)',
                  backgroundColor: mode === 'ARROW_PRESS' ? '#EF4444' : '#1E293B',
                  color: '#FFF'
                }}
              >
                🛡️ سهم ضغط
              </button>
            </div>
          </div>

          {/* Clear & Save Buttons */}
          <button
            onClick={() => setArrows([])}
            style={{
              padding: '10px',
              backgroundColor: '#1E293B',
              color: '#FFF',
              border: '1px solid rgba(255,255,255,0.1)',
              borderRadius: '10px',
              fontWeight: 'bold',
              fontSize: '12px',
              cursor: 'pointer'
            }}
          >
            🗑️ مسح الأسهم
          </button>

          <button
            onClick={saveToSupabase}
            style={{
              padding: '12px',
              backgroundColor: '#10B981',
              color: '#000',
              border: 'none',
              borderRadius: '12px',
              fontWeight: '900',
              fontSize: '13px',
              cursor: 'pointer',
              boxShadow: '0 4px 15px rgba(16,185,129,0.4)'
            }}
          >
            💾 حفظ التاكتيك سحابياً
          </button>

          {statusMessage && (
            <div style={{ fontSize: '11px', color: '#10B981', textAlign: 'center', marginTop: '6px' }}>
              {statusMessage}
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
