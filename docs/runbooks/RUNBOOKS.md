# Vibe Operational Runbooks (RB-001 through RB-010)

## RB-001: Login Failure
- **Symptoms**: 5xx spike on `/v1/auth/*`.
1. Check `JWT_KEY_ROTATION_LOG` — has key rotation just occurred?
2. Confirm Postgres connection pool health from each active region.
3. Check Redis Pub/Sub cluster status.
4. If recent key rotation: revert to previous key and verify token validity.

## RB-002: Push Notification Outage
- **Symptoms**: Notification delivery rate < 50% on dashboard.
1. Check APNs / FCM feedback endpoints for invalid device tokens.
2. Inspect FCM error rate and token revocation trends.
3. Trigger manual outbox drain via `pnpm run outbox:drain`.
4. Restart notification dispatcher workers.

## RB-003: AI Companion Outage
- **Symptoms**: `/v1/journal/companion` returning 502/504.
1. Trip the circuit breaker on the external LLM provider.
2. Automatically fallback to static supportive prompts and warm-handoff mode.
3. Display non-blocking in-app notification banner to users.
4. Monitor upstream provider status until latency returns below 3000ms.

## RB-004: GIS / Spatial Outage
- **Symptoms**: PostGIS spatial queries timing out.
1. Switch matching engine to region-key fallback mode (coarse matching).
2. Expand default search radius to 30 km without fine coordinates.
3. Restore PostGIS spatial index when cluster reconnects.

## RB-005: Database Failover
- **Symptoms**: Primary PostgreSQL instance unreachable.
1. Promote standby replica to primary cluster leader.
2. Update connection URI secret in AWS Secrets Manager / Vault.
3. Verify migration parity (`0001_init_users` through `0010_subscriptions`).
4. Re-attach read pools.

## RB-006: Abuse Spike
- **Symptoms**: `report_rate` spikes > 50% within 24h.
1. Open Admin Console (`/v1/admin/reports`) and filter by IP/device hash.
2. Execute batch quarantine or suspension of offending accounts.
3. Lower edge rate limits via Cloudflare WAF rule.

## RB-007: Privacy Breach Suspected
- **Symptoms**: User report or audit alert implying sensitive data exposure.
1. Freeze affected database logs and isolate ingress traffic.
2. Open critical incident channel with security and legal teams.
3. Initiate user notification procedure within 72 hours per GDPR Article 33/34.
4. Publish detailed remediation statement in transparency log.

## RB-008: Build Pipeline Failure
- **Symptoms**: GitHub Actions CI red.
1. Inspect failing step (`npm test`, `npx tsc`, `flutter test`).
2. Run failing tests locally with seed data.
3. Verify dependency lockfile hash integrity.

## RB-009: App Store Guideline Rejection
- **Symptoms**: Apple / Google store review rejection notice.
1. Review rejection reason against Chapter 22 & 23 requirements.
2. Verify IAP restore purchase buttons and privacy disclaimer visibility.
3. Resubmit with updated metadata.

## RB-010: Hard-Purge Day
- **Symptoms**: Daily cron execution for GDPR Article 17 compliance.
1. Execute `DELETE FROM users WHERE status = 'deleted' AND deleted_at < NOW() - INTERVAL '30 days'`.
2. Ensure audit logs remain append-only and tamper-proof.
