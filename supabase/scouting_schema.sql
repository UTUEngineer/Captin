-- 1. EXTENSIONS
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 2. TEAMS TABLE
CREATE TABLE IF NOT EXISTS public.teams (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    api_football_id INTEGER UNIQUE,
    name TEXT NOT NULL,
    short_code VARCHAR(10),
    league_name TEXT NOT NULL, -- e.g. 'Iraq Stars League', 'Premier League'
    country TEXT NOT NULL DEFAULT 'Iraq',
    logo_url TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. PLAYERS TABLE
CREATE TABLE IF NOT EXISTS public.players (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    api_football_id INTEGER UNIQUE,
    team_id UUID REFERENCES public.teams(id) ON DELETE SET NULL,
    full_name TEXT NOT NULL,
    common_name TEXT NOT NULL,
    jersey_number INTEGER DEFAULT 0,
    primary_position VARCHAR(15) NOT NULL,
    secondary_positions TEXT[],
    nationality TEXT NOT NULL,
    age INTEGER,
    height_cm INTEGER,
    weight_kg INTEGER,
    preferred_foot VARCHAR(10) DEFAULT 'Right',
    market_value_eur BIGINT DEFAULT 0,
    contract_expires DATE,
    photo_url TEXT,
    tactical_archetype TEXT, -- e.g. 'Half-Space Penetrator'
    overall_rating INTEGER DEFAULT 75,
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. PLAYER TACTICAL ATTRIBUTES (Radar & In-Depth Sub-metrics)
CREATE TABLE IF NOT EXISTS public.player_attributes (
    player_id UUID PRIMARY KEY REFERENCES public.players(id) ON DELETE CASCADE,
    -- Hexagonal Radar 0-100
    pace INTEGER CHECK (pace BETWEEN 0 AND 100) DEFAULT 70,
    shooting INTEGER CHECK (shooting BETWEEN 0 AND 100) DEFAULT 70,
    passing INTEGER CHECK (passing BETWEEN 0 AND 100) DEFAULT 70,
    dribbling INTEGER CHECK (dribbling BETWEEN 0 AND 100) DEFAULT 70,
    defending INTEGER CHECK (defending BETWEEN 0 AND 100) DEFAULT 70,
    physical INTEGER CHECK (physical BETWEEN 0 AND 100) DEFAULT 70,
    -- Sub-metrics
    sprint_speed INTEGER DEFAULT 75,
    acceleration INTEGER DEFAULT 75,
    vision_xT INTEGER DEFAULT 75,
    close_dribbling INTEGER DEFAULT 75,
    finishing INTEGER DEFAULT 70,
    press_resistance INTEGER DEFAULT 75,
    defensive_work_rate INTEGER DEFAULT 60,
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. MATCH PERFORMANCE LOGS
CREATE TABLE IF NOT EXISTS public.player_match_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    player_id UUID REFERENCES public.players(id) ON DELETE CASCADE,
    match_date DATE NOT NULL,
    competition TEXT NOT NULL,
    opponent_name TEXT NOT NULL,
    rating NUMERIC(3, 1) CHECK (rating BETWEEN 1.0 AND 10.0),
    minutes_played INTEGER DEFAULT 90,
    goals INTEGER DEFAULT 0,
    assists INTEGER DEFAULT 0,
    passing_accuracy_pct INTEGER DEFAULT 80,
    duels_won TEXT DEFAULT '0/0',
    is_win BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 6. AI SCOUTING REPORTS (Generated via Claude 3.5 Sonnet)
CREATE TABLE IF NOT EXISTS public.ai_scouting_reports (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    player_id UUID REFERENCES public.players(id) ON DELETE CASCADE,
    key_tactical_strengths TEXT[] NOT NULL,
    defensive_vulnerabilities TEXT[] NOT NULL,
    pressing_triggers TEXT[] NOT NULL,
    counter_measure_summary TEXT NOT NULL,
    model_version VARCHAR(50) DEFAULT 'claude-3-5-sonnet',
    generated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 7. PERFORMANCE INDEXES
CREATE INDEX IF NOT EXISTS idx_players_team ON public.players(team_id);
CREATE INDEX IF NOT EXISTS idx_match_logs_player ON public.player_match_logs(player_id);
CREATE INDEX IF NOT EXISTS idx_scout_reports_player ON public.ai_scouting_reports(player_id);

-- 8. ROW LEVEL SECURITY (RLS)
ALTER TABLE public.teams ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.players ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.player_attributes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.player_match_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ai_scouting_reports ENABLE ROW LEVEL SECURITY;

-- Allow read-only access to all authenticated staff / coaches
CREATE POLICY "Public Read Access" ON public.teams FOR SELECT USING (true);
CREATE POLICY "Public Read Access" ON public.players FOR SELECT USING (true);
CREATE POLICY "Public Read Access" ON public.player_attributes FOR SELECT USING (true);
CREATE POLICY "Public Read Access" ON public.player_match_logs FOR SELECT USING (true);
CREATE POLICY "Public Read Access" ON public.ai_scouting_reports FOR SELECT USING (true);
