class VibeCandidate {
  final String id;
  final String name;
  final int age;
  final int affinity; // 0 - 100
  final String rationale;
  final String energy;
  final double distanceKm;
  final List<String> activities;
  final bool phoneVerified;
  final int completedMeetups;

  const VibeCandidate({
    required this.id,
    required this.name,
    required this.age,
    required this.affinity,
    required this.rationale,
    required this.energy,
    required this.distanceKm,
    required this.activities,
    this.phoneVerified = true,
    this.completedMeetups = 0,
  });
}

const List<VibeCandidate> defaultCandidates = [
  VibeCandidate(
    id: 'cand-1',
    name: 'Maya R.',
    age: 19,
    affinity: 92,
    rationale: 'Organic chem study + iced coffee, 1.2 km away',
    energy: 'medium',
    distanceKm: 1.2,
    activities: ['study', 'coffee'],
    completedMeetups: 4,
  ),
  VibeCandidate(
    id: 'cand-2',
    name: 'Dev P.',
    age: 24,
    affinity: 88,
    rationale: 'Design critique & cafe hang, 2.5 km away',
    energy: 'medium',
    distanceKm: 2.5,
    activities: ['chill', 'creative'],
    completedMeetups: 7,
  ),
  VibeCandidate(
    id: 'cand-3',
    name: 'Sora T.',
    age: 18,
    affinity: 85,
    rationale: 'Indie game discussion & tea, 3.1 km away',
    energy: 'low',
    distanceKm: 3.1,
    activities: ['gaming', 'chill'],
    completedMeetups: 2,
  ),
  VibeCandidate(
    id: 'cand-4',
    name: 'Jordan K.',
    age: 22,
    affinity: 81,
    rationale: 'Sunset walk around Washington Square, 4.0 km away',
    energy: 'medium',
    distanceKm: 4.0,
    activities: ['walk', 'explore'],
    completedMeetups: 5,
  ),
  VibeCandidate(
    id: 'cand-5',
    name: 'Liam W.',
    age: 21,
    affinity: 78,
    rationale: 'Pickleball / outdoor movement, 4.8 km away',
    energy: 'high',
    distanceKm: 4.8,
    activities: ['fitness', 'outdoor'],
    completedMeetups: 3,
  ),
];
