import { z } from 'zod';
import { getAuthUserId } from './profile.routes.js';
import { globalStore } from '../../db/store.js';
import { ACTIVITY_CATALOGUE, INTEREST_CATALOGUE } from '../../domain/catalogue.js';
const IntentBodySchema = z.object({
    energy_level: z.enum(['low', 'medium', 'high']),
    activity_type: z.array(z.enum(['chill', 'active', 'creative', 'food', 'study', 'outdoor', 'other'])).min(1).max(3),
    activity_subtype: z.array(z.string()).max(3).default([]),
    group_size_pref: z.enum(['one_on_one', 'small_group_3_6']),
    time_window: z.enum(['today', 'this_week']),
    note: z.string().max(80).optional(),
    radius_km: z.number().int().min(1).max(30).optional(),
    lat: z.number().optional(),
    lng: z.number().optional(),
});
export async function intentsRoutes(fastify, _options) {
    // GET /v1/activities
    fastify.get('/activities', async (_request, reply) => {
        return reply.code(200).send({ catalogue: ACTIVITY_CATALOGUE });
    });
    // GET /v1/interests
    fastify.get('/interests', async (_request, reply) => {
        return reply.code(200).send({ interests: INTEREST_CATALOGUE });
    });
    // PUT /v1/me/interests
    fastify.put('/me/interests', async (request, reply) => {
        const userId = getAuthUserId(request);
        if (!userId) {
            return reply.code(401).send({ type: 'https://errors.vibe.app/unauthorized', status: 401, title: 'Unauthorized' });
        }
        const { interest_codes } = request.body || {};
        if (!Array.isArray(interest_codes)) {
            return reply.code(422).send({ type: 'https://errors.vibe.app/validation_error', status: 422, detail: 'interest_codes must be an array' });
        }
        globalStore.userInterests.set(userId, interest_codes.slice(0, 12));
        return reply.code(200).send({ interests: globalStore.userInterests.get(userId) });
    });
    // POST /v1/intents
    fastify.post('/intents', async (request, reply) => {
        const userId = getAuthUserId(request);
        if (!userId) {
            return reply.code(401).send({ type: 'https://errors.vibe.app/unauthorized', status: 401, title: 'Unauthorized' });
        }
        const parsed = IntentBodySchema.safeParse(request.body);
        if (!parsed.success) {
            return reply.code(422).send({
                type: 'https://errors.vibe.app/intent_validation_failed',
                title: 'Intent validation failed',
                status: 422,
                code: 'intent_validation_failed',
                invalid_params: parsed.error.issues.map((i) => ({
                    name: i.path.join('.'),
                    reason: i.message,
                })),
            });
        }
        const data = parsed.data;
        const intentId = crypto.randomUUID();
        const durationHours = data.time_window === 'today' ? 24 : 168;
        const expiresAt = new Date(Date.now() + durationHours * 3600 * 1000).toISOString();
        const newIntent = {
            intentId,
            userId,
            energyLevel: data.energy_level,
            activityType: data.activity_type,
            activitySubtype: data.activity_subtype,
            groupSizePref: data.group_size_pref,
            timeWindow: data.time_window,
            note: data.note,
            lat: data.lat ?? 40.7128, // Default NYC coordinates if not provided
            lng: data.lng ?? -74.006,
            radiusKm: data.radius_km ?? 5,
            createdAt: new Date().toISOString(),
            expiresAt,
            status: 'active',
        };
        globalStore.intents.set(intentId, newIntent);
        // Compute ranked suggestions synchronously within SLA (Chapter 7.1)
        const suggestions = globalStore.findSuggestionsForIntent(intentId);
        return reply.code(200).send({
            intent: newIntent,
            suggestions,
        });
    });
    // GET /v1/intents/active
    fastify.get('/intents/active', async (request, reply) => {
        const userId = getAuthUserId(request);
        if (!userId) {
            return reply.code(401).send({ type: 'https://errors.vibe.app/unauthorized', status: 401, title: 'Unauthorized' });
        }
        for (const intent of globalStore.intents.values()) {
            if (intent.userId === userId && intent.status === 'active') {
                return reply.code(200).send({ intent });
            }
        }
        return reply.code(200).send({ intent: null });
    });
    // DELETE /v1/intents/:id
    fastify.delete('/intents/:id', async (request, reply) => {
        const userId = getAuthUserId(request);
        if (!userId) {
            return reply.code(401).send({ type: 'https://errors.vibe.app/unauthorized', status: 401, title: 'Unauthorized' });
        }
        const { id } = request.params;
        const intent = globalStore.intents.get(id);
        if (intent && intent.userId === userId) {
            intent.status = 'cancelled';
        }
        return reply.code(200).send({ message: 'Intent cancelled' });
    });
}
//# sourceMappingURL=intents.routes.js.map