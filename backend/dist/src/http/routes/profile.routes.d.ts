import { FastifyInstance, FastifyPluginOptions, FastifyRequest } from 'fastify';
export declare function getAuthUserId(request: FastifyRequest): string | null;
export declare function profileRoutes(fastify: FastifyInstance, _options: FastifyPluginOptions): Promise<void>;
