-- Migration: Match Events Table for Live In-Match Captain Dashboard
-- Execute in Supabase SQL Editor

CREATE TABLE IF NOT EXISTS public.match_events (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  shift_id UUID REFERENCES public.captain_shifts(id) ON DELETE CASCADE,
  match_minute INT NOT NULL,
  event_type TEXT NOT NULL CHECK (event_type IN ('goal', 'yellow_card', 'red_card', 'substitution')),
  player_id TEXT NOT NULL,
  player_name TEXT NOT NULL,
  player_number INT NOT NULL,
  detail JSONB, -- Stores sub-off player info, assist, or card notes
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index for fast shift timeline lookups
CREATE INDEX IF NOT EXISTS idx_match_events_shift_id ON public.match_events(shift_id);

ALTER TABLE public.match_events ENABLE ROW LEVEL SECURITY;

-- Captain RLS Policy
CREATE POLICY "Captains manage own match events"
  ON public.match_events FOR ALL
  USING (
    auth.uid() IN (
      SELECT captain_id FROM public.captain_shifts WHERE id = shift_id
    )
  );
