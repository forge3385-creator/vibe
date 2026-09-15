-- 0004_intents.up.sql
CREATE EXTENSION IF NOT EXISTS postgis;

DO $$ BEGIN
  CREATE TYPE energy_level AS ENUM ('low','medium','high');
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
  CREATE TYPE activity_type AS ENUM ('chill','active','creative','food','study','outdoor','other');
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
  CREATE TYPE time_window AS ENUM ('today','this_week');
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
  CREATE TYPE intent_status AS ENUM ('uncommitted','active','expired','cancelled');
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
  CREATE TYPE group_pref AS ENUM ('one_on_one','small_group_3_6');
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

CREATE TABLE IF NOT EXISTS intents (
  intent_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
  energy_level energy_level NOT NULL,
  activity_type activity_type[] NOT NULL CHECK (cardinality(activity_type) BETWEEN 1 AND 3),
  activity_subtype text[] NOT NULL DEFAULT ARRAY[]::text[],
  group_size_pref group_pref NOT NULL,
  time_window time_window NOT NULL,
  note text CHECK (length(note) <= 80),
  geom geography(POINT,4326),
  radius_km smallint DEFAULT 5,
  created_at timestamptz NOT NULL DEFAULT now(),
  expires_at timestamptz NOT NULL,
  status intent_status NOT NULL DEFAULT 'active'
);

CREATE INDEX IF NOT EXISTS intents_active_matching_idx ON intents
USING gist (geom) WHERE status = 'active';

CREATE INDEX IF NOT EXISTS intents_user_idx ON intents (user_id, created_at DESC);
