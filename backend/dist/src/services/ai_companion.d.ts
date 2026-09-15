export type JournalMode = 'free_journaling' | 'mood_checkin' | 'action_bridge';
export interface JournalRequest {
    text?: string;
    mood?: number;
    mode?: JournalMode;
    userPrompt?: string;
}
export interface JournalResponse {
    reply: string;
    isDistress: boolean;
    actionBridge?: string[];
    crisisMessage?: string;
}
export declare function redactSensitiveTokens(input: string): string;
export declare function generateVibeMirrorResponse(req: JournalRequest): JournalResponse;
