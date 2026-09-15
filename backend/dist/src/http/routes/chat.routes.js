import { z } from 'zod';
import { getAuthUserId } from './profile.routes.js';
import { globalStore } from '../../db/store.js';
import { realtimeGateway } from '../../realtime/gateway.js';
const SendMessageSchema = z.object({
    body: z.string().min(1).max(2000),
    kind: z.enum(['text', 'image', 'place_card', 'time_card']).default('text'),
    payload: z.any().optional(),
});
const PlaceCardSchema = z.object({
    place_id: z.string().min(1),
    place_name: z.string().min(1),
    address: z.string().min(1),
});
const TimeCardSchema = z.object({
    time: z.string().datetime(),
});
export async function chatRoutes(fastify, _options) {
    // GET /v1/meetups/:id/chat
    fastify.get('/meetups/:id/chat', async (request, reply) => {
        const userId = getAuthUserId(request);
        if (!userId) {
            return reply.code(401).send({ type: 'https://errors.vibe.app/unauthorized', status: 401, title: 'Unauthorized' });
        }
        const { id } = request.params;
        const meetup = globalStore.meetups.get(id);
        if (!meetup) {
            return reply.code(404).send({ type: 'https://errors.vibe.app/not_found', status: 404, title: 'Meetup Not Found' });
        }
        const { since } = request.query;
        let messages = globalStore.chats.get(id) || [];
        if (since) {
            const sinceDate = new Date(since).getTime();
            messages = messages.filter((m) => new Date(m.postedAt).getTime() > sinceDate);
        }
        return reply.code(200).send({
            meetup_id: id,
            messages,
            is_read_only: meetup.state === 'completed' || meetup.state === 'cancelled',
        });
    });
    // POST /v1/meetups/:id/chat
    fastify.post('/meetups/:id/chat', async (request, reply) => {
        const userId = getAuthUserId(request);
        if (!userId) {
            return reply.code(401).send({ type: 'https://errors.vibe.app/unauthorized', status: 401, title: 'Unauthorized' });
        }
        const { id } = request.params;
        const meetup = globalStore.meetups.get(id);
        if (!meetup) {
            return reply.code(404).send({ type: 'https://errors.vibe.app/not_found', status: 404, title: 'Meetup Not Found' });
        }
        const parsed = SendMessageSchema.safeParse(request.body);
        if (!parsed.success) {
            return reply.code(422).send({ type: 'https://errors.vibe.app/validation_error', status: 422, invalid_params: parsed.error.issues });
        }
        const messageId = crypto.randomUUID();
        const expiresAt = new Date(Date.now() + 90 * 86400 * 1000).toISOString();
        const newMessage = {
            messageId,
            meetupId: id,
            senderId: userId,
            postedAt: new Date().toISOString(),
            body: parsed.data.body,
            kind: parsed.data.kind,
            payload: parsed.data.payload,
            expiresAt,
        };
        if (!globalStore.chats.has(id)) {
            globalStore.chats.set(id, []);
        }
        globalStore.chats.get(id).push(newMessage);
        // Broadcast over WebSocket to meetup participants
        realtimeGateway.broadcastToMeetup(id, {
            type: 'chat.message.new',
            meetup_id: id,
            message: newMessage,
        });
        return reply.code(201).send({ message: newMessage });
    });
    // POST /v1/meetups/:id/chat/place_card
    fastify.post('/meetups/:id/chat/place_card', async (request, reply) => {
        const userId = getAuthUserId(request);
        if (!userId) {
            return reply.code(401).send({ type: 'https://errors.vibe.app/unauthorized', status: 401, title: 'Unauthorized' });
        }
        const { id } = request.params;
        const parsed = PlaceCardSchema.safeParse(request.body);
        if (!parsed.success) {
            return reply.code(422).send({ type: 'https://errors.vibe.app/validation_error', status: 422 });
        }
        const newMessage = {
            messageId: crypto.randomUUID(),
            meetupId: id,
            senderId: userId,
            postedAt: new Date().toISOString(),
            body: `Suggested Location: ${parsed.data.place_name}`,
            kind: 'place_card',
            payload: parsed.data,
            expiresAt: new Date(Date.now() + 90 * 86400 * 1000).toISOString(),
        };
        if (!globalStore.chats.has(id))
            globalStore.chats.set(id, []);
        globalStore.chats.get(id).push(newMessage);
        realtimeGateway.broadcastToMeetup(id, {
            type: 'chat.message.new',
            meetup_id: id,
            message: newMessage,
        });
        return reply.code(201).send({ message: newMessage });
    });
    // POST /v1/meetups/:id/chat/time_card
    fastify.post('/meetups/:id/chat/time_card', async (request, reply) => {
        const userId = getAuthUserId(request);
        if (!userId) {
            return reply.code(401).send({ type: 'https://errors.vibe.app/unauthorized', status: 401, title: 'Unauthorized' });
        }
        const { id } = request.params;
        const parsed = TimeCardSchema.safeParse(request.body);
        if (!parsed.success) {
            return reply.code(422).send({ type: 'https://errors.vibe.app/validation_error', status: 422 });
        }
        const newMessage = {
            messageId: crypto.randomUUID(),
            meetupId: id,
            senderId: userId,
            postedAt: new Date().toISOString(),
            body: `Proposed Time: ${new Date(parsed.data.time).toLocaleTimeString()}`,
            kind: 'time_card',
            payload: parsed.data,
            expiresAt: new Date(Date.now() + 90 * 86400 * 1000).toISOString(),
        };
        if (!globalStore.chats.has(id))
            globalStore.chats.set(id, []);
        globalStore.chats.get(id).push(newMessage);
        realtimeGateway.broadcastToMeetup(id, {
            type: 'chat.message.new',
            meetup_id: id,
            message: newMessage,
        });
        return reply.code(201).send({ message: newMessage });
    });
}
//# sourceMappingURL=chat.routes.js.map