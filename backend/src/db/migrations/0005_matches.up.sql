-- 0005_matches.up.sql
DO $$ BEGIN
  CREATE TYPE match_state AS ENUM ('created','chat_open','meet_created','completed','cancelled','unmatched');
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

CREATE TABLE IF NOT EXISTS matches (
  match_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_a_id uuid NOT NULL REFERENCES users(user_id),
  user_b_id uuid NOT NULL REFERENCES users(user_id),
  origin_intent_a uuid NOT NULL REFERENCES intents(intent_id),
  origin_intent_b uuid NOT NULL REFERENCES intents(intent_id),
  created_at timestamptz NOT NULL DEFAULT now(),
  state match_state NOT NULL DEFAULT 'created',
  unmatch_reason text,
  CHECK (user_a_id <> user_b_id)
);

CREATE INDEX IF NOT EXISTS matches_user_a_idx ON matches (user_a_id, created_at DESC);
CREATE INDEX IF NOT EXISTS matches_user_b_idx ON matches (user_b_id, created_at DESC);
