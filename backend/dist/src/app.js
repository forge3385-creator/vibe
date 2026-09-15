import Fastify from 'fastify';
import cors from '@fastify/cors';
import helmet from '@fastify/helmet';
import rateLimit from '@fastify/rate-limit';
import swagger from '@fastify/swagger';
import swaggerUi from '@fastify/swagger-ui';
import path from 'path';
import fs from 'fs';
import { getMetrics, httpRequestDurationMicroseconds } from './observability/metrics.js';
import { authRoutes } from './http/routes/auth.routes.js';
import { profileRoutes } from './http/routes/profile.routes.js';
import { intentsRoutes } from './http/routes/intents.routes.js';
import { suggestionsRoutes } from './http/routes/suggestions.routes.js';
import { matchesRoutes } from './http/routes/matches.routes.js';
import { meetupsRoutes } from './http/routes/meetups.routes.js';
import { chatRoutes } from './http/routes/chat.routes.js';
import { journalRoutes } from './http/routes/journal.routes.js';
import { safetyRoutes } from './http/routes/safety.routes.js';
import { subscriptionsRoutes } from './http/routes/subscriptions.routes.js';
import { adminRoutes } from './http/routes/admin.routes.js';
export async function buildApp() {
    const app = Fastify({
        logger: false,
        genReqId: () => crypto.randomUUID(),
    });
    // Middleware
    await app.register(cors, {
        origin: true,
        methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
        credentials: true,
    });
    await app.register(helmet, {
        contentSecurityPolicy: false,
    });
    await app.register(rateLimit, {
        max: 600,
        timeWindow: '1 minute',
    });
    // Swagger OpenAPI 3.1 Documentation
    await app.register(swagger, {
        openapi: {
            openapi: '3.1.0',
            info: {
                title: 'Vibe API',
                description: 'End-to-End API Specification for Vibe: Intention into Real-World Connection',
                version: '1.0.0',
            },
            servers: [
                { url: 'http://localhost:3000', description: 'Local Development' },
                { url: 'https://api.vibe.app', description: 'Production Gateway' },
            ],
            components: {
                securitySchemes: {
                    bearerAuth: {
                        type: 'http',
                        scheme: 'bearer',
                        bearerFormat: 'JWT',
                    },
                },
            },
        },
    });
    await app.register(swaggerUi, {
        routePrefix: '/docs',
        uiConfig: {
            docExpansion: 'list',
            deepLinking: false,
        },
    });
    // Serve Web Client assets directly
    const getWebFilePath = (filename) => {
        const candidates = [
            path.resolve(process.cwd(), '../web', filename),
            path.resolve(process.cwd(), 'web', filename),
            path.resolve(process.cwd(), '../../web', filename),
        ];
        for (const c of candidates) {
            if (fs.existsSync(c))
                return c;
        }
        return candidates[0];
    };
    app.get('/', async (_request, reply) => {
        const filePath = getWebFilePath('index.html');
        if (fs.existsSync(filePath)) {
            reply.type('text/html').send(fs.readFileSync(filePath, 'utf8'));
        }
        else {
            reply.code(404).send('index.html not found');
        }
    });
    app.get('/index.html', async (_request, reply) => {
        const filePath = getWebFilePath('index.html');
        reply.type('text/html').send(fs.readFileSync(filePath, 'utf8'));
    });
    app.get('/style.css', async (_request, reply) => {
        const filePath = getWebFilePath('style.css');
        reply.type('text/css').send(fs.readFileSync(filePath, 'utf8'));
    });
    app.get('/app.js', async (_request, reply) => {
        const filePath = getWebFilePath('app.js');
        reply.type('application/javascript').send(fs.readFileSync(filePath, 'utf8'));
    });
    // Request timing histogram
    app.addHook('onRequest', (request, _reply, done) => {
        request.startTime = Date.now();
        done();
    });
    app.addHook('onResponse', (request, reply, done) => {
        const duration = Date.now() - (request.startTime || Date.now());
        httpRequestDurationMicroseconds
            .labels(request.method, request.routeOptions.url || request.url, reply.statusCode.toString())
            .observe(duration);
        done();
    });
    // Metrics endpoint
    app.get('/metrics', async (_request, reply) => {
        const metrics = await getMetrics();
        reply.header('Content-Type', 'text/plain');
        return reply.send(metrics);
    });
    // Health check
    app.get('/v1/health', async (_request, reply) => {
        return reply.code(200).send({
            status: 'healthy',
            service: 'vibe-backend',
            timestamp: new Date().toISOString(),
            version: '1.0.0',
        });
    });
    // Register API Routes
    await app.register(authRoutes, { prefix: '/v1' });
    await app.register(profileRoutes, { prefix: '/v1' });
    await app.register(intentsRoutes, { prefix: '/v1' });
    await app.register(suggestionsRoutes, { prefix: '/v1' });
    await app.register(matchesRoutes, { prefix: '/v1' });
    await app.register(meetupsRoutes, { prefix: '/v1' });
    await app.register(chatRoutes, { prefix: '/v1' });
    await app.register(journalRoutes, { prefix: '/v1' });
    await app.register(safetyRoutes, { prefix: '/v1' });
    await app.register(subscriptionsRoutes, { prefix: '/v1' });
    await app.register(adminRoutes, { prefix: '/v1' });
    // Custom RFC 7807 problem+json error handler
    app.setErrorHandler((error, _request, reply) => {
        const statusCode = error.statusCode || 500;
        reply.code(statusCode).type('application/problem+json').send({
            type: `https://errors.vibe.app/${error.code || 'internal_server_error'}`,
            title: error.name || 'Internal Error',
            status: statusCode,
            detail: error.message,
        });
    });
    return app;
}
//# sourceMappingURL=app.js.map