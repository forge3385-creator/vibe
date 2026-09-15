import { FastifyInstance, FastifyPluginOptions } from 'fastify';
import { globalStore } from '../../db/store.js';

export async function adminRoutes(fastify: FastifyInstance, _options: FastifyPluginOptions) {
  // GET /v1/admin/reports
  fastify.get('/admin/reports', async (request, reply) => {
    const { status } = (request.query as any) || {};
    let reports = Array.from(globalStore.reports.values());

    if (status) {
      reports = reports.filter((r) => r.status === status);
    }

    return reply.code(200).send({
      reports,
      total: reports.length,
      under_16_attempts_count: globalStore.under16AttemptsCount,
    });
  });

  // POST /v1/admin/reports/:id/action
  fastify.post('/admin/reports/:id/action', async (request, reply) => {
    const { id } = request.params as { id: string };
    const { action, resolution_note } = (request.body as any) || {};

    const report = globalStore.reports.get(id);
    if (!report) {
      return reply.code(404).send({ type: 'https://errors.vibe.app/not_found', status: 404, title: 'Report Not Found' });
    }

    report.status = action === 'dismiss' ? 'closed_no_action' : 'closed_action';
    report.resolutionNote = resolution_note || `Admin action: ${action}`;

    if (action === 'ban') {
      const offendingUser = globalStore.users.get(report.subjectId);
      if (offendingUser) {
        offendingUser.status = 'suspended';
      }
    }

    return reply.code(200).send({ message: 'Moderation action applied', report });
  });
}
