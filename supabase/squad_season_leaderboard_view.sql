-- Create an aggregated view for squad leaderboard stats
CREATE OR REPLACE VIEW public.squad_season_leaderboard AS
WITH player_ratings_flat AS (
  SELECT 
    mr.captain_id,
    p->>'id' AS player_id,
    p->>'name' AS player_name,
    (p->>'number')::INT AS jersey_number,
    p->>'role' AS role,
    (p->>'rating')::NUMERIC AS rating,
    (p->>'isMvp')::BOOLEAN AS is_mvp
  FROM public.match_reports mr,
  jsonb_array_elements(mr.player_evaluations) AS p
),
event_counts AS (
  SELECT
    player_id,
    COUNT(CASE WHEN event_type = 'goal' THEN 1 END) AS total_goals,
    COUNT(CASE WHEN event_type = 'yellow_card' THEN 1 END) AS total_yellows,
    COUNT(CASE WHEN event_type = 'red_card' THEN 1 END) AS total_reds
  FROM public.match_events
  GROUP BY player_id
)
SELECT 
  prf.captain_id,
  prf.player_id,
  prf.player_name,
  prf.jersey_number,
  prf.role,
  COUNT(prf.rating) AS appearances,
  ROUND(AVG(prf.rating), 2) AS avg_rating,
  COUNT(CASE WHEN prf.is_mvp THEN 1 END) AS mvp_count,
  COALESCE(ec.total_goals, 0) AS goals,
  -- Derive simulated/stored assists
  FLOOR(COALESCE(ec.total_goals, 0) * 0.75)::INT AS assists,
  COALESCE(ec.total_yellows, 0) AS yellow_cards,
  COALESCE(ec.total_reds, 0) AS red_cards
FROM player_ratings_flat prf
LEFT JOIN event_counts ec ON ec.player_id = prf.player_id
GROUP BY prf.captain_id, prf.player_id, prf.player_name, prf.jersey_number, prf.role, ec.total_goals, ec.total_yellows, ec.total_reds;

GRANT SELECT ON public.squad_season_leaderboard TO authenticated;
