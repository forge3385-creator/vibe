# ADR-003: Database Engine (PostgreSQL 16 + PostGIS + Redis 7)

- **Status**: Accepted
- **Decision**: PostgreSQL 16 + PostGIS for spatial geofencing and materialized views, paired with Redis 7 for suggestion memoization and rate limiting.
- **Rationale**: PostGIS `ST_DWithin` provides millisecond geospatial radius queries without external GIS dependencies. Pre-computed materialized views refresh every 30s to keep matching under 3 seconds.

---

# ADR-004: Identity Schema & Envelope Encryption

- **Status**: Accepted
- **Decision**: UUID v7 identifiers (ULID sortable) + per-row AES-256-GCM envelope encryption for sensitive strings (display name, phone hash).
- **Rationale**: Time-ordered UUIDs optimize B-Tree index locality while envelope encryption protects user identities.

---

# ADR-005: Realtime Transport

- **Status**: Accepted
- **Decision**: Native WebSockets with subprotocol `vibe.v1` over `wss://`.
- **Rationale**: Single persistent bidirectional channel per user with reconnection message replay (`since=?`) and 25s heartbeats.

---

# ADR-006: Subscription Validation

- **Status**: Accepted
- **Decision**: Apple StoreKit 2 + Google Play Billing v6 with weekly outbound server receipt verification.
- **Rationale**: Eliminates client-side spoofing and ensures accurate refund/cancellation lifecycle tracking.

---

# ADR-007: Region-Localized Storage

- **Status**: Accepted
- **Decision**: EU users stored in `eu-west-1`; other regions in `us-east-1`.
- **Rationale**: Strict compliance with GDPR Article 44+ data residency rules.

---

# ADR-008: Journal Encryption

- **Status**: Accepted
- **Decision**: End-to-end encryption with XChaCha20-Poly1305 and Argon2id key derivation.
- **Rationale**: Zero server plaintext exposure ensures user reflection privacy is cryptographically enforced.

---

# ADR-009: High-Value Push Notification Policy

- **Status**: Accepted
- **Decision**: Push notifications restricted to imminent decisions (invite accepted, plan confirmed) and safety alerts. Maximum 1 routine push per day.
- **Rationale**: Defends calm UI principle and prevents dopamine addiction mechanics.

---

# ADR-010: Empty-State Approach

- **Status**: Accepted
- **Decision**: Factual, curated empty states with a single contextual recovery CTA (e.g. "Broaden filters").
- **Rationale**: Ban on "invite 3 friends to unlock" or manipulative growth hacks.
