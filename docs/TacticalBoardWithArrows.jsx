import React, { useState, useEffect, useRef } from 'react';
import { createClient } from '@supabase/supabase-js';

const SUPABASE_URL = process.env.REACT_APP_SUPABASE_URL || 'https://YOUR_SUPABASE_PROJECT_URL.supabase.co';
const SUPABASE_ANON_KEY = process.env.REACT_APP_SUPABASE_ANON_KEY || 'YOUR_SUPABASE_ANON_KEY';
const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

const FORMATION_PRESETS = {
  '4-3-3': [
    { id: 1, name: 'GK', x: 50, y: 88, isGk: true },
    { id: 2, name: 'RB', x: 85, y: 70 },
    { id: 3, name: 'CB', x: 62, y: 75 },
    { id: 4, name: 'CB', x: 38, y: 75 },
    { id: 5, name: 'LB', x: 15, y: 70 },
    { id: 6, name: 'CM', x: 50, y: 55 },
    { id: 7, name: 'CM', x: 70, y: 50 },
    { id: 8, name: 'CM', x: 30, y: 50 },
    { id: 9, name: 'RW', x: 80, y: 25 },
    { id: 10, name: 'ST', x: 50, y: 20 },
    { id: 11, name: 'LW', x: 20, y: 25 },
  ],
};

