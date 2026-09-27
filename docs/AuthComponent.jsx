import React, { useState, useEffect } from 'react';
import { createClient } from '@supabase/supabase-js';

const SUPABASE_URL = process.env.REACT_APP_SUPABASE_URL || 'https://YOUR_SUPABASE_PROJECT_URL.supabase.co';
const SUPABASE_ANON_KEY = process.env.REACT_APP_SUPABASE_ANON_KEY || 'YOUR_SUPABASE_ANON_KEY';
export const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

export default function AuthComponent({ onSessionActive }) {
  const [isLogin, setIsLogin] = useState(true);
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const [errorMsg, setErrorMsg] = useState('');

  useEffect(() => {
    supabase.auth.getSession().then(({ data: { session } }) => {
      if (session) onSessionActive(session.user);
    });

    const { data: { subscription } } = supabase.auth.onAuthStateChange((_event, session) => {
      if (session) onSessionActive(session.user);
    });

    return () => subscription.unsubscribe();
  }, [onSessionActive]);

  const handleAuth = async (e) => {
    e.preventDefault();
    if (!email || !password) {
      setErrorMsg('يرجى كتابة البريد الإلكتروني وكلمة المرور');
      return;
    }

    setLoading(true);
    setErrorMsg('');
    try {
      const { data, error } = isLogin
        ? await supabase.auth.signInWithPassword({ email, password })
        : await supabase.auth.signUp({ email, password });

      if (error) throw error;
      if (data.user) onSessionActive(data.user);
    } catch (err) {
      setErrorMsg(err.message || 'حدث خطأ أثناء عملية الدخول');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="relative z-10 flex flex-col items-center justify-center w-full min-h-screen p-4">
      {/* Elegant Square Glass Card Container */}
      <div className="square-glass-card">
        
        {/* Brand Icon & Title - Centered */}
        <div className="text-center mb-5">
          <div className="inline-flex items-center justify-center p-3 mb-2 rounded-2xl bg-emerald-500/15 border border-emerald-400/30">
            <span className="text-2xl">⚽</span>
          </div>
          <h1 className="text-2xl font-black text-white tracking-tight">
            الكابتن <span className="text-emerald-400">/ EL CAPTAIN</span>
          </h1>
          <p className="text-xs text-gray-400 font-medium mt-1">
            المنصة الرقمية للتحليل والتخطيط التكتيكي
          </p>
        </div>

        {/* Center Light Motion Toggle Buttons */}
        <div className="flex items-center justify-center gap-2 p-1.5 mb-5 bg-slate-900/90 rounded-full border border-slate-700/60 shadow-inner">
          <button
            type="button"
            onClick={() => { setIsLogin(true); setErrorMsg(''); }}
            className={`motion-tab-light ${isLogin ? 'active' : ''}`}
          >
            تسجيل الدخول
          </button>
          <button
            type="button"
            onClick={() => { setIsLogin(false); setErrorMsg(''); }}
            className={`motion-tab-light ${!isLogin ? 'active' : ''}`}
          >
            حساب جديد
          </button>
        </div>

        {/* Error Alert */}
        {errorMsg && (
          <div className="w-full mb-3 p-2.5 rounded-xl bg-red-500/15 border border-red-500/30 text-red-300 text-xs font-semibold text-center">
            ⚠️ {errorMsg}
          </div>
        )}

        {/* Form Inputs - Centered Layout */}
        <form onSubmit={handleAuth} className="w-full space-y-3.5">
          <div>
            <input
              type="email"
              placeholder="البريد الإلكتروني (coach@captain.app)"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              className="custom-input-centered"
              required
            />
          </div>

          <div>
            <input
              type="password"
              placeholder="كلمة المرور (••••••••)"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              className="custom-input-centered"
              required
            />
          </div>

          {/* Light Motion Action Button */}
          <button
            type="submit"
            disabled={loading}
            className="btn-motion-light mt-2"
          >
            {loading ? (
              <span className="inline-flex items-center gap-2">
                <svg className="animate-spin h-5 w-5 text-slate-950" viewBox="0 0 24 24">
                  <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4" fill="none"></circle>
                  <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z"></path>
                </svg>
                جاري التحقق...
              </span>
            ) : (
              <span>{isLogin ? 'دخول اللوحة التكتيكية 🚀' : 'إنشاء حساب الكابتن ✨'}</span>
            )}
          </button>
        </form>

        {/* Footer Pill Badges */}
        <div className="mt-5 flex items-center justify-center gap-3 text-[11px] font-semibold text-gray-400">
          <span>⚡ مزامنة فوريّة</span>
          <span>•</span>
          <span>⚽ خطط 2D/3D</span>
          <span>•</span>
          <span>🛡️ أمان سحابي</span>
        </div>
      </div>
    </div>
  );
}
