import crypto from 'crypto';
const MASTER_ENVELOPE_KEY = crypto.scryptSync(process.env.ENVELOPE_SECRET || 'vibe_envelope_master_key_indigo', 'salt_vibe', 32);
export function encryptField(plaintext) {
    const nonce = crypto.randomBytes(12);
    const cipher = crypto.createCipheriv('aes-256-gcm', MASTER_ENVELOPE_KEY, nonce);
    let ciphertext = cipher.update(plaintext, 'utf8', 'hex');
    ciphertext += cipher.final('hex');
    const tag = cipher.getAuthTag().toString('hex');
    return {
        ciphertext,
        nonce: nonce.toString('hex'),
        tag,
    };
}
export function decryptField(envelope) {
    const decipher = crypto.createDecipheriv('aes-256-gcm', MASTER_ENVELOPE_KEY, Buffer.from(envelope.nonce, 'hex'));
    decipher.setAuthTag(Buffer.from(envelope.tag, 'hex'));
    let decrypted = decipher.update(envelope.ciphertext, 'hex', 'utf8');
    decrypted += decipher.final('utf8');
    return decrypted;
}
export function hashPhone(phoneE164, regionCode) {
    const salt = `salt_region_${regionCode.toLowerCase()}`;
    return crypto.createHmac('sha256', salt).update(phoneE164).digest('hex');
}
export function hashDevice(deviceId) {
    return crypto.createHash('sha256').update(deviceId).digest('hex');
}
//# sourceMappingURL=envelope.js.map