const DISTRESS_TRIGGERS = /(kill myself|end it|suicide|want to die|hurt (myself|them|her|him)|won't let me leave|afraid to go home|can't breathe|panic|having a breakdown|losing it|overdose|too many pills|shoot|stab)/i;
const CRISIS_RESOURCES = {
    US: '988 Suicide & Crisis Lifeline — call or text 988',
    UK: 'Samaritans — 116 123',
    CA: 'Talk Suicide Canada — 1-833-456-4566',
    IN: 'iCall — 9152987821',
    BR: 'CVV — 188',
    EU: '112 Emergency Services',
    DEFAULT: 'https://findahelpline.com (Free, confidential support worldwide)',
};
export const FIXED_DISTRESS_RESPONSE = `We hear you. Vibe's AI is not the right place for this.
You deserve to talk to someone who can help right now.

- United States: 988 Suicide & Crisis Lifeline — call or text 988
- United Kingdom: Samaritans — 116 123
- Canada: Talk Suicide Canada — 1-833-456-4566
- India: iCall — 9152987821
- Brazil: CVV — 188
- International: https://findahelpline.com

Talk to a friend? → [Open Trusted Contact]
If you feel unsafe right now, please leave this screen and call local emergency services.`;
export function classifyDistress(text) {
    if (!text || typeof text !== 'string') {
        return { isDistress: false };
    }
    // Pure in-memory scan — NEVER log or persist the input text (Chapter 9.7)
    const isMatch = DISTRESS_TRIGGERS.test(text);
    if (isMatch) {
        return {
            isDistress: true,
            message: FIXED_DISTRESS_RESPONSE,
            crisisResources: CRISIS_RESOURCES,
        };
    }
    return { isDistress: false };
}
//# sourceMappingURL=distress_classifier.js.map