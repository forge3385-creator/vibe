-- 0009_reports_blocks.up.sql
DO $$ BEGIN
  CREATE TYPE report_status AS ENUM ('received','reviewing','closed_action','closed_no_action','escalated');
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

CREATE TABLE IF NOT EXISTS reports (
  report_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  reporter_id uuid NOT NULL REFERENCES users(user_id),
  subject_id uuid NOT NULL REFERENCES users(user_id),
  category text NOT NULL,
  body text CHECK (length(body) <= 500),
  attachments_ref text[],
  created_at timestamptz NOT NULL DEFAULT now(),
  status report_status NOT NULL DEFAULT 'received',
  moderator_id uuid,
  resolution_note text
);

CREATE INDEX IF NOT EXISTS reports_status_idx ON reports (status, created_at);
CREATE INDEX IF NOT EXISTS reports_subject_idx ON reports (subject_id);

CREATE TABLE IF NOT EXISTS blocks (
  blocker_id uuid NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
  blocked_id uuid NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
  created_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (blocker_id, blocked_id)
);

CREATE INDEX IF NOT EXISTS blocks_blocked_idx ON blocks (blocked_id);
