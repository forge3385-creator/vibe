# ADR-002: Backend Language and Framework

- **Date**: 2026-09-14
- **Status**: Accepted

## Context
A high-throughput, low-latency API gateway is required to compute vibe scores, manage WebSockets, and handle ephemeral AI sessions within a 3-second P95 SLA.

## Decision
Node.js 20 LTS + TypeScript 5.x + Fastify framework.

## Rationale
Fastify delivers 2-3x higher requests/second than Express, with built-in schema compilation via Zod, first-class WebSocket plugin support, and strong async pipeline predictability.

## Consequences
All backend code is strictly typed TypeScript.
