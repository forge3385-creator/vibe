-- 0002_interests.up.sql
CREATE TABLE IF NOT EXISTS user_interests (
  user_id uuid NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
  interest_code text NOT NULL,
  weight smallint NOT NULL DEFAULT 1 CHECK (weight BETWEEN 0 AND 3),
  PRIMARY KEY (user_id, interest_code)
);

CREATE INDEX IF NOT EXISTS user_interests_code_idx ON user_interests (interest_code);