export default function TacticalBoardWithArrows() {
  const [players, setPlayers] = useState(FORMATION_PRESETS['4-3-3']);
  const [arrows, setArrows] = useState([]); // [{ startX, startY, endX, endY, type: 'pass'|'run'|'press' }]
  const [mode, setMode] = useState('DRAG'); // 'DRAG' | 'ARROW_PASS' | 'ARROW_RUN' | 'ARROW_PRESS'
  
  const [draggingId, setDraggingId] = useState(null);
  const [drawingArrow, setDrawingArrow] = useState(null);
  const [boardTitle, setBoardTitle] = useState('خطة تكتيكية مع التحركات');
  const [statusMessage, setStatusMessage] = useState('');
  const pitchRef = useRef(null);

  // حساب الإحداثيات بالنسبة المئوية للملعب
  const getCoordinates = (e) => {
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
      // حفظ السهم إذا كان طوله مناسباً
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
      const { data: { user } } = await supabase.auth.getUser();
      if (!user) {
        setStatusMessage('⚠️ يرجى تسجيل الدخول للحفظ.');
        return;
      }

      const payload = {
        user_id: user.id,
        title: boardTitle,
        formation: 'Custom',
        pitch_type: '2D_Motion',
        board_data: { players, arrows },
        updated_at: new Date().toISOString(),
      };

      const { error } = await supabase.from('tactical_boards').insert([payload]);
      if (error) throw error;
      setStatusMessage('✅ تم حفظ التشكيلة والأسهم التكتيكية بنجاح!');
    } catch (err) {
      setStatusMessage(`⚠️ خطأ: ${err.message}`);
    }
  };

  return (
    <div className="flex flex-col items-center justify-center min-h-screen bg-slate-900 text-white p-6 dir-rtl">
      <h1 className="text-xl font-bold mb-3 text-emerald-400">صانع التاكتيك والتحركات - الكابتن</h1>
      
      {/* Control Tools */}
      <div className="w-full max-w-[360px] mb-3 space-y-2">
        <input
          type="text"
          value={boardTitle}
          onChange={(e) => setBoardTitle(e.target.value)}
          className="w-full px-3 py-1.5 bg-slate-800 border border-slate-700 rounded text-sm text-white focus:outline-none focus:border-emerald-500"
        />
        <div className="grid grid-cols-4 gap-1">
          <button
            onClick={() => setMode('DRAG')}
            className={`py-1 text-xs rounded font-bold transition ${mode === 'DRAG' ? 'bg-emerald-500 text-black' : 'bg-slate-800 text-gray-300'}`}
          >
            تحريك
          </button>
          <button
            onClick={() => setMode('ARROW_PASS')}
            className={`py-1 text-xs rounded font-bold transition ${mode === 'ARROW_PASS' ? 'bg-blue-500 text-white' : 'bg-slate-800 text-gray-300'}`}
          >
            تمرير ⚽
          </button>
          <button
            onClick={() => setMode('ARROW_RUN')}
            className={`py-1 text-xs rounded font-bold transition ${mode === 'ARROW_RUN' ? 'bg-amber-500 text-black' : 'bg-slate-800 text-gray-300'}`}
          >
            ركض 🏃
          </button>
          <button
            onClick={() => setMode('ARROW_PRESS')}
            className={`py-1 text-xs rounded font-bold transition ${mode === 'ARROW_PRESS' ? 'bg-red-500 text-white' : 'bg-slate-800 text-gray-300'}`}
          >
            ضغط 🛡️
          </button>
        </div>
      </div>

      {/* Pitch Board Canvas */}
      <div
        ref={pitchRef}
        className="relative w-[360px] h-[540px] bg-slate-800 border-2 border-emerald-500 rounded-xl overflow-hidden shadow-2xl select-none touch-none"
        onMouseDown={handlePointerDown}
        onMouseMove={handlePointerMove}
        onMouseUp={handlePointerUp}
        onTouchStart={handlePointerDown}
        onTouchMove={handlePointerMove}
        onTouchEnd={handlePointerUp}
      >
        {/* SVG Drawing Layer for Arrows */}
        <svg className="absolute inset-0 w-full h-full pointer-events-none z-10">
          <defs>
            <marker id="arrow-pass" markerWidth="6" markerHeight="6" refX="5" refY="3" orient="auto">
              <path d="M0,0 L0,6 L6,3 z" fill="#3B82F6" />
            </marker>
            <marker id="arrow-run" markerWidth="6" markerHeight="6" refX="5" refY="3" orient="auto">
              <path d="M0,0 L0,6 L6,3 z" fill="#F59E0B" />
            </marker>
            <marker id="arrow-press" markerWidth="6" markerHeight="6" refX="5" refY="3" orient="auto">
              <path d="M0,0 L0,6 L6,3 z" fill="#EF4444" />
            </marker>
          </defs>

          {/* Draw Existing Arrows */}
          {[...arrows, drawingArrow].filter(Boolean).map((a, idx) => {
            const color = a.type === 'pass' ? '#3B82F6' : a.type === 'run' ? '#F59E0B' : '#EF4444';
            const dash = a.type === 'press' ? '4 4' : 'none';
            return (
              <line
                key={idx}
                x1={`${a.startX}%`}
                y1={`${a.startY}%`}
                x2={`${a.endX}%`}
                y2={`${a.endY}%`}
                stroke={color}
                strokeWidth="3"
                strokeDasharray={dash}
                markerEnd={`url(#arrow-${a.type})`}
              />
            );
          })}
        </svg>

        {/* Pitch Lines */}
        <div className="absolute top-1/2 left-0 right-0 h-[2px] bg-white/20" />
        <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-24 h-24 border-2 border-white/20 rounded-full" />

        {/* Players Layer */}
        {players.map((player) => (
          <div
            key={player.id}
            onMouseDown={() => mode === 'DRAG' && setDraggingId(player.id)}
            onTouchStart={() => mode === 'DRAG' && setDraggingId(player.id)}
            style={{ left: `${player.x}%`, top: `${player.y}%`, transform: 'translate(-50%, -50%)' }}
            className={`absolute w-8 h-8 rounded-full flex items-center justify-center font-bold text-xs shadow-lg z-20 ${
              mode === 'DRAG' ? 'cursor-grab active:cursor-grabbing' : ''
            } ${player.isGk ? 'bg-amber-400 text-black' : 'bg-emerald-400 text-slate-950'}`}
          >
            {player.name}
          </div>
        ))}
      </div>

      {statusMessage && <div className="mt-2 text-xs text-emerald-400 font-medium">{statusMessage}</div>}

      <div className="mt-3 flex gap-2">
        <button
          onClick={() => setArrows([])}
          className="px-4 py-1.5 bg-slate-700 hover:bg-slate-600 text-white font-semibold text-xs rounded transition"
        >
          مسح الأسهم 🗑️
        </button>
        <button
          onClick={saveToSupabase}
          className="px-6 py-1.5 bg-emerald-500 hover:bg-emerald-400 text-slate-950 font-bold text-xs rounded transition"
        >
          حفظ التاكتيك 💾
        </button>
      </div>
    </div>
  );
}
