import { z } from 'zod';
import { getAuthUserId } from './profile.routes.js';
import { globalStore } from '../../db/store.js';
import { validateReceipt } from '../../services/subscription_validator.js';
const ValidateReceiptSchema = z.object({
    provider: z.enum(['apple', 'google']),
    receipt_data: z.string().min(1),
    plan_id: z.enum(['monthly', 'annual']),
});
export async function subscriptionsRoutes(fastify, _options) {
    // POST /v1/subscriptions/validate_receipt
    fastify.post('/subscriptions/validate_receipt', async (request, reply) => {
        const userId = getAuthUserId(request);
        if (!userId) {
            return reply.code(401).send({ type: 'https://errors.vibe.app/unauthorized', status: 401, title: 'Unauthorized' });
        }
        const parsed = ValidateReceiptSchema.safeParse(request.body);
        if (!parsed.success) {
            return reply.code(422).send({ type: 'https://errors.vibe.app/validation_error', status: 422, invalid_params: parsed.error.issues });
        }
        const validation = await validateReceipt({
            userId,
            provider: parsed.data.provider,
            receiptData: parsed.data.receipt_data,
            planId: parsed.data.plan_id,
        });
        if (!validation.valid) {
            return reply.code(400).send({
                type: 'https://errors.vibe.app/invalid_receipt',
                title: 'Receipt Validation Failed',
                status: 400,
                detail: 'Receipt could not be verified by store provider.',
            });
        }
        const subscription = {
            subscriptionId: crypto.randomUUID(),
            userId,
            planId: validation.planId,
            provider: parsed.data.provider,
            providerSubscriptionId: validation.providerSubscriptionId,
            status: validation.status,
            startedAt: new Date().toISOString(),
            renewAt: validation.renewAt,
        };
        globalStore.subscriptions.set(userId, subscription);
        return reply.code(200).send({
            message: 'Subscription active',
            subscription,
            premium_benefits: {
                priority_suggestion_ordering: true,
                advanced_filters: true,
                journal_cap_mb: 500,
                recurring_plans: true,
            },
        });
    });
    // GET /v1/subscriptions/me
    fastify.get('/subscriptions/me', async (request, reply) => {
        const userId = getAuthUserId(request);
        if (!userId) {
            return reply.code(401).send({ type: 'https://errors.vibe.app/unauthorized', status: 401, title: 'Unauthorized' });
        }
        const subscription = globalStore.subscriptions.get(userId);
        if (!subscription) {
            return reply.code(200).send({
                plan_id: 'free',
                status: 'active',
                benefits: {
                    suggestions_limit: 12,
                    journal_cap_mb: 50,
                    unlimited_matching: true,
                },
            });
        }
        return reply.code(200).send({ subscription });
    });
    // DELETE /v1/subscriptions/me
    fastify.delete('/subscriptions/me', async (request, reply) => {
        const userId = getAuthUserId(request);
        if (!userId) {
            return reply.code(401).send({ type: 'https://errors.vibe.app/unauthorized', status: 401, title: 'Unauthorized' });
        }
        const subscription = globalStore.subscriptions.get(userId);
        if (subscription) {
            subscription.status = 'cancelled';
            subscription.cancelledAt = new Date().toISOString();
        }
        return reply.code(200).send({
            message: 'Subscription cancelled. Access remains until end of billing cycle.',
            subscription,
        });
    });
}
//# sourceMappingURL=subscriptions.routes.js.map