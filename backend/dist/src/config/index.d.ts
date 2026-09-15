export declare const config: {
    port: number;
    host: string;
    jwtSecret: string;
    jwtExpiresIn: string;
    refreshTokenExpiresIn: string;
    nodeEnv: string;
    region: string;
    rateLimit: {
        maxPerUser: number;
        timeWindow: string;
    };
    suggestionSlaMs: number;
    maxSuggestionsPerIntent: number;
    chatRetentionDays: number;
};
