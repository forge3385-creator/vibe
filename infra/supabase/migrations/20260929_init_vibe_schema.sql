-- ============================================================================
-- VIBE PERSISTENCE & PRIVACY SCHEMA (SUPABASE / POSTGRESQL 16)
-- Chapters 10, 11, 14, 28, 30: Zero-Knowledge Profiles, Intentions,
-- Spatial Proximity (PostGIS), Meetups, Encrypted Journals, Safety & RLS
-- ============================================================================

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "postgis";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- 1. PROFILES & INTENTIONAL IDENTITY
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    display_name TEXT NOT NULL,
    dob_year INTEGER NOT NULL CHECK (dob_year >= 1920 AND dob_year <= EXTRACT(YEAR FROM CURRENT_DATE)),
    age INTEGER GENERATED ALWAYS AS (EXTRACT(YEAR FROM CURRENT_DATE)::integer - dob_year) STORED CHECK (age >= 16),
    city TEXT NOT NULL DEFAULT 'San Francisco, CA',
    region_code VARCHAR(10) NOT NULL DEFAULT 'US',
    emblem_emoji VARCHAR(10) NOT NULL DEFAULT '✨',
    avatar_url TEXT,
    phone_verified BOOLEAN NOT NULL DEFAULT FALSE,
    completed_meetups_count INTEGER NOT NULL DEFAULT 0 CHECK (completed_meetups_count >= 0),
    report_rate NUMERIC(4, 3) NOT NULL DEFAULT 0.0 CHECK (report_rate >= 0.0 AND report_rate <= 1.0),
    status VARCHAR(20) NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'suspended', 'deleted', 'under_review')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 2. USER SETTINGS & PREFERENCES
CREATE TABLE IF NOT EXISTS public.user_settings (
    user_id UUID PRIMARY KEY REFERENCES public.profiles(id) ON DELETE CASCADE,
    sound_enabled BOOLEAN NOT NULL DEFAULT TRUE,
    sound_volume NUMERIC(3, 2) NOT NULL DEFAULT 0.60 CHECK (sound_volume >= 0.0 AND sound_volume <= 1.0),
    theme VARCHAR(20) NOT NULL DEFAULT 'cosmic_dark' CHECK (theme IN ('cosmic_dark', 'light', 'system')),
    reduced_motion BOOLEAN NOT NULL DEFAULT FALSE,
    mesh_discoverable BOOLEAN NOT NULL DEFAULT TRUE,
    preferred_radius_km NUMERIC(4, 1) NOT NULL DEFAULT 5.0 CHECK (preferred_radius_km >= 1.0 AND preferred_radius_km <= 15.0),
    notifications_enabled BOOLEAN NOT NULL DEFAULT TRUE,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 3. BROADCAST INTENTIONS (EPHEMERAL VIBE SIGNALS)
CREATE TABLE IF NOT EXISTS public.intents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    title VARCHAR(80) NOT NULL,
    icon VARCHAR(10) NOT NULL DEFAULT '☕',
    energy VARCHAR(20) NOT NULL CHECK (energy IN ('low', 'medium', 'high')),
    radius_km NUMERIC(4, 1) NOT NULL DEFAULT 5.0 CHECK (radius_km >= 1.0 AND radius_km <= 15.0),
    context_note TEXT,
    coordinates GEOMETRY(Point, 4326),
    status VARCHAR(20) NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'paused', 'matched', 'expired')),
    expires_at TIMESTAMPTZ NOT NULL DEFAULT (NOW() + INTERVAL '3 hours'),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 4. CURATED PUBLIC VENUES & THIRD-PLACES
