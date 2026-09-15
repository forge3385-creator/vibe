import { pino } from 'pino';

// CI Log Scrubber to ensure no PII plaintext appears in logs (Chapter 15.8)
export const logger = pino({
  level: process.env.LOG_LEVEL || 'info',
  redact: {
    paths: ['req.headers.authorization', 'body.phone_e164', 'body.ciphertext', 'body.display_name'],
    censor: '[REDACTED_PII]',
  },
  serializers: {
    req(req: any) {
      return {
        id: req.id,
        method: req.method,
        url: req.url,
      };
    },
  },
});
