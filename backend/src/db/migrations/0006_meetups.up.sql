-- 0006_meetups.up.sql
DO $$ BEGIN
  CREATE TYPE meetup_state AS ENUM ('draft','proposed','accepted_partial','confirmed','in_progress','completed','cancelled','no_show');
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

CREATE TABLE IF NOT EXISTS meetups (
  meetup_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  host_id uuid NOT NULL REFERENCES users(user_id),
  participant_ids uuid[] NOT NULL CHECK (cardinality(participant_ids) BETWEEN 1 AND 6),
  activity_subtype text NOT NULL,
  place_id text,
  place_name text,
  place_address text,
  start_at timestamptz NOT NULL,
  end_at timestamptz,
  state meetup_state NOT NULL DEFAULT 'draft',
  cost_share_total_cents bigint CHECK (cost_share_total_cents IS NULL OR cost_share_total_cents >= 0),
  currency char(3),
  created_at timestamptz NOT NULL DEFAULT now(),
  created_via_match_ids uuid[] NOT NULL DEFAULT ARRAY[]::uuid[],
  trusted_share_ends_at timestamptz
);

CREATE INDEX IF NOT EXISTS meetups_host_idx ON meetups (host_id, start_at);
