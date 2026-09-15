import { z } from 'zod';
import jwt from 'jsonwebtoken';
import { getAuthUserId } from './profile.routes.js';
import { config } from '../../config/index.js';
import { globalStore } from '../../db/store.js';
import { generateVibeMirrorResponse } from '../../services/ai_companion.js';
const SaveEntrySchema = z.object({
    ciphertext: z.string().min(1),
    nonce: z.string().min(1),
    mood: z.number().int().min(1).max(5).optional(),
});
const CompanionRequestSchema = z.object({
    text: z.string().optional(),
    mood: z.number().int().min(1).max(5).optional(),
    mode: z.enum(['free_journaling', 'mood_checkin', 'action_bridge']).optional(),
    userPrompt: z.string().optional(),
});
export async function journalRoutes(fastify, _options) {
    // POST /v1/journal/sessions
    fastify.post('/journal/sessions', async (request, reply) => {
        const userId = getAuthUserId(request);
        if (!userId) {
            return reply.code(401).send({ type: 'https://errors.vibe.app/unauthorized', status: 401, title: 'Unauthorized' });
        }
        const sessionId = crypto.randomUUID();
        const ephemeralToken = jwt.sign({ userId, sessionId, scope: 'journal_ai' }, config.jwtSecret, { expiresIn: 900 });
        return reply.code(200).send({
            session_id: sessionId,
            token: ephemeralToken,
            disclaimer: "Vibe's AI is a writing partner, not a therapist. If you're in distress or need help now, contact local support. We don't store these sessions; they're meant for you.",
        });
    });
    // POST /v1/journal/companion (Zero-retention AI interaction)
    fastify.post('/journal/companion', async (request, reply) => {
        const userId = getAuthUserId(request);
        if (!userId) {
            return reply.code(401).send({ type: 'https://errors.vibe.app/unauthorized', status: 401, title: 'Unauthorized' });
        }
        const parsed = CompanionRequestSchema.safeParse(request.body);
        if (!parsed.success) {
            return reply.code(422).send({ type: 'https://errors.vibe.app/validation_error', status: 422, invalid_params: parsed.error.issues });
        }
        // Generate ephemeral response
        const result = generateVibeMirrorResponse({
            text: parsed.data.text,
            mood: parsed.data.mood,
            mode: parsed.data.mode,
            userPrompt: parsed.data.userPrompt,
        });
        return reply.code(200).send(result);
    });
    // POST /v1/journal/entries
    fastify.post('/journal/entries', async (request, reply) => {
        const userId = getAuthUserId(request);
        if (!userId) {
            return reply.code(401).send({ type: 'https://errors.vibe.app/unauthorized', status: 401, title: 'Unauthorized' });
        }
        const parsed = SaveEntrySchema.safeParse(request.body);
        if (!parsed.success) {
            return reply.code(422).send({ type: 'https://errors.vibe.app/validation_error', status: 422, invalid_params: parsed.error.issues });
        }
        const entryId = crypto.randomUUID();
        const entry = {
            entryId,
            userId,
            ciphertext: parsed.data.ciphertext,
            nonce: parsed.data.nonce,
            createdAt: new Date().toISOString(),
            mood: parsed.data.mood,
            sizeBytes: Buffer.byteLength(parsed.data.ciphertext, 'utf8'),
        };
        if (!globalStore.journals.has(userId)) {
            globalStore.journals.set(userId, []);
        }
        globalStore.journals.get(userId).push(entry);
        return reply.code(201).send({ entry });
    });
    // GET /v1/journal/entries
    fastify.get('/journal/entries', async (request, reply) => {
        const userId = getAuthUserId(request);
        if (!userId) {
            return reply.code(401).send({ type: 'https://errors.vibe.app/unauthorized', status: 401, title: 'Unauthorized' });
        }
        const entries = (globalStore.journals.get(userId) || []).filter((e) => !e.deletedAt);
        return reply.code(200).send({ entries });
    });
    // DELETE /v1/journal/entries/:id
    fastify.delete('/journal/entries/:id', async (request, reply) => {
        const userId = getAuthUserId(request);
        if (!userId) {
            return reply.code(401).send({ type: 'https://errors.vibe.app/unauthorized', status: 401, title: 'Unauthorized' });
        }
        const { id } = request.params;
        const entries = globalStore.journals.get(userId) || [];
        const entry = entries.find((e) => e.entryId === id);
        if (entry) {
            entry.deletedAt = new Date().toISOString();
        }
        return reply.code(200).send({ message: 'Journal entry deleted' });
    });
}
//# sourceMappingURL=journal.routes.js.map