-- 0003_privacy_defaults.up.sql
CREATE TABLE IF NOT EXISTS user_privacy_defaults (
  user_id uuid PRIMARY KEY REFERENCES users(user_id) ON DELETE CASCADE,
  discoverable_to_friends boolean NOT NULL DEFAULT false,
  share_photo_by_default boolean NOT NULL DEFAULT false,
  journal_encrypted boolean NOT NULL DEFAULT true,
  trusted_contact_ids uuid[] NOT NULL DEFAULT ARRAY[]::uuid[]
);
