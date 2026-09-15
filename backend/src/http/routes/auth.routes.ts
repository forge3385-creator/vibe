import { FastifyInstance, FastifyPluginOptions } from 'fastify';
import { z } from 'zod';
import jwt from 'jsonwebtoken';
import { config } from '../../config/index.js';
import { globalStore } from '../../db/store.js';
import { encryptField, hashPhone } from '../../crypto/envelope.js';
import { User } from '../../domain/types.js';

const StartSignupSchema = z.object({
  region_code: z.string().length(2),
  dob_year: z.number().int().min(1900).max(new Date().getFullYear()),
  display_name: z.string().min(1).max(40).optional(),
});

const VerifyPhoneSchema = z.object({
  signup_token: z.string().min(1),
  phone_e164: z.string().regex(/^\+[1-9]\d{1,14}$/, 'Invalid E.164 phone format'),
  otp: z.string().length(6),
});

const SkipPhoneSchema = z.object({
  signup_token: z.string().min(1),
});

const otpRequestTracker = new Map<string, number[]>(); // phone -> timestamps

export async function authRoutes(fastify: FastifyInstance, _options: FastifyPluginOptions) {
  // POST /v1/auth/start_signup
  fastify.post('/auth/start_signup', async (request, reply) => {
    const parseResult = StartSignupSchema.safeParse(request.body);
    if (!parseResult.success) {
      return reply.code(422).send({
        type: 'https://errors.vibe.app/validation_error',
        title: 'Validation Failed',
        status: 422,
        invalid_params: parseResult.error.issues,
      });
    }

    const { region_code, dob_year, display_name = 'Vibe User' } = parseResult.data;
    const currentYear = new Date().getFullYear();
    const age = currentYear - dob_year;

    // Hard gate under-16 (Chapter 5.2.3 & 23.4)
    if (age < 16) {
      globalStore.under16AttemptsCount++;
      return reply.code(403).send({
        type: 'https://errors.vibe.app/age_gate_failed',
        title: 'Age Restricted',
        status: 403,
        detail: 'Vibe is for ages 16+. We cannot create an account for you yet.',
      });
    }

    const signupToken = jwt.sign(
      { region_code, dob_year, display_name, purpose: 'signup' },
      config.jwtSecret,
      { expiresIn: '30m' }
    );

    return reply.code(200).send({
      signup_token: signupToken,
      region_code,
      dob_year,
    });
  });

  // POST /v1/auth/verify_phone
  fastify.post('/auth/verify_phone', async (request, reply) => {
    const parseResult = VerifyPhoneSchema.safeParse(request.body);
    if (!parseResult.success) {
      return reply.code(422).send({
        type: 'https://errors.vibe.app/validation_error',
        title: 'Validation Failed',
        status: 422,
        invalid_params: parseResult.error.issues,
      });
    }

    const { signup_token, phone_e164, otp } = parseResult.data;

    // Rate limit OTP: 5 requests per 60s
    const now = Date.now();
    const timestamps = otpRequestTracker.get(phone_e164) || [];
    const recentTimestamps = timestamps.filter((t) => now - t < 60000);
    if (recentTimestamps.length >= 5) {
      return reply.code(429).send({
        type: 'https://errors.vibe.app/rate_limited',
        title: 'Too Many Requests',
        status: 429,
        detail: 'Too many OTP attempts. Please wait 60 seconds.',
      });
    }
    recentTimestamps.push(now);
    otpRequestTracker.set(phone_e164, recentTimestamps);

    let decodedSignup: any;
    try {
      decodedSignup = jwt.verify(signup_token, config.jwtSecret);
    } catch {
      return reply.code(401).send({
        type: 'https://errors.vibe.app/unauthorized',
        title: 'Invalid Signup Token',
        status: 401,
      });
    }

    const userId = crypto.randomUUID();
    const displayName = decodedSignup.display_name || 'Alex';
    const encryptedName = encryptField(displayName);
    const phoneHashed = hashPhone(phone_e164, decodedSignup.region_code || 'US');

    const newUser: User = {
      userId,
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
      displayNameEncrypted: encryptedName,
      displayName,
      dobYear: decodedSignup.dob_year,
      regionCode: decodedSignup.region_code,
      locale: 'en_US',
      phoneHash: phoneHashed,
      phoneVerified: true,
      photoVerified: false,
      preferences: { units: 'km', theme: 'light' },
      lastActiveAt: new Date().toISOString(),
      status: 'active',
      reportRate: 0,
      completedMeetups: 0,
    };

    globalStore.users.set(userId, newUser);
    globalStore.userPrivacy.set(userId, {
      userId,
      discoverableToFriends: false,
      sharePhotoByDefault: false,
      journalEncrypted: true,
      trustedContactIds: [],
    });

    const accessToken = jwt.sign(
      { userId, unverified_phone: false },
      config.jwtSecret,
      { expiresIn: 900 }
    );
    const refreshToken = jwt.sign(
      { userId, type: 'refresh' },
      config.jwtSecret,
      { expiresIn: 30 * 86400 }
    );

    return reply.code(200).send({
      access_token: accessToken,
      refresh_token: refreshToken,
      user: {
        userId,
        displayName,
        phoneVerified: true,
        regionCode: newUser.regionCode,
      },
    });
  });

  // POST /v1/auth/skip_phone
  fastify.post('/auth/skip_phone', async (request, reply) => {
    const parseResult = SkipPhoneSchema.safeParse(request.body);
    if (!parseResult.success) {
      return reply.code(422).send({
        type: 'https://errors.vibe.app/validation_error',
        title: 'Validation Failed',
        status: 422,
      });
    }

    let decodedSignup: any;
    try {
      decodedSignup = jwt.verify(parseResult.data.signup_token, config.jwtSecret);
    } catch {
      return reply.code(401).send({
        type: 'https://errors.vibe.app/unauthorized',
        title: 'Invalid Signup Token',
        status: 401,
      });
    }

    const userId = crypto.randomUUID();
    const displayName = decodedSignup.display_name || 'New Explorer';
    const encryptedName = encryptField(displayName);

    const newUser: User = {
      userId,
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
      displayNameEncrypted: encryptedName,
      displayName,
      dobYear: decodedSignup.dob_year,
      regionCode: decodedSignup.region_code,
      locale: 'en_US',
      phoneVerified: false,
      photoVerified: false,
      preferences: { units: 'km', theme: 'light' },
      lastActiveAt: new Date().toISOString(),
      status: 'active',
      reportRate: 0,
      completedMeetups: 0,
    };

    globalStore.users.set(userId, newUser);
    globalStore.userPrivacy.set(userId, {
      userId,
      discoverableToFriends: false,
      sharePhotoByDefault: false,
      journalEncrypted: true,
      trustedContactIds: [],
    });

    const accessToken = jwt.sign(
      { userId, unverified_phone: true },
      config.jwtSecret,
      { expiresIn: 900 }
    );
    const refreshToken = jwt.sign(
      { userId, type: 'refresh' },
      config.jwtSecret,
      { expiresIn: 30 * 86400 }
    );

    return reply.code(200).send({
      access_token: accessToken,
      refresh_token: refreshToken,
      claims: { unverified_phone: true },
      user: {
        userId,
        displayName,
        phoneVerified: false,
        regionCode: newUser.regionCode,
      },
    });
  });

  // POST /v1/auth/refresh
  fastify.post('/auth/refresh', async (request, reply) => {
    const { refresh_token } = (request.body as any) || {};
    if (!refresh_token) {
      return reply.code(401).send({
        type: 'https://errors.vibe.app/unauthorized',
        title: 'Missing Refresh Token',
        status: 401,
      });
    }

    try {
      const decoded = jwt.verify(refresh_token, config.jwtSecret) as { userId: string };
      const user = globalStore.users.get(decoded.userId);
      if (!user || user.status !== 'active') {
        return reply.code(401).send({
          type: 'https://errors.vibe.app/unauthorized',
          title: 'User Not Active',
          status: 401,
        });
      }

      const newAccessToken = jwt.sign(
        { userId: user.userId, unverified_phone: !user.phoneVerified },
        config.jwtSecret,
        { expiresIn: 900 }
      );

      return reply.code(200).send({ access_token: newAccessToken });
    } catch {
      return reply.code(401).send({
        type: 'https://errors.vibe.app/unauthorized',
        title: 'Refresh Token Expired',
        status: 401,
        detail: 'Session expired. Please log in again.',
      });
    }
  });
}
