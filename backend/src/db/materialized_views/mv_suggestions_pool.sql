-- backend/src/db/materialized_views/mv_suggestions_pool.sql
CREATE MATERIALIZED VIEW IF NOT EXISTS mv_suggestions_pool AS
SELECT
  i_a.intent_id AS intent_a_id,
  i_b.intent_id AS intent_b_id,
  i_a.user_id AS user_a,
  i_b.user_id AS user_b,
  i_a.energy_level AS energy_a,
  i_b.energy_level AS energy_b,
  i_a.activity_type AS activity_a,
  i_b.activity_type AS activity_b,
  ST_Distance(i_a.geom, i_b.geom)/1000 AS distance_km
FROM intents i_a
JOIN intents i_b
  ON i_a.intent_id <> i_b.intent_id
  AND i_a.energy_level = i_b.energy_level
  AND i_a.activity_type && i_b.activity_type
  AND i_a.time_window = i_b.time_window
  AND i_a.status = 'active' AND i_b.status = 'active'
  AND ST_DWithin(i_a.geom, i_b.geom, COALESCE(i_a.radius_km, i_b.radius_km)*1000)
WHERE i_a.user_id <> i_b.user_id;

CREATE UNIQUE INDEX IF NOT EXISTS mv_suggestions_pool_pk
ON mv_suggestions_pool (intent_a_id, intent_b_id);
