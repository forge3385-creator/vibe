import test from 'node:test';
import assert from 'node:assert';
import { buildApp } from '../src/app.js';
import { fnComputeVibeScore } from '../src/services/vibe_score.js';
import { classifyDistress, FIXED_DISTRESS_RESPONSE } from '../src/services/distress_classifier.js';
import { generateVibeMirrorResponse, redactSensitiveTokens } from '../src/services/ai_companion.js';
import { validateReceipt } from '../src/services/subscription_validator.js';
import { encryptField, decryptField } from '../src/crypto/envelope.js';
test('Project VIBE Master Test Suite (Chapters 25 & 33 Matrix)', async (t) => {
    const app = await buildApp();
    await t.test('Section 33.1: Authentication & Onboarding (AUTH-1..5, OB-1..5)', async () => {
        // OB-1: DOB year < 16 Hard-stop
        const under16Res = await app.inject({
            method: 'POST',
            url: '/v1/auth/start_signup',
            payload: { region_code: 'US', dob_year: 2018, display_name: 'Kid' },
        });
        assert.strictEqual(under16Res.statusCode, 403);
        assert.ok(under16Res.json().detail.includes('16+'));
        // Valid age >= 16 start signup
        const validSignupRes = await app.inject({
            method: 'POST',
            url: '/v1/auth/start_signup',
            payload: { region_code: 'US', dob_year: 2002, display_name: 'Maya' },
        });
        assert.strictEqual(validSignupRes.statusCode, 200);
        const signupToken = validSignupRes.json().signup_token;
        assert.ok(signupToken);
        // AUTH-5: Invalid phone format fails validation (422)
        const invalidPhoneRes = await app.inject({
            method: 'POST',
            url: '/v1/auth/verify_phone',
            payload: { signup_token: signupToken, phone_e164: '+1abc', otp: '123456' },
        });
        assert.strictEqual(invalidPhoneRes.statusCode, 422);
        // AUTH-4 & OB-2: Skip phone produces unverified JWT
        const skipPhoneRes = await app.inject({
            method: 'POST',
            url: '/v1/auth/skip_phone',
            payload: { signup_token: signupToken },
        });
        assert.strictEqual(skipPhoneRes.statusCode, 200);
        const skipToken = skipPhoneRes.json().access_token;
        assert.ok(skipToken);
        assert.strictEqual(skipPhoneRes.json().user.phoneVerified, false);
    });
    await t.test('Section 33.3: Set Intent (INT-1..6)', async () => {
        // Signup a valid user
        const signupRes = await app.inject({
            method: 'POST',
            url: '/v1/auth/start_signup',
            payload: { region_code: 'US', dob_year: 2000, display_name: 'Dev' },
        });
        const phoneRes = await app.inject({
            method: 'POST',
            url: '/v1/auth/verify_phone',
            payload: { signup_token: signupRes.json().signup_token, phone_e164: '+12125550199', otp: '998877' },
        });
        const token = phoneRes.json().access_token;
        // INT-1: Missing energy -> 422
        const missingEnergyRes = await app.inject({
            method: 'POST',
            url: '/v1/intents',
            headers: { authorization: `Bearer ${token}` },
            payload: { activity_type: ['chill'], group_size_pref: 'one_on_one', time_window: 'today' },
        });
        assert.strictEqual(missingEnergyRes.statusCode, 422);
        // INT-2: 4 activities -> 422 (max is 3)
        const tooManyActRes = await app.inject({
            method: 'POST',
            url: '/v1/intents',
            headers: { authorization: `Bearer ${token}` },
            payload: { energy_level: 'medium', activity_type: ['chill', 'active', 'food', 'outdoor'], group_size_pref: 'one_on_one', time_window: 'today' },
        });
        assert.strictEqual(tooManyActRes.statusCode, 422);
        // INT-4: Valid Intent returns intent and suggestions
        const validIntentRes = await app.inject({
            method: 'POST',
            url: '/v1/intents',
            headers: { authorization: `Bearer ${token}` },
            payload: {
                energy_level: 'medium',
                activity_type: ['chill', 'food'],
                activity_subtype: ['cafe_hang', 'coffee'],
                group_size_pref: 'one_on_one',
                time_window: 'today',
                note: 'Coffee and casual chat',
                radius_km: 10,
                lat: 40.7128,
                lng: -74.006,
            },
        });
        assert.strictEqual(validIntentRes.statusCode, 200);
        assert.ok(validIntentRes.json().intent);
        assert.ok(Array.isArray(validIntentRes.json().suggestions));
    });
    await t.test('Section 33.4: Suggestions & Vibe Score (SUG-1..7)', async () => {
        // Mathematical formula correctness check
        const score = fnComputeVibeScore({
            energyA: 'medium',
            energyB: 'medium',
            overlapCount: 3,
            distanceKm: 1.5,
            radiusKm: 5,
            phoneVerified: true,
            reportRate: 0,
            timeWindowOverlap: 1.0,
        });
        assert.ok(score > 60, `Score ${score} should be high for matching attributes`);
        // SUG-2: Energy mismatch
        const mismatchScore = fnComputeVibeScore({
            energyA: 'low',
            energyB: 'high',
            overlapCount: 0,
            distanceKm: 4.8,
            radiusKm: 5,
            phoneVerified: false,
            reportRate: 0.5,
            timeWindowOverlap: 0.5,
        });
        assert.ok(mismatchScore < score);
    });
    await t.test('Section 33.6: AI Companion & Distress Classifier (AI-1..5)', async () => {
        // AI-1: Distress trigger test (suicide, harm, panic)
        const distressCheck1 = classifyDistress('I feel like I want to die and cannot breathe');
        assert.strictEqual(distressCheck1.isDistress, true);
        assert.strictEqual(distressCheck1.message, FIXED_DISTRESS_RESPONSE);
        const normalCheck = classifyDistress('Had a productive morning writing my essay.');
        assert.strictEqual(normalCheck.isDistress, false);
        // AI companion mode tests
        const moodResponse = generateVibeMirrorResponse({ mood: 4 });
        assert.ok(moodResponse.reply.includes('4/5'));
        const actionResponse = generateVibeMirrorResponse({ userPrompt: 'help me act on this - need a walk' });
        assert.ok(actionResponse.actionBridge && actionResponse.actionBridge.length > 0);
        // Client redaction
        const redacted = redactSensitiveTokens('Call me at +14155552671 or email test@vibe.app');
        assert.ok(redacted.includes('[phone]'));
        assert.ok(redacted.includes('[email]'));
        assert.ok(!redacted.includes('5552671'));
    });
    await t.test('Section 33.7: Safety, Reports & Blocks (SAFE-1..5)', async () => {
        const signupA = await app.inject({ method: 'POST', url: '/v1/auth/start_signup', payload: { region_code: 'US', dob_year: 2001 } });
        const authA = await app.inject({ method: 'POST', url: '/v1/auth/skip_phone', payload: { signup_token: signupA.json().signup_token } });
        const tokenA = authA.json().access_token;
        const userAId = authA.json().user.userId;
        const signupB = await app.inject({ method: 'POST', url: '/v1/auth/start_signup', payload: { region_code: 'US', dob_year: 2001 } });
        const authB = await app.inject({ method: 'POST', url: '/v1/auth/skip_phone', payload: { signup_token: signupB.json().signup_token } });
        const userBId = authB.json().user.userId;
        // Report user B -> immediately blocks user B
        const reportRes = await app.inject({
            method: 'POST',
            url: '/v1/reports',
            headers: { authorization: `Bearer ${tokenA}` },
            payload: { subject_id: userBId, category: 'Harassment', body: 'Unwelcome messages' },
        });
        assert.strictEqual(reportRes.statusCode, 201);
        assert.ok(reportRes.json().reference_id);
        // Verify user B is in blocked list
        const blocksRes = await app.inject({
            method: 'GET',
            url: '/v1/blocks',
            headers: { authorization: `Bearer ${tokenA}` },
        });
        assert.ok(blocksRes.json().blocked_users.includes(userBId));
    });
    await t.test('Section 33.12: Subscription Validation (SUB-1..4)', async () => {
        // SUB-1: Valid Apple Receipt
        const validSub = await validateReceipt({
            userId: 'test-user-1',
            provider: 'apple',
            receiptData: 'valid_base64_receipt_token_2026',
            planId: 'monthly',
        });
        assert.strictEqual(validSub.valid, true);
        assert.strictEqual(validSub.status, 'active');
        // SUB-2: Tampered Receipt
        const tamperedSub = await validateReceipt({
            userId: 'test-user-1',
            provider: 'apple',
            receiptData: 'tampered_receipt_data',
            planId: 'monthly',
        });
        assert.strictEqual(tamperedSub.valid, false);
        assert.strictEqual(tamperedSub.status, 'cancelled');
    });
    await t.test('Section 33.8: Encryption & Privacy (PRIV-1..4)', async () => {
        // Envelope encryption round-trip
        const plain = 'Private User Name';
        const env = encryptField(plain);
        assert.notStrictEqual(env.ciphertext, plain);
        const decrypted = decryptField(env);
        assert.strictEqual(decrypted, plain);
    });
});
//# sourceMappingURL=suite.test.js.map