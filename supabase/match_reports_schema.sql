-- Migration: Match Reports Table for Post-Match Summary Report & Evaluation System
-- Execute in Supabase SQL Editor

CREATE TABLE IF NOT EXISTS public.match_reports (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  shift_id UUID REFERENCES public.captain_shifts(id) ON DELETE CASCADE,
  captain_id UUID REFERENCES public.captains(id) ON DELETE CASCADE,
  final_score_home INT NOT NULL,
  final_score_away INT NOT NULL,
  stats JSONB NOT NULL,          -- { possessionHome, possessionAway, shotsHome, shotsAway, foulsHome, foulsAway }
  player_evaluations JSONB NOT NULL, -- Array of { id, name, number, role, rating, notes, isMvp }
  mvp_player_id TEXT,
  match_outcome TEXT NOT NULL CHECK (match_outcome IN ('win', 'draw', 'loss')),
  submitted_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index for fast shift lookups
CREATE INDEX IF NOT EXISTS idx_match_reports_shift_id ON public.match_reports(shift_id);

ALTER TABLE public.match_reports ENABLE ROW LEVEL SECURITY;

-- Captain RLS Policy
CREATE POLICY "Captains manage own match reports"
  ON public.match_reports FOR ALL
  USING (auth.uid() = captain_id)
  WITH CHECK (auth.uid() = captain_id);
