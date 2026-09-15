-- 0010_subscriptions.up.sql
DO $$ BEGIN
  CREATE TYPE sub_plan AS ENUM ('monthly','annual');
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
  CREATE TYPE sub_provider AS ENUM ('apple','google');
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
  CREATE TYPE sub_status AS ENUM ('active','past_due','cancelled','expired','refunded');
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

CREATE TABLE IF NOT EXISTS subscriptions (
  subscription_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
  plan_id sub_plan NOT NULL,
  provider sub_provider NOT NULL,
  provider_subscription_id text NOT NULL,
  status sub_status NOT NULL DEFAULT 'active',
  started_at timestamptz NOT NULL DEFAULT now(),
  renew_at timestamptz NOT NULL,
  cancelled_at timestamptz,
  UNIQUE (provider, provider_subscription_id)
);

CREATE INDEX IF NOT EXISTS subscriptions_user_idx ON subscriptions (user_id);
