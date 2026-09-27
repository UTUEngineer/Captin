import React, { useState } from 'react';
import AuthComponent, { supabase } from './AuthComponent';
import TacticalBoard from './TacticalBoard';

export default function AppWithAuth() {
  const [currentUser, setCurrentUser] = useState(null);

  const handleLogout = async () => {
    await supabase.auth.signOut();
    setCurrentUser(null);
  };

  if (!currentUser) {
    return (
      <div className="min-h-screen bg-slate-900 flex items-center justify-center p-4">
        <AuthComponent onSessionActive={(user) => setCurrentUser(user)} />
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-slate-900 text-white">
      {/* Top Header Bar */}
      <div className="bg-slate-800 border-b border-slate-700 px-6 py-3 flex justify-between items-center dir-rtl">
        <div className="flex items-center gap-3">
          <span className="w-3 h-3 bg-emerald-400 rounded-full animate-pulse"></span>
          <span className="text-sm text-slate-300">
            الكابتن: <strong className="text-emerald-400">{currentUser.email}</strong>
          </span>
        </div>
        <button
          onClick={handleLogout}
          className="text-xs px-3 py-1.5 bg-red-500/20 text-red-400 hover:bg-red-500/30 border border-red-500/40 rounded-lg transition"
        >
          تسجيل الخروج
        </button>
      </div>

      {/* Main Tactical Board View */}
      <TacticalBoard user={currentUser} />
    </div>
  );
}
