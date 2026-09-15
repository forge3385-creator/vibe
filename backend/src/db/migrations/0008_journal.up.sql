-- 0008_journal.up.sql
CREATE TABLE IF NOT EXISTS journal_entries (
  entry_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
  ciphertext bytea NOT NULL,
  nonce bytea NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  mood smallint CHECK (mood BETWEEN 1 AND 5),
  size_bytes int NOT NULL,
  deleted_at timestamptz
);

CREATE INDEX IF NOT EXISTS journal_user_idx ON journal_entries (user_id, created_at DESC)
WHERE deleted_at IS NULL;
