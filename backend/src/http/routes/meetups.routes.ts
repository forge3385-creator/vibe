import { FastifyInstance, FastifyPluginOptions } from 'fastify';
import { z } from 'zod';
import { getAuthUserId } from './profile.routes.js';
import { globalStore } from '../../db/store.js';
import { Meetup, MeetupState } from '../../domain/types.js';
import { realtimeGateway } from '../../realtime/gateway.js';

const CreateMeetupSchema = z.object({
  participant_ids: z.array(z.string().uuid()).min(1).max(6),
  activity_subtype: z.string().min(1),
  place_id: z.string().optional(),
  place_name: z.string().optional(),
  place_address: z.string().optional(),
  start_at: z.string().datetime(),
  end_at: z.string().datetime().optional(),
  cost_share_total_cents: z.number().int().min(0).optional(),
  currency: z.string().length(3).optional(),
});

const PatchMeetupSchema = z.object({
  state: z.enum(['draft', 'proposed', 'accepted_partial', 'confirmed', 'in_progress', 'completed', 'cancelled', 'no_show']).optional(),
  start_at: z.string().datetime().optional(),
  end_at: z.string().datetime().optional(),
  place_name: z.string().optional(),
  place_address: z.string().optional(),
  cost_share_total_cents: z.number().int().min(0).optional(),
});

