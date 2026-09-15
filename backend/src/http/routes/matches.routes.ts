import { FastifyInstance, FastifyPluginOptions } from 'fastify';
import { getAuthUserId } from './profile.routes.js';
import { globalStore } from '../../db/store.js';
import { Match, Meetup } from '../../domain/types.js';
import { realtimeGateway } from '../../realtime/gateway.js';

export async function matchesRoutes(fastify: FastifyInstance, _options: FastifyPluginOptions) {
  // POST /v1/matches/:match_id/accept
  fastify.post('/matches/:match_id/accept', async (request, reply) => {
    const userId = getAuthUserId(request);
    if (!userId) {
      return reply.code(401).send({ type: 'https://errors.vibe.app/unauthorized', status: 401, title: 'Unauthorized' });
    }

    const { match_id } = request.params as { match_id: string };
    const { target_user_id, origin_intent_id } = (request.body as any) || {};

    let match = globalStore.matches.get(match_id);
    if (!match && target_user_id) {
      // Create new match row
      match = {
        matchId: match_id,
        userAId: userId,
        userBId: target_user_id,
        originIntentA: origin_intent_id || crypto.randomUUID(),
        originIntentB: crypto.randomUUID(),
        createdAt: new Date().toISOString(),
        state: 'chat_open',
      };
      globalStore.matches.set(match_id, match);

      // Auto-initialize meetup for planning (Chapter 8.2)
      const meetupId = crypto.randomUUID();
      const newMeetup: Meetup = {
        meetupId,
        hostId: userId,
        participantIds: [userId, target_user_id],
        activitySubtype: 'cafe_hang',
        placeName: 'Blue Bottle Coffee',
        placeAddress: '450 W 15th St, New York',
        startAt: new Date(Date.now() + 2 * 3600 * 1000).toISOString(),
        state: 'confirmed',
        createdViaMatchIds: [match_id],
        createdAt: new Date().toISOString(),
      };
      globalStore.meetups.set(meetupId, newMeetup);

      // Realtime notification to other participant
      realtimeGateway.sendToUser(target_user_id, {
        type: 'match.opened',
        match_id,
        by: userId,
        meetup_id: meetupId,
      });

      return reply.code(200).send({
        match,
        meetup: newMeetup,
        status: 'bilateral_accepted',
      });
    }

    if (match) {
      match.state = 'chat_open';
      return reply.code(200).send({ match, status: 'accepted' });
    }

    return reply.code(404).send({ type: 'https://errors.vibe.app/not_found', status: 404, title: 'Match not found' });
  });

  // POST /v1/matches/:match_id/decline
  fastify.post('/matches/:match_id/decline', async (request, reply) => {
    const userId = getAuthUserId(request);
    if (!userId) {
      return reply.code(401).send({ type: 'https://errors.vibe.app/unauthorized', status: 401, title: 'Unauthorized' });
    }

    const { match_id } = request.params as { match_id: string };
    const { reason } = (request.body as any) || {};

    const match = globalStore.matches.get(match_id);
    if (match) {
      match.state = 'unmatched';
      match.unmatchReason = reason || 'declined_by_user';
    }

    return reply.code(200).send({
      message: 'Match declined',
      reason_code: reason || 'declined',
    });
  });
}
