import { z } from 'zod';
import jwt from 'jsonwebtoken';
import { config } from '../../config/index.js';
import { globalStore } from '../../db/store.js';
export function getAuthUserId(request) {
    const authHeader = request.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer '))
        return null;
    const token = authHeader.split(' ')[1];
    try {
        const decoded = jwt.verify(token, config.jwtSecret);
        return decoded.userId;
    }
    catch {
        return null;
    }
}
const UpdateProfileSchema = z.object({
    display_name: z.string().min(1).max(40).optional(),
    units: z.enum(['km', 'miles']).optional(),
    language: z.string().optional(),
    theme: z.enum(['light', 'dark']).optional(),
});
export async function profileRoutes(fastify, _options) {
    // GET /v1/me
    fastify.get('/me', async (request, reply) => {
        const userId = getAuthUserId(request);
        if (!userId) {
            return reply.code(401).send({ type: 'https://errors.vibe.app/unauthorized', status: 401, title: 'Unauthorized' });
        }
        const user = globalStore.users.get(userId);
        if (!user) {
            return reply.code(404).send({ type: 'https://errors.vibe.app/not_found', status: 404, title: 'User Not Found' });
        }
        const privacy = globalStore.userPrivacy.get(userId);
        const interests = globalStore.userInterests.get(userId) || [];
        const subscription = globalStore.subscriptions.get(userId);
        return reply.code(200).send({
            user_id: user.userId,
            display_name: user.displayName,
            dob_year: user.dobYear,
            region_code: user.regionCode,
            locale: user.locale,
            phone_verified: user.phoneVerified,
            photo_verified: user.photoVerified,
            primary_photo_url: user.primaryPhotoUrl,
            preferences: user.preferences,
            interests,
            privacy: privacy || {
                discoverable_to_friends: false,
                share_photo_by_default: false,
                journal_encrypted: true,
            },
            subscription: subscription ? {
                plan_id: subscription.planId,
                status: subscription.status,
                renew_at: subscription.renewAt,
            } : { plan_id: 'free', status: 'active' },
            completed_meetups: user.completedMeetups,
        });
    });
    // PATCH /v1/me
    fastify.patch('/me', async (request, reply) => {
        const userId = getAuthUserId(request);
        if (!userId) {
            return reply.code(401).send({ type: 'https://errors.vibe.app/unauthorized', status: 401, title: 'Unauthorized' });
        }
        const user = globalStore.users.get(userId);
        if (!user) {
            return reply.code(404).send({ type: 'https://errors.vibe.app/not_found', status: 404, title: 'User Not Found' });
        }
        const parsed = UpdateProfileSchema.safeParse(request.body);
        if (!parsed.success) {
            return reply.code(422).send({ type: 'https://errors.vibe.app/validation_error', status: 422, invalid_params: parsed.error.issues });
        }
        if (parsed.data.display_name)
            user.displayName = parsed.data.display_name;
        if (parsed.data.units)
            user.preferences.units = parsed.data.units;
        if (parsed.data.language)
            user.preferences.language = parsed.data.language;
        if (parsed.data.theme)
            user.preferences.theme = parsed.data.theme;
        user.updatedAt = new Date().toISOString();
        return reply.code(200).send({ message: 'Profile updated', user });
    });
    // POST /v1/me/photo
    fastify.post('/me/photo', async (request, reply) => {
        const userId = getAuthUserId(request);
        if (!userId) {
            return reply.code(401).send({ type: 'https://errors.vibe.app/unauthorized', status: 401, title: 'Unauthorized' });
        }
        const user = globalStore.users.get(userId);
        if (!user)
            return reply.code(404).send({ status: 404, title: 'User Not Found' });
        user.primaryPhotoUrl = `https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&h=200&fit=crop&crop=faces`;
        return reply.code(200).send({
            photo_url: user.primaryPhotoUrl,
            photo_verified: user.photoVerified,
        });
    });
    // POST /v1/me/photo_verify
    fastify.post('/me/photo_verify', async (request, reply) => {
        const userId = getAuthUserId(request);
        if (!userId) {
            return reply.code(401).send({ type: 'https://errors.vibe.app/unauthorized', status: 401, title: 'Unauthorized' });
        }
        const user = globalStore.users.get(userId);
        if (!user)
            return reply.code(404).send({ status: 404, title: 'User Not Found' });
        user.photoVerified = true;
        return reply.code(200).send({
            photo_verified: true,
            badge: 'Photo Verified',
        });
    });
    // GET /v1/me/export
    fastify.get('/me/export', async (request, reply) => {
        const userId = getAuthUserId(request);
        if (!userId) {
            return reply.code(401).send({ type: 'https://errors.vibe.app/unauthorized', status: 401, title: 'Unauthorized' });
        }
        const user = globalStore.users.get(userId);
        const interests = globalStore.userInterests.get(userId) || [];
        const privacy = globalStore.userPrivacy.get(userId);
        const journals = globalStore.journals.get(userId) || [];
        const exportData = {
            user,
            interests,
            privacy,
            journal_count: journals.length,
            exported_at: new Date().toISOString(),
            retention_notice: 'Export link valid for 24h per GDPR Article 20.',
        };
        return reply.code(200).send({
            export_url: `https://api.vibe.app/v1/downloads/export_${userId}.json`,
            expires_at: new Date(Date.now() + 86400000).toISOString(),
            data: exportData,
        });
    });
    // DELETE /v1/me
    fastify.delete('/me', async (request, reply) => {
        const userId = getAuthUserId(request);
        if (!userId) {
            return reply.code(401).send({ type: 'https://errors.vibe.app/unauthorized', status: 401, title: 'Unauthorized' });
        }
        const user = globalStore.users.get(userId);
        if (user) {
            user.status = 'deleted';
            user.deletedAt = new Date().toISOString();
        }
        return reply.code(202).send({
            message: 'Account soft-deleted. Hard-purge will execute in 30 days per GDPR Article 17.',
            status: 'deleted',
        });
    });
}
//# sourceMappingURL=profile.routes.js.map