import { globalStore } from '../src/db/store.js';
import { encryptField } from '../src/crypto/envelope.js';
import { User, Intent, Meetup } from '../src/domain/types.js';

const CITIES = [
  { name: 'NYC', region: 'US', lat: 40.7128, lng: -74.006, locale: 'en_US' },
  { name: 'London', region: 'UK', lat: 51.5074, lng: -0.1278, locale: 'en_GB' },
  { name: 'São Paulo', region: 'BR', lat: -23.5505, lng: -46.6333, locale: 'pt_BR' },
  { name: 'Berlin', region: 'EU', lat: 52.52, lng: 13.405, locale: 'de' },
  { name: 'Mumbai', region: 'IN', lat: 19.076, lng: 72.8777, locale: 'hi' },
];

const FIRST_NAMES = [
  'Maya', 'Dev', 'Sora', 'Jordan', 'Liam', 'Emma', 'Noah', 'Olivia', 'Aarav', 'Ananya',
  'Lucas', 'Sophia', 'Kai', 'Elena', 'Mateo', 'Isabella', 'Rohan', 'Zara', 'Felix', 'Chloe'
];

const ACTIVITIES = ['chill', 'active', 'creative', 'food', 'study', 'outdoor'] as const;
const SUBTYPES: Record<string, string[]> = {
  chill: ['cafe_hang', 'movie_night', 'rooftop_sunset'],
  active: ['run', 'walk', 'yoga', 'cycle'],
  creative: ['jam', 'sketch_walk', 'co_writing'],
  food: ['coffee', 'meal', 'brunch', 'street_food'],
  study: ['exam_prep', 'language_x', 'cowork_focus'],
  outdoor: ['park', 'beach', 'trail'],
};

export function runSeed(count = 10000) {
  console.log(`[Seed] Generating ${count} synthetic users across 5 metropolitan regions...`);
  const now = Date.now();

  for (let i = 0; i < count; i++) {
    const city = CITIES[i % CITIES.length];
    const name = `${FIRST_NAMES[i % FIRST_NAMES.length]} ${String.fromCharCode(65 + (i % 26))}.`;
    const userId = `synth-${city.region.toLowerCase()}-${i.toString().padStart(5, '0')}`;
    const dobYear = 1998 + (i % 8); // 18-26 years old

    // Jitter coordinates within 5-10 km
    const latJitter = (Math.random() - 0.5) * 0.08;
    const lngJitter = (Math.random() - 0.5) * 0.08;

    const user: User = {
      userId,
      createdAt: new Date(now - i * 60000).toISOString(),
      updatedAt: new Date().toISOString(),
      displayNameEncrypted: encryptField(name),
      displayName: name,
      dobYear,
      regionCode: city.region,
      locale: city.locale,
      phoneVerified: i % 3 === 0,
      photoVerified: i % 5 === 0,
      preferences: { units: city.region === 'US' ? 'miles' : 'km', theme: 'light' },
      lastActiveAt: new Date(now - (i % 1440) * 60000).toISOString(),
      status: 'active',
      reportRate: (i % 100 === 0) ? 0.02 : 0,
      completedMeetups: i % 10,
      primaryPhotoUrl: null,
    };

    globalStore.users.set(userId, user);
    globalStore.userInterests.set(userId, ['Coffee', 'Walks', 'Tech', 'Music', 'Books'].slice(0, 3 + (i % 3)));

    // 10% active intents
    if (i % 10 === 0) {
      const actType = ACTIVITIES[i % ACTIVITIES.length];
      const actSubtypes = SUBTYPES[actType] || [];
      const intentId = `intent-synth-${i}`;

      const intent: Intent = {
        intentId,
        userId,
        energyLevel: (i % 3 === 0 ? 'low' : i % 3 === 1 ? 'medium' : 'high'),
        activityType: [actType],
        activitySubtype: actSubtypes.slice(0, 2),
        groupSizePref: i % 2 === 0 ? 'one_on_one' : 'small_group_3_6',
        timeWindow: i % 4 === 0 ? 'today' : 'this_week',
        note: 'Looking for a relaxing session nearby',
        lat: city.lat + latJitter,
        lng: city.lng + lngJitter,
        radiusKm: 5 + (i % 15),
        createdAt: new Date(now - 3600000).toISOString(),
        expiresAt: new Date(now + 23 * 3600000).toISOString(),
        status: 'active',
      };
      globalStore.intents.set(intentId, intent);
    }

    // 0.5% with confirmed meetups (50 meetups in 10k)
    if (i % 200 === 0) {
      const meetupId = `meetup-synth-${i}`;
      const partnerId = `synth-${city.region.toLowerCase()}-${((i + 1) % count).toString().padStart(5, '0')}`;

      const meetup: Meetup = {
        meetupId,
        hostId: userId,
        participantIds: [userId, partnerId],
        activitySubtype: 'cafe_hang',
        placeName: `${city.name} Central Cafe`,
        placeAddress: `123 Main St, ${city.name}`,
        startAt: new Date(now + 3600000).toISOString(),
        state: 'confirmed',
        createdViaMatchIds: [],
        createdAt: new Date().toISOString(),
      };
      globalStore.meetups.set(meetupId, meetup);
    }
  }

  console.log(`[Seed] Successfully seeded ${globalStore.users.size} users, ${globalStore.intents.size} active intents, and ${globalStore.meetups.size} meetups.`);
}

if (process.argv[1]?.endsWith('seed.ts') || process.argv[1]?.endsWith('seed.js')) {
  runSeed(10000);
}
