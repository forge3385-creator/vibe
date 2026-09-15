# ADR-001: Cross-Platform Mobile Stack

- **Date**: 2026-09-14
- **Status**: Accepted

## Context
The project brief required cross-platform mobile support for iOS and Android, evaluating Flutter (Dart) vs React Native (Expo).

## Decision
Build Vibe mobile using Flutter (Dart).

## Rationale
1. High-performance rendering for 60fps suggestions list scrolling and real-time chat.
2. Direct native module access without bridge serialization latency (crucial for < 3s suggestion SLA).
3. Mature ecosystem for secure keystore access (`flutter_secure_storage`) and offline database caching (`drift`).

## Consequences
- React Native codebases are disallowed in MVP.
- Web client is developed as a companion PWA/interface for direct localhost and web access.
