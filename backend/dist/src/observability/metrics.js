import client from 'prom-client';
const collectDefaultMetrics = client.collectDefaultMetrics;
collectDefaultMetrics({ prefix: 'vibe_' });
export const httpRequestDurationMicroseconds = new client.Histogram({
    name: 'vibe_http_request_duration_ms',
    help: 'Duration of HTTP requests in ms',
    labelNames: ['method', 'route', 'code'],
    buckets: [10, 50, 100, 200, 300, 500, 1000, 3000],
});
export const activeWebSocketConnections = new client.Gauge({
    name: 'vibe_active_websocket_connections',
    help: 'Number of active realtime WebSocket connections',
});
export const distressClassifierHits = new client.Counter({
    name: 'vibe_distress_classifier_hits_total',
    help: 'Total number of distress classifier triggers',
});
export const completedMeetupsCounter = new client.Counter({
    name: 'vibe_completed_meetups_total',
    help: 'Total number of completed offline meetups',
});
export async function getMetrics() {
    return await client.register.metrics();
}
//# sourceMappingURL=metrics.js.map