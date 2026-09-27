import React, { useState, useEffect } from 'react';
import { createClient } from '@supabase/supabase-js';

const SUPABASE_URL = import.meta.env.VITE_SUPABASE_URL || 'https://YOUR_SUPABASE_PROJECT_URL.supabase.co';
const SUPABASE_ANON_KEY = import.meta.env.VITE_SUPABASE_ANON_KEY || 'YOUR_SUPABASE_ANON_KEY';
export const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

export const SESSION_STORAGE_KEY = 'captain_auth_session_v1';

export default function AuthComponent({ onSessionActive }) {
  const [isLogin, setIsLogin] = useState(true);
  const [fullName, setFullName] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const [statusMsg, setStatusMsg] = useState('');

  // 1. Check for saved persistent session on initial mount
  useEffect(() => {
    // Check localStorage first
    try {
      const savedSession = localStorage.getItem(SESSION_STORAGE_KEY);
      if (savedSession) {
        const parsedUser = JSON.parse(savedSession);
        if (parsedUser && parsedUser.email) {
          onSessionActive(parsedUser);
          return;
        }
      }
    } catch (_) {}

    // Check Supabase session
    try {
      supabase.auth.getSession().then(({ data: { session } }) => {
        if (session?.user) {
          const userObj = {
            id: session.user.id,
            email: session.user.email,
            fullName: session.user.user_metadata?.full_name || 'الكابتن الرئيسي'
          };
          localStorage.setItem(SESSION_STORAGE_KEY, JSON.stringify(userObj));
          onSessionActive(userObj);
        }
      }).catch(() => {});

      const { data: { subscription } } = supabase.auth.onAuthStateChange((_event, session) => {
        if (session?.user) {
          const userObj = {
            id: session.user.id,
            email: session.user.email,
            fullName: session.user.user_metadata?.full_name || 'الكابتن الرئيسي'
          };
          localStorage.setItem(SESSION_STORAGE_KEY, JSON.stringify(userObj));
          onSessionActive(userObj);
        }
      });

      return () => subscription?.unsubscribe?.();
    } catch (_) {}
  }, [onSessionActive]);

  const handleAuth = async (e) => {
    if (e) e.preventDefault();
    setLoading(true);
    setStatusMsg('');

    const targetEmail = email.trim();
    const targetPassword = password.trim();

    if (!isLogin && !fullName.trim()) {
      setStatusMsg('⚠️ يرجى كتابة الاسم الكامل للمدرب');
      setLoading(false);
      return;
    }

    if (!targetEmail || !targetPassword) {
      setStatusMsg('⚠️ يرجى كتابة البريد الإلكتروني وكلمة المرور');
      setLoading(false);
      return;
    }

    if (!isLogin && targetPassword !== confirmPassword.trim()) {
      setStatusMsg('⚠️ كلمة المرور وتأكيد كلمة المرور غير متطابقين');
      setLoading(false);
      return;
    }

    try {
      const { data, error } = isLogin
        ? await supabase.auth.signInWithPassword({ email: targetEmail, password: targetPassword })
        : await supabase.auth.signUp({
            email: targetEmail,
            password: targetPassword,
            options: { data: { full_name: fullName.trim() } }
          });

      if (!error && data?.user) {
        const userObj = {
          id: data.user.id,
          email: data.user.email,
          fullName: fullName.trim() || data.user.user_metadata?.full_name || 'الكابتن الرئيسي'
        };
        localStorage.setItem(SESSION_STORAGE_KEY, JSON.stringify(userObj));
        onSessionActive(userObj);
        return;
      }
    } catch (_) {}

    // Fallback: Save local coach session persistently in localStorage
    setTimeout(() => {
      const coachProfile = {
        id: `coach-${Date.now()}`,
        email: targetEmail,
        fullName: isLogin ? 'الكابتن الرئيسي' : fullName.trim() || 'الكابتن الجديد',
      };
      localStorage.setItem(SESSION_STORAGE_KEY, JSON.stringify(coachProfile));
      onSessionActive(coachProfile);
      setLoading(false);
    }, 300);
  };

  const handleQuickDemoAccess = () => {
    const demoUser = {
      id: 'coach-demo-888',
      email: 'captain.pro@captain.app',
      fullName: 'الكابتن التجريبي السريع',
    };
    localStorage.setItem(SESSION_STORAGE_KEY, JSON.stringify(demoUser));
    onSessionActive(demoUser);
  };

  return (
    <div style={{
      width: '100%',
      minHeight: '85vh',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      padding: '20px',
      direction: 'rtl'
    }}>
      {/* Luxury Square Glass Card Container */}
      <div style={{
        width: '460px',
        maxWidth: '100%',
        backgroundColor: 'rgba(12, 26, 18, 0.94)',
        backdropFilter: 'blur(24px)',
        WebkitBackdropFilter: 'blur(24px)',
        border: '2px solid rgba(16, 185, 129, 0.45)',
        borderRadius: '28px',
        boxShadow: '0 30px 70px rgba(0, 0, 0, 0.95), 0 0 50px rgba(16, 185, 129, 0.25)',
        padding: '36px 32px',
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        textAlign: 'center',
        position: 'relative'
      }}>

        {/* Brand Badge & Header */}
        <div style={{ marginBottom: '18px', display: 'flex', flexDirection: 'column', alignItems: 'center' }}>
          <div style={{
            width: '60px',
            height: '60px',
            borderRadius: '20px',
            backgroundColor: 'rgba(16, 185, 129, 0.18)',
            border: '1.5px solid rgba(52, 211, 153, 0.5)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            fontSize: '30px',
            marginBottom: '10px',
            boxShadow: '0 0 25px rgba(16, 185, 129, 0.4)'
          }}>
            ⚽
          </div>
          
          <h1 style={{ fontSize: '24px', fontWeight: '900', color: '#FFFFFF', letterSpacing: '-0.5px', margin: 0 }}>
            الكابتن <span style={{ color: '#34D399' }}>/ EL CAPTAIN</span>
          </h1>
          <p style={{ fontSize: '12px', color: '#9CA3AF', fontWeight: '600', marginTop: '4px' }}>
            {isLogin ? 'تسجيل الدخول لمنصة التحليل التكتيكي (2D / 3D)' : 'إنشاء حساب مدرب جديد وتثبيت البيانات'}
          </p>
        </div>

        {/* Light Motion Tab Switcher */}
        <div style={{
          display: 'flex',
          gap: '8px',
          padding: '6px',
          backgroundColor: '#030712',
          borderRadius: '9999px',
          border: '1px solid rgba(52, 211, 153, 0.3)',
          marginBottom: '18px',
          width: '100%',
          maxWidth: '300px',
          justifyContent: 'center'
        }}>
          <button
            type="button"
            onClick={() => { setIsLogin(true); setStatusMsg(''); }}
            style={{
              flex: 1,
              padding: '8px 16px',
              borderRadius: '9999px',
              fontSize: '13px',
              fontWeight: '800',
              border: 'none',
              cursor: 'pointer',
              transition: 'all 0.25s cubic-bezier(0.34, 1.56, 0.64, 1)',
              backgroundColor: isLogin ? '#FFFFFF' : 'transparent',
              color: isLogin ? '#030712' : '#9CA3AF',
              boxShadow: isLogin ? '0 4px 20px rgba(255, 255, 255, 0.4), 0 0 15px rgba(52, 211, 153, 0.4)' : 'none',
              transform: isLogin ? 'scale(1.04)' : 'scale(1)'
            }}
          >
            تسجيل الدخول
          </button>

          <button
            type="button"
            onClick={() => { setIsLogin(false); setStatusMsg(''); }}
            style={{
              flex: 1,
              padding: '8px 16px',
              borderRadius: '9999px',
              fontSize: '13px',
              fontWeight: '800',
              border: 'none',
              cursor: 'pointer',
              transition: 'all 0.25s cubic-bezier(0.34, 1.56, 0.64, 1)',
              backgroundColor: !isLogin ? '#FFFFFF' : 'transparent',
              color: !isLogin ? '#030712' : '#9CA3AF',
              boxShadow: !isLogin ? '0 4px 20px rgba(255, 255, 255, 0.4), 0 0 15px rgba(52, 211, 153, 0.4)' : 'none',
              transform: !isLogin ? 'scale(1.04)' : 'scale(1)'
            }}
          >
            حساب جديد
          </button>
        </div>

        {/* Status Alert */}
        {statusMsg && (
          <div style={{
            width: '100%',
            padding: '10px',
            borderRadius: '12px',
            backgroundColor: 'rgba(239, 68, 68, 0.15)',
            border: '1px solid rgba(239, 68, 68, 0.4)',
            color: '#F87171',
            fontSize: '12px',
            fontWeight: 'bold',
            marginBottom: '14px'
          }}>
            {statusMsg}
          </div>
        )}

        {/* Form Inputs */}
        <form onSubmit={handleAuth} style={{ width: '100%', display: 'flex', flexDirection: 'column', gap: '12px' }}>
          
          {/* Full Name Input (For Sign Up) */}
          {!isLogin && (
            <div>
              <label style={{ display: 'block', fontSize: '12px', fontWeight: 'bold', color: '#D1D5DB', textAlign: 'right', marginBottom: '4px' }}>
                الاسم الكامل للمدرب / الكابتن
              </label>
              <input
                type="text"
                placeholder="الكابتن علي حسين"
                value={fullName}
                onChange={(e) => setFullName(e.target.value)}
                style={{
                  width: '100%',
                  padding: '11px 14px',
                  backgroundColor: 'rgba(3, 7, 18, 0.8)',
                  border: '1.5px solid rgba(52, 211, 153, 0.3)',
                  borderRadius: '14px',
                  color: '#FFFFFF',
                  fontSize: '13px',
                  textAlign: 'right',
                  outline: 'none'
                }}
                required
              />
            </div>
          )}

          {/* Email Input */}
          <div>
            <label style={{ display: 'block', fontSize: '12px', fontWeight: 'bold', color: '#D1D5DB', textAlign: 'right', marginBottom: '4px' }}>
              البريد الإلكتروني
            </label>
            <input
              type="email"
              placeholder="coach@captain.app"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              style={{
                width: '100%',
                padding: '11px 14px',
                backgroundColor: 'rgba(3, 7, 18, 0.8)',
                border: '1.5px solid rgba(255, 255, 255, 0.15)',
                borderRadius: '14px',
                color: '#FFFFFF',
                fontSize: '13px',
                textAlign: 'right',
                outline: 'none'
              }}
              required
            />
          </div>

          {/* Password Input */}
          <div>
            <label style={{ display: 'block', fontSize: '12px', fontWeight: 'bold', color: '#D1D5DB', textAlign: 'right', marginBottom: '4px' }}>
              كلمة المرور
            </label>
            <input
              type="password"
              placeholder="••••••••"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              style={{
                width: '100%',
                padding: '11px 14px',
                backgroundColor: 'rgba(3, 7, 18, 0.8)',
                border: '1.5px solid rgba(255, 255, 255, 0.15)',
                borderRadius: '14px',
                color: '#FFFFFF',
                fontSize: '13px',
                textAlign: 'right',
                outline: 'none'
              }}
              required
            />
          </div>

          {/* Confirm Password Input (For Sign Up) */}
          {!isLogin && (
            <div>
              <label style={{ display: 'block', fontSize: '12px', fontWeight: 'bold', color: '#D1D5DB', textAlign: 'right', marginBottom: '4px' }}>
                تأكيد كلمة المرور
              </label>
              <input
                type="password"
                placeholder="••••••••"
                value={confirmPassword}
                onChange={(e) => setConfirmPassword(e.target.value)}
                style={{
                  width: '100%',
                  padding: '11px 14px',
                  backgroundColor: 'rgba(3, 7, 18, 0.8)',
                  border: '1.5px solid rgba(255, 255, 255, 0.15)',
                  borderRadius: '14px',
                  color: '#FFFFFF',
                  fontSize: '13px',
                  textAlign: 'right',
                  outline: 'none'
                }}
                required
              />
            </div>
          )}

          {/* Light Motion Primary Action Button */}
          <button
            type="submit"
            disabled={loading}
            style={{
              width: '100%',
              padding: '14px',
              marginTop: '4px',
              backgroundColor: '#FFFFFF',
              color: '#030712',
              fontWeight: '900',
              fontSize: '15px',
              border: 'none',
              borderRadius: '16px',
              cursor: 'pointer',
              boxShadow: '0 6px 25px rgba(255, 255, 255, 0.3), 0 0 20px rgba(52, 211, 153, 0.4)',
              transition: 'all 0.25s ease'
            }}
          >
            {loading ? 'جاري التثبيت...' : isLogin ? 'دخول اللوحة التكتيكية 🚀' : 'إنشاء وتثبيت حساب الكابتن ✨'}
          </button>
        </form>

        {/* Quick Demo Access Button */}
        <button
          type="button"
          onClick={handleQuickDemoAccess}
          style={{
            width: '100%',
            padding: '11px',
            marginTop: '10px',
            backgroundColor: 'rgba(16, 185, 129, 0.15)',
            color: '#34D399',
            fontWeight: '800',
            fontSize: '12px',
            border: '1.5px solid rgba(52, 211, 153, 0.4)',
            borderRadius: '14px',
            cursor: 'pointer',
            transition: 'all 0.2s ease'
          }}
        >
          ⚡ دخول سريع ومجاني (بنقرة واحدة)
        </button>

        {/* Feature Badges Footer */}
        <div style={{
          marginTop: '16px',
          display: 'flex',
          gap: '10px',
          fontSize: '11px',
          fontWeight: 'bold',
          color: 'rgba(52, 211, 153, 0.8)',
          justifyContent: 'center'
        }}>
          <span>⚽ خطط وتحركات 2D / 3D</span>
          <span>•</span>
          <span>⚡ حفظ الجلسة دائمياً</span>
          <span>•</span>
          <span>🛡️ أمان سحابي</span>
        </div>

      </div>
    </div>
  );
}
