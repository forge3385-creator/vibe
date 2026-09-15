import { getAuthUserId } from './profile.routes.js';
import { globalStore } from '../../db/store.js';
export async function suggestionsRoutes(fastify, _options) {
    // GET /v1/suggestions
    fastify.get('/suggestions', async (request, reply) => {
        const userId = getAuthUserId(request);
        if (!userId) {
            return reply.code(401).send({ type: 'https://errors.vibe.app/unauthorized', status: 401, title: 'Unauthorized' });
        }
        // Find active intent for user
        let activeIntentId = null;
        for (const intent of globalStore.intents.values()) {
            if (intent.userId === userId && intent.status === 'active') {
                activeIntentId = intent.intentId;
                break;
            }
        }
        if (!activeIntentId) {
            return reply.code(200).send({
                suggestions: [],
                message: 'No active intent set. Set an intent to discover suggestions.',
            });
        }
        const suggestions = globalStore.findSuggestionsForIntent(activeIntentId);
        return reply.code(200).send({ suggestions });
    });
    // POST /v1/suggestions/:id/open
    fastify.post('/suggestions/:id/open', async (request, reply) => {
        const userId = getAuthUserId(request);
        if (!userId) {
            return reply.code(401).send({ type: 'https://errors.vibe.app/unauthorized', status: 401, title: 'Unauthorized' });
        }
        const { id } = request.params;
        const targetIntent = globalStore.intents.get(id);
        if (!targetIntent) {
            return reply.code(404).send({ type: 'https://errors.vibe.app/not_found', status: 404, title: 'Suggestion Not Found' });
        }
        return reply.code(200).send({
            message: 'Interest recorded',
            suggestion_id: id,
            target_user_id: targetIntent.userId,
        });
    });
    // POST /v1/suggestions/:id/hide
    fastify.post('/suggestions/:id/hide', async (request, reply) => {
        const userId = getAuthUserId(request);
        if (!userId) {
            return reply.code(401).send({ type: 'https://errors.vibe.app/unauthorized', status: 401, title: 'Unauthorized' });
        }
        const { id } = request.params;
        if (!globalStore.hiddenSuggestions.has(userId)) {
            globalStore.hiddenSuggestions.set(userId, new Set());
        }
        globalStore.hiddenSuggestions.get(userId).add(id);
        return reply.code(200).send({
            message: 'Suggestion hidden locally',
            suggestion_id: id,
        });
    });
}
//# sourceMappingURL=suggestions.routes.js.map