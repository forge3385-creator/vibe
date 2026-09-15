import { FastifyInstance, FastifyPluginOptions } from 'fastify';
import { z } from 'zod';
import { getAuthUserId } from './profile.routes.js';
import { globalStore } from '../../db/store.js';
import { Report } from '../../domain/types.js';

const CreateReportSchema = z.object({
  subject_id: z.string().min(1),
  category: z.enum(['Harassment', 'Spam', 'Safety concern', 'Inappropriate content', 'Other']),
  body: z.string().max(500),
  attachments_ref: z.array(z.string()).max(3).optional(),
});

const BlockUserSchema = z.object({
  subject_id: z.string().min(1),
});

const TrustedContactSchema = z.object({
  kind: z.enum(['phone', 'invite']),
  value: z.string().min(1),
  name: z.string().optional(),
});

export async function safetyRoutes(fastify: FastifyInstance, _options: FastifyPluginOptions) {
  // POST /v1/reports
  fastify.post('/reports', async (request, reply) => {
    const userId = getAuthUserId(request);
    if (!userId) {
      return reply.code(401).send({ type: 'https://errors.vibe.app/unauthorized', status: 401, title: 'Unauthorized' });
    }

    const parsed = CreateReportSchema.safeParse(request.body);
    if (!parsed.success) {
      return reply.code(422).send({ type: 'https://errors.vibe.app/validation_error', status: 422, invalid_params: parsed.error.issues });
    }

    const reportId = crypto.randomUUID();
    const report: Report = {
      reportId,
      reporterId: userId,
      subjectId: parsed.data.subject_id,
      category: parsed.data.category,
      body: parsed.data.body,
      attachmentsRef: parsed.data.attachments_ref,
      createdAt: new Date().toISOString(),
      status: 'received',
    };

    globalStore.reports.set(reportId, report);

    // Immediate mutual block on report (Chapter 10.2)
    if (!globalStore.blocks.has(userId)) {
      globalStore.blocks.set(userId, new Set());
    }
    globalStore.blocks.get(userId)!.add(parsed.data.subject_id);

    return reply.code(201).send({
      reference_id: reportId,
      message: "We've recorded your report. You won't see them again.",
      status: 'received',
    });
  });

  // POST /v1/blocks
  fastify.post('/blocks', async (request, reply) => {
    const userId = getAuthUserId(request);
    if (!userId) {
      return reply.code(401).send({ type: 'https://errors.vibe.app/unauthorized', status: 401, title: 'Unauthorized' });
    }

    const parsed = BlockUserSchema.safeParse(request.body);
    if (!parsed.success) {
      return reply.code(422).send({ type: 'https://errors.vibe.app/validation_error', status: 422 });
    }

    if (!globalStore.blocks.has(userId)) {
      globalStore.blocks.set(userId, new Set());
    }

    const userBlockSet = globalStore.blocks.get(userId)!;
    if (userBlockSet.size >= 500) {
      return reply.code(400).send({
        type: 'https://errors.vibe.app/block_limit_reached',
        title: 'Block Limit Reached',
        status: 400,
        detail: 'Block list capped at 500 entries (Chapter 10.3)',
      });
    }

    userBlockSet.add(parsed.data.subject_id);
    return reply.code(200).send({
      message: 'Blocked',
      subject_id: parsed.data.subject_id,
    });
  });

  // GET /v1/blocks
  fastify.get('/blocks', async (request, reply) => {
    const userId = getAuthUserId(request);
    if (!userId) {
      return reply.code(401).send({ type: 'https://errors.vibe.app/unauthorized', status: 401, title: 'Unauthorized' });
    }

    const blockedList = Array.from(globalStore.blocks.get(userId) || []);
    return reply.code(200).send({ blocked_users: blockedList, total: blockedList.length });
  });

  // DELETE /v1/blocks/:id
  fastify.delete('/blocks/:id', async (request, reply) => {
    const userId = getAuthUserId(request);
    if (!userId) {
      return reply.code(401).send({ type: 'https://errors.vibe.app/unauthorized', status: 401, title: 'Unauthorized' });
    }

    const { id } = request.params as { id: string };
    const userBlockSet = globalStore.blocks.get(userId);
    if (userBlockSet) {
      userBlockSet.delete(id);
    }

    return reply.code(200).send({ message: 'User unblocked' });
  });

  // GET /v1/trusted_contacts
  fastify.get('/trusted_contacts', async (request, reply) => {
    const userId = getAuthUserId(request);
    if (!userId) {
      return reply.code(401).send({ type: 'https://errors.vibe.app/unauthorized', status: 401, title: 'Unauthorized' });
    }

    const contacts = globalStore.trustedContacts.get(userId) || [];
    return reply.code(200).send({ contacts, count: contacts.length });
  });

  // POST /v1/trusted_contacts
  fastify.post('/trusted_contacts', async (request, reply) => {
    const userId = getAuthUserId(request);
    if (!userId) {
      return reply.code(401).send({ type: 'https://errors.vibe.app/unauthorized', status: 401, title: 'Unauthorized' });
    }

    const parsed = TrustedContactSchema.safeParse(request.body);
    if (!parsed.success) {
      return reply.code(422).send({ type: 'https://errors.vibe.app/validation_error', status: 422 });
    }

    if (!globalStore.trustedContacts.has(userId)) {
      globalStore.trustedContacts.set(userId, []);
    }

    const contacts = globalStore.trustedContacts.get(userId)!;
    if (contacts.length >= 5) {
      return reply.code(400).send({
        type: 'https://errors.vibe.app/limit_exceeded',
        status: 400,
        title: 'Limit Exceeded',
        detail: 'Maximum 5 trusted contacts allowed (Chapter 10.5)',
      });
    }

    const contactId = crypto.randomUUID();
    const newContact = {
      id: contactId,
      kind: parsed.data.kind,
      value: parsed.data.value,
      name: parsed.data.name,
    };
    contacts.push(newContact);

    return reply.code(201).send({ contact: newContact });
  });

  // DELETE /v1/trusted_contacts/:id
  fastify.delete('/trusted_contacts/:id', async (request, reply) => {
    const userId = getAuthUserId(request);
    if (!userId) {
      return reply.code(401).send({ type: 'https://errors.vibe.app/unauthorized', status: 401, title: 'Unauthorized' });
    }

    const { id } = request.params as { id: string };
    const contacts = globalStore.trustedContacts.get(userId) || [];
    globalStore.trustedContacts.set(userId, contacts.filter((c) => c.id !== id));

    return reply.code(200).send({ message: 'Trusted contact removed' });
  });

  // Friends System (Minimal Social Layer, Chapter 11)
  fastify.get('/friends', async (request, reply) => {
    const userId = getAuthUserId(request);
    if (!userId) return reply.code(401).send({ status: 401, title: 'Unauthorized' });

    const friendIds = Array.from(globalStore.friends.get(userId) || []);
    const friends = friendIds.map((fId) => {
      const u = globalStore.users.get(fId);
      return {
        userId: fId,
        displayName: u?.displayName || 'Friend',
        age: u ? new Date().getFullYear() - u.dobYear : 20,
        phoneVerified: u?.phoneVerified || false,
      };
    });

    return reply.code(200).send({ friends, count: friends.length });
  });

  fastify.post('/friends/request', async (request, reply) => {
    const userId = getAuthUserId(request);
    if (!userId) return reply.code(401).send({ status: 401, title: 'Unauthorized' });

    const { subject_id } = (request.body as any) || {};
    const requestId = crypto.randomUUID();
    globalStore.friendRequests.set(requestId, {
      id: requestId,
      from: userId,
      to: subject_id,
      createdAt: new Date().toISOString(),
    });

    return reply.code(200).send({ request_id: requestId, message: 'Friend request sent' });
  });

  fastify.post('/friends/accept', async (request, reply) => {
    const userId = getAuthUserId(request);
    if (!userId) return reply.code(401).send({ status: 401, title: 'Unauthorized' });

    const { request_id, subject_id } = (request.body as any) || {};
    const targetUserId = subject_id || globalStore.friendRequests.get(request_id)?.from;

    if (!targetUserId) {
      return reply.code(404).send({ status: 404, title: 'Request Not Found' });
    }

    if (!globalStore.friends.has(userId)) globalStore.friends.set(userId, new Set());
    if (!globalStore.friends.has(targetUserId)) globalStore.friends.set(targetUserId, new Set());

    const userFriends = globalStore.friends.get(userId)!;
    if (userFriends.size >= 50) {
      return reply.code(400).send({ status: 400, title: 'Friends list capped at 50' });
    }

    userFriends.add(targetUserId);
    globalStore.friends.get(targetUserId)!.add(userId);

    return reply.code(200).send({ message: 'Friend request accepted bilaterally' });
  });
}
