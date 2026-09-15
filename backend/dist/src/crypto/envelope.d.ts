export interface EncryptedEnvelope {
    ciphertext: string;
    nonce: string;
    tag: string;
}
export declare function encryptField(plaintext: string): EncryptedEnvelope;
export declare function decryptField(envelope: EncryptedEnvelope): string;
export declare function hashPhone(phoneE164: string, regionCode: string): string;
export declare function hashDevice(deviceId: string): string;
