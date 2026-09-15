-- 0007_chats.up.sql
CREATE TABLE IF NOT EXISTS chat_messages (
  message_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  meetup_id uuid NOT NULL REFERENCES meetups(meetup_id) ON DELETE CASCADE,
  sender_id uuid NOT NULL REFERENCES users(user_id),
  posted_at timestamptz NOT NULL DEFAULT now(),
  body text,
  kind text NOT NULL CHECK (kind IN ('text','image','place_card','time_card')),
  payload jsonb,
  expires_at timestamptz NOT NULL
);

CREATE INDEX IF NOT EXISTS chat_messages_meetup_idx ON chat_messages (meetup_id, posted_at);
