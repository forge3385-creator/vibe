import client from 'prom-client';
export declare const httpRequestDurationMicroseconds: client.Histogram<"method" | "route" | "code">;
export declare const activeWebSocketConnections: client.Gauge<string>;
export declare const distressClassifierHits: client.Counter<string>;
export declare const completedMeetupsCounter: client.Counter<string>;
export declare function getMetrics(): Promise<string>;
