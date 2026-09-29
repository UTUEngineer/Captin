-- 1. EXTENSIONS
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 2. CAPTAINS PROFILE TABLE
CREATE TABLE IF NOT EXISTS public.captains (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  full_name TEXT NOT NULL,
  jersey_number INT NOT NULL DEFAULT 10,
  armband_tier TEXT NOT NULL CHECK (armband_tier IN ('First Team', 'Sunday League', 'Academy')),
  team_name TEXT DEFAULT 'Az-Zawra''a SC',
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. CAPTAIN MATCHDAY SESSIONS TABLE
CREATE TABLE IF NOT EXISTS public.captain_shifts (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  captain_id UUID REFERENCES public.captains(id) ON DELETE CASCADE,
  status TEXT NOT NULL DEFAULT 'online' CHECK (status IN ('online', 'in_match', 'offline')),
  tier TEXT NOT NULL,
  kick_score_telemetry JSONB,
  started_at TIMESTAMPTZ DEFAULT NOW(),
  ended_at TIMESTAMPTZ
);

-- 4. ROW LEVEL SECURITY (RLS) POLICIES
ALTER TABLE public.captains ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.captain_shifts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Captains can view their own profile"
  ON public.captains FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Captains can view and insert their own shifts"
  ON public.captain_shifts FOR ALL
  USING (auth.uid() = captain_id)
  WITH CHECK (auth.uid() = captain_id);
