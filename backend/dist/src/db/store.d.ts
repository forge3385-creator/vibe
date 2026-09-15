import { User, UserPrivacyDefaults, Intent, Suggestion, Match, Meetup, ChatMessage, JournalEntry, Report, Subscription } from '../domain/types.js';
export interface OutboxItem {
    id: string;
    kind: string;
    payload: any;
    createdAt: string;
    processedAt?: string | null;
}
export declare class DataStore {
    users: Map<string, User>;
    userPrivacy: Map<string, UserPrivacyDefaults>;
    userInterests: Map<string, string[]>;
    intents: Map<string, Intent>;
    matches: Map<string, Match>;
    meetups: Map<string, Meetup>;
    chats: Map<string, ChatMessage[]>;
    journals: Map<string, JournalEntry[]>;
    reports: Map<string, Report>;
    blocks: Map<string, Set<string>>;
    trustedContacts: Map<string, Array<{
        id: string;
        kind: 'phone' | 'invite';
        value: string;
        name?: string;
    }>>;
    friends: Map<string, Set<string>>;
    friendRequests: Map<string, {
        id: string;
        from: string;
        to: string;
        createdAt: string;
    }>;
    subscriptions: Map<string, Subscription>;
    outbox: OutboxItem[];
    hiddenSuggestions: Map<string, Set<string>>;
    under16AttemptsCount: number;
    constructor();
    private initDefaultAdminAndSeedData;
    findSuggestionsForIntent(intentId: string): Suggestion[];
}
export declare const globalStore: DataStore;
