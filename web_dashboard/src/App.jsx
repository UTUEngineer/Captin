import React, { useState } from 'react';
import TacticalBoardWithArrows from './TacticalBoardWithArrows';
import Tactical3DCanvas from './Tactical3DCanvas';
import PitchHomographyCalibration from './PitchHomographyCalibration';
import AIScoutingReport from './AIScoutingReport';
import AuthComponent, { supabase, SESSION_STORAGE_KEY } from './AuthComponent';

export default function App() {
  const [activeTab, setActiveTab] = useState('BOARD_3D'); // 'BOARD_2D' | 'BOARD_3D' | 'CALIBRATION' | 'SCOUTING' | 'AUTH'
  const [currentUser, setCurrentUser] = useState(() => {
    try {
      const saved = localStorage.getItem(SESSION_STORAGE_KEY);
      if (saved) return JSON.parse(saved);
    } catch (_) {}
    return {
      id: 'coach-demo-1',
      email: 'captain@captain.app',
      fullName: 'الكابتن الرئيسي'
    };
  });

  const handleLogout = async () => {
    try {
      localStorage.removeItem(SESSION_STORAGE_KEY);
      await supabase.auth.signOut();
    } catch (_) {}
    setCurrentUser(null);
    setActiveTab('AUTH');
  };

  return (
    <div style={{
      minHeight: '100vh',
      backgroundColor: '#060B08',
      color: '#FFFFFF',
      display: 'flex',
      flexDirection: 'column',
      direction: 'rtl'
    }}>
      {/* Top Header Bar */}
      <header style={{
        backgroundColor: 'rgba(12, 26, 18, 0.95)',
        borderBottom: '1.5px solid rgba(16, 185, 129, 0.3)',
        padding: '14px 24px',
        display: 'flex',
        justifyContent: 'space-between',
        alignItems: 'center',
        boxShadow: '0 4px 20px rgba(0,0,0,0.4)',
        flexWrap: 'wrap',
        gap: '12px'
      }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
          <span style={{ fontSize: '24px' }}>⚽</span>
          <div>
            <h1 style={{ fontSize: '18px', fontWeight: '900', color: '#FFFFFF', margin: 0 }}>
              الكابتن <span style={{ color: '#10B981' }}>/ EL CAPTAIN</span>
            </h1>
            <p style={{ fontSize: '11px', color: '#9CA3AF', margin: 0 }}>
              {currentUser ? `أهلاً بك: ${currentUser.fullName || currentUser.email}` : 'منصة التخطيط والتحليل التكتيكي الرقمي (2D / 3D)'}
            </p>
          </div>
        </div>

        {/* Header Right Actions & Tab Switcher */}
        <div style={{ display: 'flex', alignItems: 'center', gap: '8px', flexWrap: 'wrap' }}>
          <div style={{ display: 'flex', gap: '4px', backgroundColor: '#030712', padding: '4px', borderRadius: '12px', border: '1px solid rgba(255,255,255,0.1)' }}>
            <button
              onClick={() => setActiveTab('BOARD_3D')}
              style={{
                padding: '8px 14px',
                borderRadius: '8px',
                fontWeight: 'bold',
                fontSize: '12px',
                border: 'none',
                cursor: 'pointer',
                backgroundColor: activeTab === 'BOARD_3D' ? '#10B981' : 'transparent',
                color: activeTab === 'BOARD_3D' ? '#000' : '#9CA3AF',
                transition: 'all 0.2s ease'
              }}
            >
              🎮 الملعب 3D WebGL
            </button>
            <button
              onClick={() => setActiveTab('BOARD_2D')}
              style={{
                padding: '8px 14px',
                borderRadius: '8px',
                fontWeight: 'bold',
                fontSize: '12px',
                border: 'none',
                cursor: 'pointer',
                backgroundColor: activeTab === 'BOARD_2D' ? '#10B981' : 'transparent',
                color: activeTab === 'BOARD_2D' ? '#000' : '#9CA3AF',
                transition: 'all 0.2s ease'
              }}
            >
              ⚽ السبورة 2D
            </button>
            <button
              onClick={() => setActiveTab('CALIBRATION')}
              style={{
                padding: '8px 14px',
                borderRadius: '8px',
                fontWeight: 'bold',
                fontSize: '12px',
                border: 'none',
                cursor: 'pointer',
                backgroundColor: activeTab === 'CALIBRATION' ? '#10B981' : 'transparent',
                color: activeTab === 'CALIBRATION' ? '#000' : '#9CA3AF',
                transition: 'all 0.2s ease'
              }}
            >
              📐 معايرة الفيديو
            </button>
            <button
              onClick={() => setActiveTab('SCOUTING')}
              style={{
                padding: '8px 14px',
                borderRadius: '8px',
                fontWeight: 'bold',
                fontSize: '12px',
                border: 'none',
                cursor: 'pointer',
                backgroundColor: activeTab === 'SCOUTING' ? '#10B981' : 'transparent',
                color: activeTab === 'SCOUTING' ? '#000' : '#9CA3AF',
                transition: 'all 0.2s ease'
              }}
            >
              📊 تقرير AI
            </button>
            <button
              onClick={() => setActiveTab('AUTH')}
              style={{
                padding: '8px 14px',
                borderRadius: '8px',
                fontWeight: 'bold',
                fontSize: '12px',
                border: 'none',
                cursor: 'pointer',
                backgroundColor: activeTab === 'AUTH' ? '#10B981' : 'transparent',
                color: activeTab === 'AUTH' ? '#000' : '#9CA3AF',
                transition: 'all 0.2s ease'
              }}
            >
              🔒 الحساب
            </button>
          </div>

          {currentUser && (
            <button
              onClick={handleLogout}
              style={{
                padding: '8px 12px',
                backgroundColor: 'rgba(239, 68, 68, 0.15)',
                color: '#F87171',
                border: '1px solid rgba(239, 68, 68, 0.3)',
                borderRadius: '10px',
                fontSize: '12px',
                fontWeight: 'bold',
                cursor: 'pointer',
                transition: 'all 0.2s ease'
              }}
            >
              خروج 🚪
            </button>
          )}
        </div>
      </header>

      {/* Main App Content View */}
      <main style={{ flex: 1, padding: '20px 16px', display: 'flex', justifyContent: 'center', alignItems: 'center' }}>
        {activeTab === 'BOARD_3D' && (
          <div style={{ width: '100%', maxWidth: '1200px' }}>
            <Tactical3DCanvas />
          </div>
        )}
        {activeTab === 'BOARD_2D' && <TacticalBoardWithArrows />}
        {activeTab === 'CALIBRATION' && <PitchHomographyCalibration />}
        {activeTab === 'SCOUTING' && <AIScoutingReport />}
        {activeTab === 'AUTH' && (
          <AuthComponent onSessionActive={(user) => {
            setCurrentUser(user);
            setActiveTab('BOARD_3D');
          }} />
        )}
      </main>

      {/* Footer */}
      <footer style={{
        textAlign: 'center',
        padding: '12px',
        fontSize: '11px',
        color: '#6B7280',
        borderTop: '1px solid rgba(255,255,255,0.05)',
        backgroundColor: '#030712'
      }}>
        جميع الحقوق محفوظة © {new Date().getFullYear()} الكابتن - EL CAPTAIN Tactical System (2D / 3D)
      </footer>
    </div>
  );
}