export async function meetupsRoutes(fastify: FastifyInstance, _options: FastifyPluginOptions) {
  // GET /v1/meetups
  fastify.get('/meetups', async (request, reply) => {
    const userId = getAuthUserId(request);
    if (!userId) {
      return reply.code(401).send({ type: 'https://errors.vibe.app/unauthorized', status: 401, title: 'Unauthorized' });
    }

    const userMeetups: Meetup[] = [];
    for (const meetup of globalStore.meetups.values()) {
      if (meetup.participantIds.includes(userId) || meetup.hostId === userId) {
        userMeetups.push(meetup);
      }
    }

    userMeetups.sort((a, b) => new Date(a.startAt).getTime() - new Date(b.startAt).getTime());
    return reply.code(200).send({ meetups: userMeetups });
  });

  // POST /v1/meetups
  fastify.post('/meetups', async (request, reply) => {
    const userId = getAuthUserId(request);
    if (!userId) {
      return reply.code(401).send({ type: 'https://errors.vibe.app/unauthorized', status: 401, title: 'Unauthorized' });
    }

    const parsed = CreateMeetupSchema.safeParse(request.body);
    if (!parsed.success) {
      return reply.code(422).send({
        type: 'https://errors.vibe.app/validation_error',
        status: 422,
        invalid_params: parsed.error.issues,
      });
    }

    const data = parsed.data;
    const meetupId = crypto.randomUUID();
    const allParticipants = Array.from(new Set([userId, ...data.participant_ids]));

    const newMeetup: Meetup = {
      meetupId,
      hostId: userId,
      participantIds: allParticipants,
      activitySubtype: data.activity_subtype,
      placeId: data.place_id,
      placeName: data.place_name || 'Cafe Meetup',
      placeAddress: data.place_address || 'Central Square',
      startAt: data.start_at,
      endAt: data.end_at,
      state: 'proposed',
      costShareTotalCents: data.cost_share_total_cents,
      currency: data.currency || 'USD',
      createdViaMatchIds: [],
      createdAt: new Date().toISOString(),
    };

    globalStore.meetups.set(meetupId, newMeetup);

    // Broadcast to participants
    for (const pId of allParticipants) {
      realtimeGateway.sendToUser(pId, {
        type: 'meetup.state.changed',
        meetup_id: meetupId,
        state: 'proposed',
      });
    }

    return reply.code(201).send({ meetup: newMeetup });
  });

  // GET /v1/meetups/:id
  fastify.get('/meetups/:id', async (request, reply) => {
    const userId = getAuthUserId(request);
    if (!userId) {
      return reply.code(401).send({ type: 'https://errors.vibe.app/unauthorized', status: 401, title: 'Unauthorized' });
    }

    const { id } = request.params as { id: string };
    const meetup = globalStore.meetups.get(id);
    if (!meetup) {
      return reply.code(404).send({ type: 'https://errors.vibe.app/not_found', status: 404, title: 'Meetup Not Found' });
    }

    const attendees = meetup.participantIds.map((pId) => {
      const u = globalStore.users.get(pId);
      return {
        userId: pId,
        displayName: u?.displayName || 'Attendee',
        isHost: pId === meetup.hostId,
        photoVerified: u?.photoVerified || false,
      };
    });

    return reply.code(200).send({ meetup, attendees });
  });

  // PATCH /v1/meetups/:id
  fastify.patch('/meetups/:id', async (request, reply) => {
    const userId = getAuthUserId(request);
    if (!userId) {
      return reply.code(401).send({ type: 'https://errors.vibe.app/unauthorized', status: 401, title: 'Unauthorized' });
    }

    const { id } = request.params as { id: string };
    const meetup = globalStore.meetups.get(id);
    if (!meetup) {
      return reply.code(404).send({ type: 'https://errors.vibe.app/not_found', status: 404, title: 'Meetup Not Found' });
    }

    const parsed = PatchMeetupSchema.safeParse(request.body);
    if (!parsed.success) {
      return reply.code(422).send({ type: 'https://errors.vibe.app/validation_error', status: 422, invalid_params: parsed.error.issues });
    }

    if (parsed.data.state) meetup.state = parsed.data.state as MeetupState;
    if (parsed.data.start_at) meetup.startAt = parsed.data.start_at;
    if (parsed.data.end_at) meetup.endAt = parsed.data.end_at;
    if (parsed.data.place_name) meetup.placeName = parsed.data.place_name;
    if (parsed.data.place_address) meetup.placeAddress = parsed.data.place_address;
    if (parsed.data.cost_share_total_cents !== undefined) meetup.costShareTotalCents = parsed.data.cost_share_total_cents;

    // Realtime sync
    for (const pId of meetup.participantIds) {
      realtimeGateway.sendToUser(pId, {
        type: 'meetup.state.changed',
        meetup_id: id,
        state: meetup.state,
      });
    }

    return reply.code(200).send({ meetup });
  });

  // POST /v1/meetups/:id/trusted_share
  fastify.post('/meetups/:id/trusted_share', async (request, reply) => {
    const userId = getAuthUserId(request);
    if (!userId) {
      return reply.code(401).send({ type: 'https://errors.vibe.app/unauthorized', status: 401, title: 'Unauthorized' });
    }

    const { id } = request.params as { id: string };
    const meetup = globalStore.meetups.get(id);
    if (!meetup) {
      return reply.code(404).send({ type: 'https://errors.vibe.app/not_found', status: 404, title: 'Meetup Not Found' });
    }

    meetup.trustedShareEndsAt = new Date(Date.now() + 4 * 3600 * 1000).toISOString();

    return reply.code(200).send({
      message: 'Live meetup shared with trusted contact',
      trusted_share_ends_at: meetup.trustedShareEndsAt,
    });
  });

  // POST /v1/meetups/:id/complete
  fastify.post('/meetups/:id/complete', async (request, reply) => {
    const userId = getAuthUserId(request);
    if (!userId) {
      return reply.code(401).send({ type: 'https://errors.vibe.app/unauthorized', status: 401, title: 'Unauthorized' });
    }

    const { id } = request.params as { id: string };
    const meetup = globalStore.meetups.get(id);
    if (!meetup) {
      return reply.code(404).send({ type: 'https://errors.vibe.app/not_found', status: 404, title: 'Meetup Not Found' });
    }

    meetup.state = 'completed';
    meetup.endAt = new Date().toISOString();

    // Increment completed meetups counter (capped at 50 per Section 7.4)
    for (const pId of meetup.participantIds) {
      const u = globalStore.users.get(pId);
      if (u) {
        u.completedMeetups = Math.min(50, u.completedMeetups + 1);
      }
    }

    return reply.code(200).send({
      message: 'Meetup marked completed',
      meetup,
    });
  });
}
