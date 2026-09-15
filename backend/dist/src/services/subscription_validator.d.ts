import { SubPlan, SubProvider, SubStatus } from '../domain/types.js';
export interface ReceiptValidationRequest {
    userId: string;
    provider: SubProvider;
    receiptData: string;
    planId: SubPlan;
}
export interface ReceiptValidationResult {
    valid: boolean;
    status: SubStatus;
    planId: SubPlan;
    renewAt: string;
    providerSubscriptionId: string;
}
export declare function validateReceipt(req: ReceiptValidationRequest): Promise<ReceiptValidationResult>;
