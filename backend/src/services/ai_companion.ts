import { classifyDistress } from './distress_classifier.js';

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

export function redactSensitiveTokens(input: string): string {
  if (!input) return '';
  return input
    .replace(/\b\+?[0-9]{7,15}\b/g, '[phone]')
    .replace(/[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}/g, '[email]')
    .replace(/\b[0-9a-fA-F]{24,64}\b/g, '[code]');
}

export function generateVibeMirrorResponse(req: JournalRequest): JournalResponse {
  const rawText = (req.text || req.userPrompt || '').trim();

  // 1. Pre-LLM Distress Classification Check
  const distressCheck = classifyDistress(rawText);
  if (distressCheck.isDistress) {
    return {
      reply: distressCheck.message!,
      isDistress: true,
      crisisMessage: distressCheck.message,
    };
  }

  const mode = req.mode || (req.mood ? 'mood_checkin' : req.userPrompt?.includes('act') ? 'action_bridge' : 'free_journaling');

  // Redacted session text (ephemeral processing only)
  const sanitized = redactSensitiveTokens(rawText);

  if (mode === 'mood_checkin' && typeof req.mood === 'number') {
    const clampedMood = Math.max(1, Math.min(5, req.mood));
    return {
      reply: `Logged at ${clampedMood}/5. Anything you'd like to note? You can leave it blank.`,
      isDistress: false,
    };
  }

  if (mode === 'action_bridge') {
    if (sanitized.toLowerCase().includes('walk') || sanitized.toLowerCase().includes('outside')) {
      return {
        reply: 'Sounds like a calm walk would help. Want to set one as an intent, or text a friend?',
        isDistress: false,
        actionBridge: ['Set a 30-min walk intent', 'Text a trusted contact'],
      };
    }
    if (sanitized.toLowerCase().includes('coffee') || sanitized.toLowerCase().includes('talk')) {
      return {
        reply: 'A quiet coffee catchup could be grounding. Would you like to set a coffee intent for today?',
        isDistress: false,
        actionBridge: ['Set a coffee hang intent', 'Save note to journal'],
      };
    }
    return {
      reply: 'Taking a small step often clears the mind. You could set a light study or walk intent for later.',
      isDistress: false,
      actionBridge: ['Set a low-energy intent', 'Write another reflection'],
    };
  }

  // Free journaling mode
  if (sanitized.length === 0) {
    return {
      reply: 'Welcome to your private reflection space. Write when you are ready.',
      isDistress: false,
    };
  }

  return {
    reply: 'Thank you for writing that. Would you like a short reflection prompt, or just leave it here?',
    isDistress: false,
  };
}
