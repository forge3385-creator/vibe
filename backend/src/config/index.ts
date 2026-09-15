import dotenv from 'dotenv';
dotenv.config();

export const config = {
  port: parseInt(process.env.PORT || '3000', 10),
  host: process.env.HOST || '0.0.0.0',
  jwtSecret: process.env.JWT_SECRET || 'vibe_master_jwt_secret_key_2026_purple_900',
  jwtExpiresIn: '15m',
  refreshTokenExpiresIn: '30d',
  nodeEnv: process.env.NODE_ENV || 'development',
  region: process.env.REGION || 'us-east-1',
  rateLimit: {
    maxPerUser: 60,
    timeWindow: '1 minute',
  },
  suggestionSlaMs: 3000,
  maxSuggestionsPerIntent: 12,
  chatRetentionDays: 90,
};
