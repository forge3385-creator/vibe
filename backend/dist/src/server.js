import { buildApp } from './app.js';
import { config } from './config/index.js';
import { realtimeGateway } from './realtime/gateway.js';
async function main() {
    const app = await buildApp();
    // Start HTTP server
    await app.listen({ port: config.port, host: config.host });
    console.log(`[Vibe Backend] Server listening on http://${config.host}:${config.port}`);
    console.log(`[Vibe Backend] OpenAPI documentation at http://${config.host}:${config.port}/docs`);
    console.log(`[Vibe Backend] Prometheus metrics at http://${config.host}:${config.port}/metrics`);
    // Attach Realtime WebSocket Gateway on /v1/realtime
    realtimeGateway.attach(app.server);
    console.log(`[Vibe Backend] Realtime WebSocket gateway attached on wss://${config.host}:${config.port}/v1/realtime`);
}
main().catch((err) => {
    console.error('[Vibe Backend] Fatal startup error:', err);
    process.exit(1);
});
//# sourceMappingURL=server.js.map