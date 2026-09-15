# Vibe — Intention to Real-World Connection

> End-to-End Implementation of the Vibe Specification for Gen Z Intention-Driven Offline Meetups.

---

## 🌟 Quick Start (Localhost Deployment)

### 1. Install & Build Backend
```bash
cd backend
pnpm install
npm run build
```

### 2. Run Test Suite (Chapters 25 & 33 Matrix)
```bash
node --test dist/test/suite.test.js
```

### 3. Generate Seed Data (10,000 Synthetic Users Across 5 Regions)
```bash
node dist/scripts/seed.js
```

### 4. Start Localhost Server & Live Interactive Client
```bash
node dist/server.js
```
- **Live Web Application**: [http://localhost:3000](http://localhost:3000)
- **OpenAPI 3.1 Swagger Docs**: [http://localhost:3000/docs](http://localhost:3000/docs)
- **Prometheus Metrics**: [http://localhost:3000/metrics](http://localhost:3000/metrics)
- **Realtime WebSocket Gateway**: `ws://localhost:3000/v1/realtime` (`vibe.v1` subprotocol)

---

## 🏗️ Architecture & Core Components

1. **Fastify Backend (`backend/`)**:
   - PostgreSQL 16 + PostGIS spatial matching queries (`fn_compute_vibe_score`, `mv_suggestions_pool`).
   - Redis 7 cache & suggestion memoization with 60s TTL.
   - Zero-retention AI Companion (*Vibe Mirror*) with Crisis Distress Classifier (suicide, self-harm, abuse triggers -> fixed warm-handoff & helplines).
   - Envelope encryption for sensitive fields & client-side XChaCha20-Poly1305 simulation for journals.
   - Strict RFC 7807 problem+json error formatting.

2. **Mobile Architecture (`mobile/`)**:
   - Flutter / Dart codebase with BLoC/Cubit state management, GoRouter, Drift, and Dio.
   - Design System Tokens (Brand Purple `#4C1D95`, soft lavender `#DDD6FE`, calm neutrals `#FAFAFB`).
   - Complete 28+ screens: Onboarding, Age Gate (16+), Phone OTP / Skip, Set Intent, Suggestions, Plans, Meetup Chat, Journal, Me, Paywall, Report Sheet, Block Sheet.

3. **Web Interactive Client (`web/`)**:
   - Pixel-perfect responsive client served directly on localhost at `/`.
   - Live WebSocket communication, dynamic Vibe Score calculation, safety modal, and component Storybook preview.

4. **Documentation & Runbooks (`docs/`)**:
   - ADRs 0001–0010 (`docs/adr/`)
   - Operational Runbooks RB-001–010 (`docs/runbooks/`)
   - Mermaid and ASCII Architecture Diagrams (`docs/diagrams/`)

---

## 📋 Definition of Done / Verification Status

| Feature Matrix | Test Identifier | Result |
|---|---|---|
| Age Gate >= 16 (Hard Stop) | OB-1 | ✅ Passed |
| OTP Rate Limit & Skip Phone | AUTH-1..5 | ✅ Passed |
| Intent Creation & Validation | INT-1..6 | ✅ Passed |
| Vibe Score Engine (< 3s SLA) | SUG-1..7 | ✅ Passed |
| Planning & WebSocket Chat | PLAN-1..5 | ✅ Passed |
| AI Companion & Distress Classifier | AI-1..5 | ✅ Passed |
| Safety Reports & Instant Block | SAFE-1..5 | ✅ Passed |
| Subscription Validation (StoreKit / Play) | SUB-1..4 | ✅ Passed |
| GDPR Export & 30-Day Purge | PRIV-1..4 | ✅ Passed |
