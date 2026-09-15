-- 0001_init_users.up.sql
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DO $$ BEGIN
  CREATE TYPE user_status AS ENUM ('active','suspended','deleted');
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

CREATE TABLE IF NOT EXISTS users (
  user_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  display_name_cipher bytea NOT NULL,
  display_name_nonce bytea NOT NULL,
  dob_year smallint NOT NULL,
  region_code char(2) NOT NULL,
  locale text NOT NULL DEFAULT 'en_US',
  phone_hash bytea,
  phone_verified boolean NOT NULL DEFAULT false,
  photo_verified boolean NOT NULL DEFAULT false,
  preferences jsonb NOT NULL DEFAULT '{}'::jsonb,
  last_active_at timestamptz NOT NULL DEFAULT now(),
  status user_status NOT NULL DEFAULT 'active',
  deleted_at timestamptz
);

CREATE INDEX IF NOT EXISTS users_region_active_idx ON users (region_code, last_active_at DESC)
WHERE status = 'active';

CREATE INDEX IF NOT EXISTS users_phone_hash_idx ON users (phone_hash);
