import {
  User,
  UserPrivacyDefaults,
  Intent,
  Suggestion,
  Match,
  Meetup,
  ChatMessage,
  JournalEntry,
  Report,
  Subscription,
} from '../domain/types.js';
import { encryptField } from '../crypto/envelope.js';
import { fnComputeVibeScore, calculateHaversineDistance, jaccardOverlap } from '../services/vibe_score.js';

export interface OutboxItem {
  id: string;
  kind: string;
  payload: any;
  createdAt: string;
  processedAt?: string | null;
}

export class DataStore {
  public users: Map<string, User> = new Map();
  public userPrivacy: Map<string, UserPrivacyDefaults> = new Map();
  public userInterests: Map<string, string[]> = new Map();
  public intents: Map<string, Intent> = new Map();
  public matches: Map<string, Match> = new Map();
  public meetups: Map<string, Meetup> = new Map();
  public chats: Map<string, ChatMessage[]> = new Map(); // meetupId -> messages
  public journals: Map<string, JournalEntry[]> = new Map(); // userId -> entries
  public reports: Map<string, Report> = new Map();
  public blocks: Map<string, Set<string>> = new Map(); // blockerId -> Set<blockedId>
  public trustedContacts: Map<string, Array<{ id: string; kind: 'phone' | 'invite'; value: string; name?: string }>> = new Map();
  public friends: Map<string, Set<string>> = new Map(); // userId -> Set<friendUserId>
  public friendRequests: Map<string, { id: string; from: string; to: string; createdAt: string }> = new Map();
  public subscriptions: Map<string, Subscription> = new Map();
  public outbox: OutboxItem[] = [];
  public hiddenSuggestions: Map<string, Set<string>> = new Map(); // userId -> Set<suggestionId>
  public under16AttemptsCount: number = 0;

  constructor() {
    this.initDefaultAdminAndSeedData();
  }

  private initDefaultAdminAndSeedData() {
    // Initial dummy system seed for instant local test capability
    const defaultUser: User = {
      userId: '00000000-0000-7000-8000-000000000001',
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
      displayNameEncrypted: encryptField('Alex Rivera'),
      displayName: 'Alex',
      dobYear: 2004,
      regionCode: 'US',
      locale: 'en_US',
      phoneVerified: true,
      photoVerified: false,
      preferences: { units: 'km', theme: 'light' },
      lastActiveAt: new Date().toISOString(),
      status: 'active',
      reportRate: 0,
      completedMeetups: 4,
      primaryPhotoUrl: null,
    };
    this.users.set(defaultUser.userId, defaultUser);
    this.userPrivacy.set(defaultUser.userId, {
      userId: defaultUser.userId,
      discoverableToFriends: true,
      sharePhotoByDefault: false,
      journalEncrypted: true,
      trustedContactIds: [],
    });
    this.userInterests.set(defaultUser.userId, ['Coffee', 'Walks', 'Tech', 'Music']);
  }

  // Suggestion Pool Query
  public findSuggestionsForIntent(intentId: string): Suggestion[] {
    const activeIntent = this.intents.get(intentId);
    if (!activeIntent || activeIntent.status !== 'active') return [];

    const requester = this.users.get(activeIntent.userId);
    const userBlocks = this.blocks.get(activeIntent.userId) || new Set();
    const userHiddens = this.hiddenSuggestions.get(activeIntent.userId) || new Set();
    const requesterInterests = this.userInterests.get(activeIntent.userId) || [];

    const candidates: Suggestion[] = [];

    for (const [candidateIntentId, otherIntent] of this.intents.entries()) {
      if (candidateIntentId === intentId) continue;
      if (otherIntent.userId === activeIntent.userId) continue;
      if (otherIntent.status !== 'active') continue;
      if (userBlocks.has(otherIntent.userId)) continue;
      if (userHiddens.has(candidateIntentId)) continue;

      // Reverse block check
      const otherBlocks = this.blocks.get(otherIntent.userId) || new Set();
      if (otherBlocks.has(activeIntent.userId)) continue;

      // Check Activity overlap
      const sharedActivities = activeIntent.activityType.filter((a) =>
        otherIntent.activityType.includes(a)
      );
      if (sharedActivities.length === 0) continue;

      // Distance calculation
      const distKm = calculateHaversineDistance(
        activeIntent.lat,
        activeIntent.lng,
        otherIntent.lat,
        otherIntent.lng
      );
      const maxRadius = Math.max(activeIntent.radiusKm || 5, otherIntent.radiusKm || 5);
      if (distKm > maxRadius) continue;

      const otherUser = this.users.get(otherIntent.userId);
      if (!otherUser || otherUser.status !== 'active') continue;

      const otherInterests = this.userInterests.get(otherIntent.userId) || [];
      const sharedSubtypes = activeIntent.activitySubtype.filter((s) =>
        otherIntent.activitySubtype.includes(s)
      );
      const interestOverlap = jaccardOverlap(requesterInterests, otherInterests);

      const vibeScore = fnComputeVibeScore({
        energyA: activeIntent.energyLevel,
        energyB: otherIntent.energyLevel,
        overlapCount: sharedSubtypes.length + interestOverlap,
        distanceKm: distKm,
        radiusKm: maxRadius,
        phoneVerified: otherUser.phoneVerified,
        reportRate: otherUser.reportRate,
        timeWindowOverlap: activeIntent.timeWindow === otherIntent.timeWindow ? 1.0 : 0.5,
      });

      const age = new Date().getFullYear() - otherUser.dobYear;
      const rationaleItems = [
        ...sharedActivities.map((a) => a.charAt(0).toUpperCase() + a.slice(1)),
        ...sharedSubtypes.map((s) => s.replace(/_/g, ' ')),
      ];

      const rationaleText = `${rationaleItems.slice(0, 2).join(' + ')}, ${distKm} km away`;

      candidates.push({
        suggestionId: candidateIntentId,
        matchUser: {
          userId: otherUser.userId,
          displayName: otherUser.displayName,
          age,
          primaryPhotoUrl: otherUser.primaryPhotoUrl || null,
          vibeAffinity: vibeScore,
          sharedSubtypes: sharedSubtypes.length > 0 ? sharedSubtypes : [sharedActivities[0]],
          mutualIntersect: sharedSubtypes.length + interestOverlap,
          trustSignals: {
            phoneVerified: otherUser.phoneVerified,
            mutualFriendCount: (this.friends.get(activeIntent.userId) || new Set()).has(otherUser.userId) ? 1 : 0,
            reportRate: otherUser.reportRate,
            completedMeetups: otherUser.completedMeetups,
          },
        },
        rank: 0,
        rationale: rationaleText,
        distanceKm: distKm,
      });
    }

    // Rank by vibeAffinity DESC and cap at 12
    candidates.sort((a, b) => b.matchUser.vibeAffinity - a.matchUser.vibeAffinity);
    const top12 = candidates.slice(0, 12).map((c, index) => ({
      ...c,
      rank: index + 1,
    }));

    return top12;
  }
}

export const globalStore = new DataStore();
