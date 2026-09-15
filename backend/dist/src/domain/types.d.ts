import { EncryptedEnvelope } from '../crypto/envelope.js';
export type UserStatus = 'active' | 'suspended' | 'deleted';
export type EnergyLevel = 'low' | 'medium' | 'high';
export type ActivityType = 'chill' | 'active' | 'creative' | 'food' | 'study' | 'outdoor' | 'other';
export type TimeWindow = 'today' | 'this_week';
export type GroupPref = 'one_on_one' | 'small_group_3_6';
export type IntentStatus = 'uncommitted' | 'active' | 'expired' | 'cancelled';
export type MatchState = 'created' | 'chat_open' | 'meet_created' | 'completed' | 'cancelled' | 'unmatched';
export type MeetupState = 'draft' | 'proposed' | 'accepted_partial' | 'confirmed' | 'in_progress' | 'completed' | 'cancelled' | 'no_show';
export type MessageKind = 'text' | 'image' | 'place_card' | 'time_card';
export type ReportStatus = 'received' | 'reviewing' | 'closed_action' | 'closed_no_action' | 'escalated';
export type SubPlan = 'monthly' | 'annual';
export type SubProvider = 'apple' | 'google';
export type SubStatus = 'active' | 'past_due' | 'cancelled' | 'expired' | 'refunded';
export interface User {
    userId: string;
    createdAt: string;
    updatedAt: string;
    displayNameEncrypted: EncryptedEnvelope;
    displayName: string;
    dobYear: number;
    regionCode: string;
    locale: string;
    phoneHash?: string;
    phoneVerified: boolean;
    photoVerified: boolean;
    preferences: {
        units?: 'km' | 'miles';
        language?: string;
        theme?: 'light' | 'dark';
    };
    lastActiveAt: string;
    status: UserStatus;
    deletedAt?: string | null;
    reportRate: number;
    completedMeetups: number;
    primaryPhotoUrl?: string | null;
}
export interface UserPrivacyDefaults {
    userId: string;
    discoverableToFriends: boolean;
    sharePhotoByDefault: boolean;
    journalEncrypted: boolean;
    trustedContactIds: string[];
}
export interface Intent {
    intentId: string;
    userId: string;
    energyLevel: EnergyLevel;
    activityType: ActivityType[];
    activitySubtype: string[];
    groupSizePref: GroupPref;
    timeWindow: TimeWindow;
    note?: string;
    lat: number;
    lng: number;
    radiusKm: number;
    createdAt: string;
    expiresAt: string;
    status: IntentStatus;
}
export interface Suggestion {
    suggestionId: string;
    matchUser: {
        userId: string;
        displayName: string;
        age: number;
        primaryPhotoUrl?: string | null;
        vibeAffinity: number;
        sharedSubtypes: string[];
        mutualIntersect: number;
        trustSignals: {
            phoneVerified: boolean;
            mutualFriendCount: number;
            reportRate: number;
            completedMeetups: number;
        };
    };
    rank: number;
    rationale: string;
    distanceKm: number;
}
export interface Match {
    matchId: string;
    userAId: string;
    userBId: string;
    originIntentA: string;
    originIntentB: string;
    createdAt: string;
    state: MatchState;
    unmatchReason?: string | null;
}
export interface Meetup {
    meetupId: string;
    hostId: string;
    participantIds: string[];
    activitySubtype: string;
    placeId?: string;
    placeName?: string;
    placeAddress?: string;
    startAt: string;
    endAt?: string | null;
    state: MeetupState;
    costShareTotalCents?: number | null;
    currency?: string | null;
    createdViaMatchIds: string[];
    trustedShareEndsAt?: string | null;
    createdAt: string;
}
export interface ChatMessage {
    messageId: string;
    meetupId: string;
    senderId: string;
    postedAt: string;
    body: string;
    kind: MessageKind;
    payload?: any;
    expiresAt: string;
}
export interface JournalEntry {
    entryId: string;
    userId: string;
    ciphertext: string;
    nonce: string;
    createdAt: string;
    mood?: number | null;
    sizeBytes: number;
    deletedAt?: string | null;
}
export interface Report {
    reportId: string;
    reporterId: string;
    subjectId: string;
    category: string;
    body: string;
    attachmentsRef?: string[];
    createdAt: string;
    status: ReportStatus;
    moderatorId?: string | null;
    resolutionNote?: string | null;
}
export interface Subscription {
    subscriptionId: string;
    userId: string;
    planId: SubPlan;
    provider: SubProvider;
    providerSubscriptionId: string;
    status: SubStatus;
    startedAt: string;
    renewAt: string;
    cancelledAt?: string | null;
}
