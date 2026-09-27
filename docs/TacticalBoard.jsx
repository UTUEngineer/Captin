import React, { useState, useEffect } from 'react';
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
  '3-2-4-1': [
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
  '4-2-4': [
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
};

export default function TacticalBoard() {
  const [formationName, setFormationName] = useState('4-3-3');
  const [boardTitle, setBoardTitle] = useState('خطة الكابتن 4-3-3');
  const [players, setPlayers] = useState(FORMATION_PRESETS['4-3-3']);
  const [draggingId, setDraggingId] = useState(null);
  
  const [savedBoards, setSavedBoards] = useState([]);
  const [selectedBoardId, setSelectedBoardId] = useState('');
  const [isSaving, setIsSaving] = useState(false);
  const [statusMessage, setStatusMessage] = useState('');

  useEffect(() => {
    fetchSavedBoards();
  }, []);

  const fetchSavedBoards = async () => {
    try {
      const { data, error } = await supabase
        .from('tactical_boards')
        .select('*')
        .order('updated_at', { ascending: false });
      if (error) throw error;
      if (data) setSavedBoards(data);
    } catch (err) {
      console.warn("إشعار Supabase:", err.message);
    }
  };

  const handlePointerMove = (clientX, clientY, currentTarget) => {
    if (draggingId === null) return;
    const board = currentTarget.getBoundingClientRect();
    const x = Math.min(Math.max(0, ((clientX - board.left) / board.width) * 100), 100);
    const y = Math.min(Math.max(0, ((clientY - board.top) / board.height) * 100), 100);

    setPlayers((prev) =>
      prev.map((p) => (p.id === draggingId ? { ...p, x: Math.round(x), y: Math.round(y) } : p))
    );
  };

  const saveToSupabase = async () => {
    try {
      setIsSaving(true);
      setStatusMessage('');

      // الحصول على مستخدم Supabase الحالي لتفادي خطأ RLS
      const { data: { user } } = await supabase.auth.getUser();
      if (!user) {
        setStatusMessage('⚠️ يرجى تسجيل الدخول أولاً للحفظ.');
        setIsSaving(false);
        return;
      }

      const payload = {
        user_id: user.id, // تم إضافة معرف المستخدم هنا
        title: boardTitle || `خطة ${formationName}`,
        formation: formationName,
        pitch_type: '2D',
        board_data: { players },
        updated_at: new Date().toISOString(),
      };

      if (selectedBoardId) {
        const { error } = await supabase.from('tactical_boards').update(payload).eq('id', selectedBoardId);
        if (error) throw error;
      } else {
        const { data, error } = await supabase.from('tactical_boards').insert([payload]).select();
        if (error) throw error;
        if (data?.[0]) setSelectedBoardId(data[0].id);
      }

      setStatusMessage('✅ تم حفظ التشكيلة بنجاح في قاعدة البيانات!');
      fetchSavedBoards();
    } catch (err) {
      setStatusMessage(`⚠️ يتعذر الحفظ: ${err.message}`);
    } finally {
      setIsSaving(false);
    }
  };

  return (
    <div className="flex flex-col items-center justify-center min-h-screen bg-slate-900 text-white p-6 dir-rtl">
      <h1 className="text-2xl font-bold mb-4 text-emerald-400">لوحة التحكم التكتيكية - الكابتن</h1>
      
      {/* Control Inputs */}
      <div className="w-full max-w-[360px] mb-4 space-y-2">
        <input
          type="text"
          value={boardTitle}
          onChange={(e) => setBoardTitle(e.target.value)}
          placeholder="عنوان الخطة"
          className="w-full px-3 py-2 bg-slate-800 border border-slate-700 rounded-lg text-sm text-white focus:outline-none focus:border-emerald-500"
        />
        <select
          value={formationName}
          onChange={(e) => {
            setFormationName(e.target.value);
            setPlayers(FORMATION_PRESETS[e.target.value] || FORMATION_PRESETS['4-3-3']);
          }}
          className="w-full px-3 py-2 bg-slate-800 border border-slate-700 rounded-lg text-sm text-emerald-400 font-semibold focus:outline-none"
        >
          <option value="4-3-3">4-3-3 (أساسي)</option>
          <option value="3-2-4-1">3-2-4-1 (استحواذ)</option>
          <option value="4-2-4">4-2-4 (هجوم مكثف)</option>
        </select>
      </div>

      {/* Pitch Board */}
      <div
        className="relative w-[360px] h-[540px] bg-slate-800 border-2 border-emerald-500 rounded-xl overflow-hidden shadow-2xl cursor-pointer select-none touch-none"
        onMouseMove={(e) => handlePointerMove(e.clientX, e.clientY, e.currentTarget)}
        onTouchMove={(e) => e.touches.length && handlePointerMove(e.touches[0].clientX, e.touches[0].clientY, e.currentTarget)}
        onMouseUp={() => setDraggingId(null)}
        onTouchEnd={() => setDraggingId(null)}
      >
        <div className="absolute top-1/2 left-0 right-0 h-[2px] bg-white/20" />
        <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-24 h-24 border-2 border-white/20 rounded-full pointer-events-none" />

        {players.map((player) => (
          <div
            key={player.id}
            onMouseDown={() => setDraggingId(player.id)}
            onTouchStart={() => setDraggingId(player.id)}
            style={{ left: `${player.x}%`, top: `${player.y}%`, transform: 'translate(-50%, -50%)' }}
            className={`absolute w-8 h-8 rounded-full flex items-center justify-center font-bold text-xs cursor-grab active:cursor-grabbing shadow-lg select-none ${
              player.isGk ? 'bg-amber-400 text-black' : 'bg-emerald-400 text-slate-950'
            }`}
          >
            {player.name}
          </div>
        ))}
      </div>

      {statusMessage && <div className="mt-2 text-xs text-emerald-400 font-medium">{statusMessage}</div>}

      <div className="mt-4 flex gap-3">
        <button
          onClick={saveToSupabase}
          disabled={isSaving}
          className="px-6 py-2 bg-emerald-500 hover:bg-emerald-400 text-slate-950 font-bold rounded-lg transition"
        >
          {isSaving ? 'جاري الحفظ...' : 'حفظ في قاعدة البيانات 💾'}
        </button>
      </div>
    </div>
  );
}
