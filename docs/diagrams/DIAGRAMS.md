# Vibe Architecture Diagrams (ASCII & Mermaid)

## 1. System Topology

```mermaid
graph TD
    A[Flutter Mobile Client / Web PWA] -->|HTTPS REST| B[Fastify API Gateway]
    A -->|WSS vibe.v1| C[WebSocket Realtime Gateway]
    B --> D[(PostgreSQL 16 + PostGIS)]
    B --> E[(Redis 7 Cache & Rate Limit)]
    B --> F[Zero-Retention AI Companion]
    C --> E
    B --> G[Outbox Worker]
    G --> H[APNs / FCM Push Dispatcher]
```

## 2. Intent-to-Match Flow

```mermaid
sequenceDiagram
    autonumber
    actor User as Maya (User)
    participant Client as Vibe Client
    participant API as Fastify API
    participant Engine as Vibe Score Engine
    participant Store as PostGIS & Redis

    User->>Client: Selects Medium Energy + Coffee + 10km
    Client->>API: POST /v1/intents
    API->>Store: Query candidate active intents within radius
    API->>Engine: Compute fn_compute_vibe_score()
    Engine-->>API: Top 12 candidates sorted by affinity
    API-->>Client: 200 OK with suggestions list (< 3s SLA)
    Client-->>User: Renders Suggestion Cards with 10-dot affinity
```

## 3. Meetup Lifecycle State Machine (Chapter 4.5 & 36.5)

```mermaid
stateDiagram-v2
    [*] --> draft
    draft --> proposed: User presses "Send Invite"
    proposed --> accepted_partial: >= 1 invitee accepts
    accepted_partial --> confirmed: Meetup time reached & confirmed
    confirmed --> in_progress: Anyone marks "I am here"
    in_progress --> completed: "Mark Completed" / Auto-4h
    in_progress --> no_show: Host absent after 30 min
    draft --> cancelled: User cancels
    proposed --> cancelled: Any party cancels
    confirmed --> cancelled: Any party cancels
```

## 4. Privacy & End-to-End Journal Encryption (Chapter 9.5 & 36.6)

```
[User Text] ───→ [Argon2id(Passphrase)] ───→ [Key]
                         │
                         ▼
        [XChaCha20-Poly1305 Encrypt]
                         │
                         ▼
      [Ciphertext + Nonce + Salt] ───→ Server (Opaque Blob)
```
