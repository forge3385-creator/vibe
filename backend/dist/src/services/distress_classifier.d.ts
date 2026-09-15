export interface DistressResult {
    isDistress: boolean;
    message?: string;
    crisisResources?: Record<string, string>;
}
export declare const FIXED_DISTRESS_RESPONSE = "We hear you. Vibe's AI is not the right place for this.\nYou deserve to talk to someone who can help right now.\n\n- United States: 988 Suicide & Crisis Lifeline \u2014 call or text 988\n- United Kingdom: Samaritans \u2014 116 123\n- Canada: Talk Suicide Canada \u2014 1-833-456-4566\n- India: iCall \u2014 9152987821\n- Brazil: CVV \u2014 188\n- International: https://findahelpline.com\n\nTalk to a friend? \u2192 [Open Trusted Contact]\nIf you feel unsafe right now, please leave this screen and call local emergency services.";
export declare function classifyDistress(text: string): DistressResult;