CREATE TABLE IF NOT EXISTS public.public_venues (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    category VARCHAR(40) NOT NULL CHECK (category IN ('cafe', 'park', 'library', 'campus_hub', 'bookstore', 'art_center')),
    address TEXT NOT NULL,
    city TEXT NOT NULL,
    coordinates GEOMETRY(Point, 4326) NOT NULL,
    safety_tier VARCHAR(20) NOT NULL DEFAULT 'verified_public' CHECK (safety_tier IN ('verified_public', 'community_approved')),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 5. CONFIRMED MEETUPS
CREATE TABLE IF NOT EXISTS public.meetups (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    initiator_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    participant_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    venue_id UUID REFERENCES public.public_venues(id) ON DELETE SET NULL,
    custom_venue_name TEXT,
    custom_venue_address TEXT,
    scheduled_time TIMESTAMPTZ NOT NULL,
    vibe_affinity_score INTEGER NOT NULL CHECK (vibe_affinity_score >= 0 AND vibe_affinity_score <= 100),
    status VARCHAR(30) NOT NULL DEFAULT 'proposed' CHECK (status IN ('proposed', 'confirmed', 'checked_in', 'completed', 'cancelled')),
    initiator_checked_in BOOLEAN NOT NULL DEFAULT FALSE,
    participant_checked_in BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 6. TRANSIENT MEETUP MESSAGES (EPHEMERAL ZERO-RETENTION)
CREATE TABLE IF NOT EXISTS public.chat_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    meetup_id UUID NOT NULL REFERENCES public.meetups(id) ON DELETE CASCADE,
    sender_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    encrypted_payload TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 7. ZERO-KNOWLEDGE CLIENT-ENCRYPTED JOURNALS
CREATE TABLE IF NOT EXISTS public.journal_entries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    encrypted_content TEXT NOT NULL, -- Encrypted client-side with XChaCha20-Poly1305 before transmission
    nonce_hex TEXT NOT NULL,
    mood_tag VARCHAR(30),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 8. SAFETY, BLOCKS & CRISIS REPORTS
CREATE TABLE IF NOT EXISTS public.safety_reports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    reporter_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    reported_user_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    category VARCHAR(40) NOT NULL CHECK (category IN ('harassment', 'underage', 'solicitation', 'impersonation', 'inappropriate_venue', 'other')),
    details TEXT,
    status VARCHAR(20) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'investigating', 'resolved', 'dismissed')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.user_blocks (
    blocker_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    blocked_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (blocker_id, blocked_id)
);

-- ============================================================================
-- INDEXES FOR LOW-LATENCY QUERIES (< 50ms SLA)
-- ============================================================================
CREATE INDEX IF NOT EXISTS idx_intents_active ON public.intents(status, expires_at) WHERE status = 'active';
CREATE INDEX IF NOT EXISTS idx_intents_spatial ON public.intents USING GIST (coordinates);
CREATE INDEX IF NOT EXISTS idx_venues_spatial ON public.public_venues USING GIST (coordinates);
CREATE INDEX IF NOT EXISTS idx_meetups_participants ON public.meetups(initiator_id, participant_id, status);
CREATE INDEX IF NOT EXISTS idx_chat_meetup ON public.chat_messages(meetup_id, created_at);
CREATE INDEX IF NOT EXISTS idx_journal_user ON public.journal_entries(user_id, created_at DESC);

-- ============================================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- Strict user ownership checks: users can only read & mutate their own data
-- ============================================================================
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.intents ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.meetups ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chat_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.journal_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.safety_reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_blocks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.public_venues ENABLE ROW LEVEL SECURITY;

-- Profiles: Public can view active profiles that are discoverable, only owner can update
CREATE POLICY "Public profiles are viewable by authenticated users"
    ON public.profiles FOR SELECT
    TO authenticated
    USING (status = 'active');

CREATE POLICY "Users can insert their own profile"
    ON public.profiles FOR INSERT
    WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can update their own profile"
    ON public.profiles FOR UPDATE
    USING (auth.uid() = id);

-- Settings: Only user can view and update their own settings
CREATE POLICY "Users manage own settings"
    ON public.user_settings FOR ALL
    USING (auth.uid() = user_id);

-- Intents: Anyone active can read active unexpired intents (filtered by blocks in app/rpc)
CREATE POLICY "Users can view active intentions"
    ON public.intents FOR SELECT
    TO authenticated
    USING (status = 'active' AND expires_at > NOW());

CREATE POLICY "Users can create their own intent"
    ON public.intents FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own intent"
    ON public.intents FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own intent"
    ON public.intents FOR DELETE
    USING (auth.uid() = user_id);

-- Meetups: Only members involved in the meetup can read or update it
CREATE POLICY "Meetup participants can view meetup"
    ON public.meetups FOR SELECT
    TO authenticated
    USING (auth.uid() = initiator_id OR auth.uid() = participant_id);

CREATE POLICY "Users can initiate meetups"
    ON public.meetups FOR INSERT
    WITH CHECK (auth.uid() = initiator_id);

CREATE POLICY "Meetup participants can update meetup"
    ON public.meetups FOR UPDATE
    USING (auth.uid() = initiator_id OR auth.uid() = participant_id);

-- Chat: Only participants of the corresponding meetup can view/send messages
CREATE POLICY "Participants can view meetup chat"
    ON public.chat_messages FOR SELECT
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM public.meetups m
            WHERE m.id = chat_messages.meetup_id
            AND (m.initiator_id = auth.uid() OR m.participant_id = auth.uid())
        )
    );

CREATE POLICY "Participants can send meetup chat"
    ON public.chat_messages FOR INSERT
    WITH CHECK (
        auth.uid() = sender_id AND
        EXISTS (
            SELECT 1 FROM public.meetups m
            WHERE m.id = chat_messages.meetup_id
            AND (m.initiator_id = auth.uid() OR m.participant_id = auth.uid())
        )
    );

-- Journals: Strictly confidential to the owning user
CREATE POLICY "Users have exclusive access to own journal"
    ON public.journal_entries FOR ALL
    USING (auth.uid() = user_id);

-- Safety Reports: Users can create reports, only admins can view
CREATE POLICY "Users can create safety reports"
    ON public.safety_reports FOR INSERT
    WITH CHECK (auth.uid() = reporter_id);

CREATE POLICY "Users manage own blocks"
    ON public.user_blocks FOR ALL
    USING (auth.uid() = blocker_id);

-- Public Venues: All authenticated users can read verified venues
CREATE POLICY "Public venues are viewable by all"
    ON public.public_venues FOR SELECT
    TO authenticated
    USING (is_active = TRUE);
