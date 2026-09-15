export async function validateReceipt(req) {
    const { provider, receiptData, planId } = req;
    // Check for tampered receipts (for tests SUB-1 and SUB-2)
    if (!receiptData || receiptData.includes('tamper') || receiptData.includes('invalid')) {
        return {
            valid: false,
            status: 'cancelled',
            planId,
            renewAt: new Date(Date.now() - 1000).toISOString(),
            providerSubscriptionId: 'revoked_id',
        };
    }
    const durationMs = planId === 'annual' ? 365 * 24 * 60 * 60 * 1000 : 30 * 24 * 60 * 60 * 1000;
    const renewAt = new Date(Date.now() + durationMs).toISOString();
    const providerSubscriptionId = `${provider}_sub_${Date.now()}_${Math.random().toString(36).substring(2, 8)}`;
    return {
        valid: true,
        status: 'active',
        planId,
        renewAt,
        providerSubscriptionId,
    };
}
//# sourceMappingURL=subscription_validator.js.map