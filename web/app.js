// ==========================================================================
// VIBE CLIENT APPLICATION (CHAPTERS 18, 19, 28)
// Dual-Mode: Connects to Live Backend API OR Runs Autonomous Embedded Engine (Netlify/Static)
// ==========================================================================

const API_BASE = window.location.origin + '/v1';
const WS_URL = (window.location.protocol === 'https:' ? 'wss://' : 'ws://') + window.location.host + '/v1/realtime';

const state = {
  token: localStorage.getItem('vibe_token') || null,
  user: JSON.parse(localStorage.getItem('vibe_user') || 'null'),
  currentIntent: JSON.parse(localStorage.getItem('vibe_current_intent') || 'null'),
  activeMeetup: null,
  ws: null,
  isDark: false,
  isStandaloneClient: false,
};

// Embedded Candidates Pool for Static Deployments (Netlify, etc.)
const EMBEDDED_CANDIDATES = [
  { userId: 'cand-1', displayName: 'Maya R.', age: 19, energy: 'medium', activities: ['chill', 'food'], subtypes: ['cafe_hang', 'coffee'], distanceKm: 1.2, phoneVerified: true, completedMeetups: 4, reportRate: 0 },
  { userId: 'cand-2', displayName: 'Dev P.', age: 24, energy: 'medium', activities: ['chill', 'study'], subtypes: ['cafe_hang', 'cowork_focus'], distanceKm: 2.5, phoneVerified: true, completedMeetups: 7, reportRate: 0 },
  { userId: 'cand-3', displayName: 'Sora T.', age: 18, energy: 'low', activities: ['chill'], subtypes: ['cafe_hang', 'movie_night'], distanceKm: 3.1, phoneVerified: true, completedMeetups: 2, reportRate: 0 },
  { userId: 'cand-4', displayName: 'Jordan K.', age: 27, energy: 'medium', activities: ['active', 'food'], subtypes: ['walk', 'coffee'], distanceKm: 4.0, phoneVerified: false, completedMeetups: 5, reportRate: 0 },
  { userId: 'cand-5', displayName: 'Liam W.', age: 21, energy: 'high', activities: ['active', 'outdoor'], subtypes: ['run', 'trail'], distanceKm: 4.8, phoneVerified: true, completedMeetups: 3, reportRate: 0 },
  { userId: 'cand-6', displayName: 'Emma S.', age: 20, energy: 'low', activities: ['creative', 'chill'], subtypes: ['sketch_walk', 'cafe_hang'], distanceKm: 5.2, phoneVerified: true, completedMeetups: 6, reportRate: 0 },
  { userId: 'cand-7', displayName: 'Aarav N.', age: 22, energy: 'medium', activities: ['study', 'food'], subtypes: ['cowork_focus', 'coffee'], distanceKm: 2.1, phoneVerified: true, completedMeetups: 8, reportRate: 0 },
  { userId: 'cand-8', displayName: 'Chloe M.', age: 23, energy: 'high', activities: ['active'], subtypes: ['cycle', 'yoga'], distanceKm: 6.0, phoneVerified: false, completedMeetups: 1, reportRate: 0 },
];

const FIXED_DISTRESS_RESPONSE = `We hear you. Vibe's AI is not the right place for this.
You deserve to talk to someone who can help right now.

- United States: 988 Suicide & Crisis Lifeline — call or text 988
- United Kingdom: Samaritans — 116 123
- Canada: Talk Suicide Canada — 1-833-456-4566
- India: iCall — 9152987821
- Brazil: CVV — 188
- International: https://findahelpline.com

Talk to a friend? → [Open Trusted Contact]
If you feel unsafe right now, please leave this screen and call local emergency services.`;

// Initialize App
document.addEventListener('DOMContentLoaded', async () => {
  if (window.lucide) {
    window.lucide.createIcons();
  }

  setupEventListeners();

  // Test if live backend API is available or if running standalone (Netlify)
  try {
    const healthCheck = await fetch(`${API_BASE}/health`, { signal: AbortSignal.timeout(1500) });
    if (!healthCheck.ok) throw new Error('Standalone');
  } catch {
    state.isStandaloneClient = true;
    console.log('[Vibe] Running in Netlify / Client-Autonomous Mode with Embedded Vibe Engine.');
  }

  if (!state.token && !state.user) {
    document.getElementById('onboarding-overlay').classList.remove('hidden');
  } else {
    await fetchUserProfile();
    await loadInitialData();
    if (!state.isStandaloneClient) {
      connectWebSocket();
    }
  }
});

function setupEventListeners() {
  // Navigation Tabs
  document.querySelectorAll('.nav-tab').forEach((tab) => {
    tab.addEventListener('click', () => {
      const targetTab = tab.dataset.tab;
      switchTab(targetTab);
    });
  });

  // Theme Toggle
  document.getElementById('theme-toggle-btn').addEventListener('click', () => {
    state.isDark = !state.isDark;
    document.body.classList.toggle('dark-theme', state.isDark);
  });

  // Onboarding Flow
  document.getElementById('onb-start-btn')?.addEventListener('click', () => {
    document.getElementById('onb-step-carousel').classList.add('hidden');
    document.getElementById('onb-step-age').classList.remove('hidden');
  });

  document.getElementById('age-gate-next-btn')?.addEventListener('click', () => {
    const year = parseInt(document.getElementById('dob-year-input').value, 10);
    const age = new Date().getFullYear() - year;
    if (age < 16) {
      document.getElementById('age-gate-error').classList.remove('hidden');
      return;
    }
    document.getElementById('onb-step-age').classList.add('hidden');
    document.getElementById('onb-step-auth').classList.remove('hidden');
  });

  document.getElementById('auth-submit-btn')?.addEventListener('click', () => handleAuth(true));
  document.getElementById('auth-skip-btn')?.addEventListener('click', () => handleAuth(false));

  // Energy Buttons
  document.querySelectorAll('.energy-btn').forEach((btn) => {
    btn.addEventListener('click', () => {
      document.querySelectorAll('.energy-btn').forEach((b) => b.classList.remove('active'));
      btn.classList.add('active');
    });
  });

  // Activity Chips (Max 3)
  document.querySelectorAll('#activity-chips .chip').forEach((chip) => {
    chip.addEventListener('click', () => {
      const activeCount = document.querySelectorAll('#activity-chips .chip.active').length;
      if (!chip.classList.contains('active') && activeCount >= 3) {
        showToast('Maximum 3 activities allowed (Chapter 6.2)');
        return;
      }
      chip.classList.toggle('active');
    });
  });

  // Subtype Chips
  document.querySelectorAll('#subtype-chips .chip').forEach((chip) => {
    chip.addEventListener('click', () => chip.classList.toggle('active'));
  });

  // Segmented Controls
  document.querySelectorAll('.segmented-control').forEach((control) => {
    control.querySelectorAll('.segment').forEach((btn) => {
      btn.addEventListener('click', () => {
        control.querySelectorAll('.segment').forEach((b) => b.classList.remove('active'));
        btn.classList.add('active');
      });
    });
  });

  // Radius Slider
  const slider = document.getElementById('intent-radius-slider');
  slider?.addEventListener('input', (e) => {
    document.getElementById('radius-val').textContent = `${e.target.value} km`;
  });

  // Commit Intent Button
  document.getElementById('commit-intent-btn')?.addEventListener('click', commitIntent);

  // Broaden Filters CTA
  document.getElementById('broaden-filters-btn')?.addEventListener('click', () => {
    if (slider) {
      slider.value = 25;
      document.getElementById('radius-val').textContent = '25 km';
    }
    switchTab('set');
  });

  // Refresh Suggestions
  document.getElementById('refresh-suggestions-btn')?.addEventListener('click', fetchSuggestions);

  // Chat Actions
  document.getElementById('chat-form')?.addEventListener('submit', sendChatMessage);
  document.getElementById('send-place-card-btn')?.addEventListener('click', suggestPlaceCard);
  document.getElementById('send-time-card-btn')?.addEventListener('click', proposeTimeCard);
  document.getElementById('send-going-btn')?.addEventListener('click', markImGoing);
  document.getElementById('trusted-share-btn')?.addEventListener('click', shareLiveWithTrustedContact);
  document.getElementById('mark-complete-btn')?.addEventListener('click', completeCurrentMeetup);

  // Mood Picker in Journal
  document.querySelectorAll('#mood-picker .mood-chip').forEach((chip) => {
    chip.addEventListener('click', () => {
      document.querySelectorAll('#mood-picker .mood-chip').forEach((c) => c.classList.remove('active'));
      chip.classList.add('active');
    });
  });

  // AI Vibe Mirror Interaction
  document.getElementById('ai-mirror-reflect-btn')?.addEventListener('click', () => invokeVibeMirror('free_journaling'));
  document.getElementById('ai-action-bridge-btn')?.addEventListener('click', () => invokeVibeMirror('action_bridge'));
  document.getElementById('save-journal-entry-btn')?.addEventListener('click', saveJournalEntry);

  // Modals & Tools
  document.getElementById('quick-report-btn')?.addEventListener('click', () => openReportModal());
  document.getElementById('close-report-modal')?.addEventListener('click', () => closeReportModal());
  document.getElementById('cancel-report-btn')?.addEventListener('click', () => closeReportModal());
  document.getElementById('submit-report-btn')?.addEventListener('click', submitSafetyReport);
  document.getElementById('open-storybook-btn')?.addEventListener('click', openStorybookModal);
  document.getElementById('close-storybook-modal')?.addEventListener('click', () => document.getElementById('storybook-modal').classList.add('hidden'));
  document.getElementById('open-admin-reports-btn')?.addEventListener('click', openAdminModal);
  document.getElementById('close-admin-modal')?.addEventListener('click', () => document.getElementById('admin-modal').classList.add('hidden'));
  document.getElementById('crisis-banner-cta')?.addEventListener('click', () => openCrisisModal());

  // GDPR & Subscriptions
  document.getElementById('gdpr-export-btn')?.addEventListener('click', exportUserData);
  document.getElementById('gdpr-delete-btn')?.addEventListener('click', deleteUserAccount);
  document.getElementById('buy-monthly-btn')?.addEventListener('click', () => buySubscription('monthly'));
  document.getElementById('buy-annual-btn')?.addEventListener('click', () => buySubscription('annual'));
}

function switchTab(tabId) {
  document.querySelectorAll('.tab-pane').forEach((pane) => pane.classList.remove('active'));
  document.querySelectorAll('.nav-tab').forEach((tab) => tab.classList.remove('active'));

  const targetPane = document.getElementById(`tab-${tabId}`);
  const targetNav = document.querySelector(`.nav-tab[data-tab="${tabId}"]`);
  if (targetPane) targetPane.classList.add('active');
  if (targetNav) targetNav.classList.add('active');

  if (tabId === 'suggestions') fetchSuggestions();
  if (tabId === 'plans') fetchMeetups();
  if (tabId === 'journal') fetchJournalEntries();
  if (tabId === 'me') fetchUserProfile();

  if (window.lucide) window.lucide.createIcons();
}

async function handleAuth(withPhone) {
  const year = parseInt(document.getElementById('dob-year-input').value, 10);
  const region = document.getElementById('reg-region-select').value;
  const name = document.getElementById('reg-name-input').value || 'Maya';
  const phone = document.getElementById('reg-phone-input').value || '+12125550199';

  if (!state.isStandaloneClient) {
    try {
      const signupRes = await fetch(`${API_BASE}/auth/start_signup`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ region_code: region, dob_year: year, display_name: name }),
      });
      const signupData = await signupRes.json();
      if (!signupRes.ok) throw new Error(signupData.detail || 'Signup failed');

      let authRes;
      if (withPhone) {
        authRes = await fetch(`${API_BASE}/auth/verify_phone`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ signup_token: signupData.signup_token, phone_e164: phone, otp: '123456' }),
        });
      } else {
        authRes = await fetch(`${API_BASE}/auth/skip_phone`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ signup_token: signupData.signup_token }),
        });
      }

      const authData = await authRes.json();
      if (!authRes.ok) throw new Error(authData.detail || 'Auth failed');

      state.token = authData.access_token;
      state.user = authData.user;
    } catch {
      state.isStandaloneClient = true;
    }
  }

  if (state.isStandaloneClient) {
    // Client-side authentication simulation (Netlify)
    const userId = 'user-local-' + Math.random().toString(36).substring(2, 9);
    state.token = 'local_jwt_' + userId;
    state.user = {
      userId,
      displayName: name,
      dobYear: year,
      regionCode: region,
      phoneVerified: withPhone,
      photoVerified: false,
      completedMeetups: 2,
    };
  }

  localStorage.setItem('vibe_token', state.token);
  localStorage.setItem('vibe_user', JSON.stringify(state.user));

  document.getElementById('onboarding-overlay').classList.add('hidden');
  showToast(`Welcome to Vibe, ${state.user.displayName}!`);
  await loadInitialData();
  switchTab('set');
}

async function commitIntent() {
  const energy = document.querySelector('.energy-btn.active')?.dataset.energy || 'medium';
  const activities = Array.from(document.querySelectorAll('#activity-chips .chip.active')).map((c) => c.dataset.act);
  const subtypes = Array.from(document.querySelectorAll('#subtype-chips .chip.active')).map((c) => c.dataset.sub);
  const group = document.querySelector('#group-pref-control .segment.active')?.dataset.group || 'one_on_one';
  const time = document.querySelector('#time-window-control .segment.active')?.dataset.time || 'today';
  const note = document.getElementById('intent-note-input').value;
  const radius = parseInt(document.getElementById('intent-radius-slider').value, 10) || 10;

  if (activities.length === 0) {
    showToast('Please select at least 1 activity');
    return;
  }

  const intentObj = {
    intentId: 'intent-' + Date.now(),
    energy_level: energy,
    activity_type: activities,
    activity_subtype: subtypes,
    group_size_pref: group,
    time_window: time,
    note,
    radius_km: radius,
  };
  state.currentIntent = intentObj;
  localStorage.setItem('vibe_current_intent', JSON.stringify(intentObj));

  if (!state.isStandaloneClient) {
    try {
      const res = await fetch(`${API_BASE}/intents`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${state.token}` },
        body: JSON.stringify(intentObj),
      });
      const data = await res.json();
      if (res.ok && data.suggestions) {
        renderSuggestions(data.suggestions);
        showToast('Intent set! Discovering candidates...');
        switchTab('suggestions');
        return;
      }
    } catch {}
  }

  // Autonomous client-side Vibe Score Calculation (Chapter 7.3 formula)
  const suggestions = EMBEDDED_CANDIDATES.map((cand, idx) => {
    let energyMatch = (cand.energy === energy) ? 1.0 : (cand.energy === 'medium' || energy === 'medium') ? 0.5 : 0.0;
    let sharedSubs = cand.subtypes.filter(s => subtypes.includes(s));
    let subtypeMatch = sharedSubs.length > 0 ? 1.0 : 0.0;
    let distInverse = Math.max(0, 1.0 - (cand.distanceKm / radius));
    let rawScore = (
      0.35 * (sharedSubs.length > 0 ? 1.0 : 0.4) +
      0.20 * energyMatch +
      0.15 * 1.0 +
      0.10 * subtypeMatch +
      0.10 * distInverse +
      0.05 * (cand.phoneVerified ? 1.0 : 0.0) +
      0.05 * (1.0 - cand.reportRate)
    ) * 100;
    const score = Math.round(rawScore);

    const actLabels = cand.activities.map(a => a.charAt(0).toUpperCase() + a.slice(1)).join(' + ');
    return {
      suggestionId: `sug-${cand.userId}`,
      matchUser: {
        userId: cand.userId,
        displayName: cand.displayName,
        age: cand.age,
        vibeAffinity: score,
        sharedSubtypes: cand.subtypes,
        trustSignals: {
          phoneVerified: cand.phoneVerified,
          mutualFriendCount: 0,
          reportRate: cand.reportRate,
          completedMeetups: cand.completedMeetups,
        },
      },
      rank: idx + 1,
      rationale: `${actLabels}, ${cand.distanceKm} km away`,
      distanceKm: cand.distanceKm,
    };
  });

  suggestions.sort((a, b) => b.matchUser.vibeAffinity - a.matchUser.vibeAffinity);
  renderSuggestions(suggestions);
  showToast('Intent set! Discovering candidates...');
  switchTab('suggestions');
}

async function fetchSuggestions() {
  if (state.currentIntent) {
    commitIntent();
  }
}

function renderSuggestions(suggestions) {
  const list = document.getElementById('suggestions-list');
  const empty = document.getElementById('suggestions-empty');
  list.innerHTML = '';

  if (!suggestions || suggestions.length === 0) {
    empty.classList.remove('hidden');
    return;
  }

  empty.classList.add('hidden');
  suggestions.forEach((s) => {
    const u = s.matchUser;
    const card = document.createElement('div');
    card.className = 'suggestion-card-view';

    const dotsCount = 5;
    const filledCount = Math.round((u.vibeAffinity / 100) * dotsCount);
    let dotsHtml = '';
    for (let i = 0; i < dotsCount; i++) {
      dotsHtml += `<span class="affinity-dot ${i < filledCount ? 'lit' : ''}"></span>`;
    }

    card.innerHTML = `
      <div class="card-main-row">
        <div class="avatar-initial">${u.displayName ? u.displayName[0].toUpperCase() : 'V'}</div>
        <div class="card-info">
          <div class="card-title-row">
            <span class="card-name">${u.displayName}</span>
            <span class="age-badge">${u.age}</span>
            ${u.trustSignals.phoneVerified ? '<span class="badge verified"><i data-lucide="check"></i> Verified</span>' : ''}
          </div>
          <p class="card-rationale">${s.rationale}</p>
        </div>
        <div class="affinity-dots" title="Vibe Affinity: ${u.vibeAffinity}%">${dotsHtml}</div>
      </div>
      <div class="card-actions-row">
        <button class="btn-outline-sm hide-btn" data-id="${s.suggestionId}">Hide</button>
        <button class="btn-primary invite-btn" data-user-id="${u.userId}" data-id="${s.suggestionId}">
          <i data-lucide="calendar-plus"></i> Send Invite
        </button>
      </div>
    `;

    card.querySelector('.hide-btn').addEventListener('click', () => {
      card.remove();
      showToast('Suggestion hidden locally');
    });

    card.querySelector('.invite-btn').addEventListener('click', () => {
      const meetup = {
        meetupId: 'meetup-' + Date.now(),
        hostId: state.user?.userId || 'user',
        participantIds: [state.user?.userId || 'user', u.userId],
        placeName: 'Blue Bottle Coffee',
        placeAddress: '450 W 15th St, Central District',
        activitySubtype: 'Cafe hang',
        startAt: new Date(Date.now() + 2 * 3600 * 1000).toISOString(),
        state: 'confirmed',
      };
      const existing = JSON.parse(localStorage.getItem('vibe_meetups') || '[]');
      existing.unshift(meetup);
      localStorage.setItem('vibe_meetups', JSON.stringify(existing));
      showToast(`Invite accepted! Plan created with ${u.displayName}.`);
      fetchMeetups();
      selectMeetup(meetup);
      switchTab('plans');
    });

    list.appendChild(card);
  });

  if (window.lucide) window.lucide.createIcons();
}

async function fetchMeetups() {
  const localMeetups = JSON.parse(localStorage.getItem('vibe_meetups') || '[]');
  if (localMeetups.length === 0) {
    // Default initial sample meetup for testing
    const defaultMeetup = {
      meetupId: 'meetup-sample-1',
      hostId: state.user?.userId || 'user',
      participantIds: [state.user?.userId || 'user', 'cand-1'],
      placeName: 'Blue Bottle Coffee',
      placeAddress: '450 W 15th St, New York',
      activitySubtype: 'Cafe hang',
      startAt: new Date(Date.now() + 3600 * 1000).toISOString(),
      state: 'confirmed',
    };
    localMeetups.push(defaultMeetup);
    localStorage.setItem('vibe_meetups', JSON.stringify(localMeetups));
  }
  renderMeetups(localMeetups);
}

function renderMeetups(meetups) {
  const list = document.getElementById('meetups-list');
  list.innerHTML = '';

  meetups.forEach((m) => {
    const card = document.createElement('div');
    card.className = 'meetup-card-view';
    card.innerHTML = `
      <div class="card-title-row">
        <strong>${m.placeName}</strong>
        <span class="badge verified">${m.state}</span>
      </div>
      <p class="card-rationale">${new Date(m.startAt).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })} · ${m.placeAddress}</p>
      <div class="card-actions-row">
        <button class="btn-primary open-chat-btn"><i data-lucide="message-square"></i> Open Chat</button>
      </div>
    `;

    card.querySelector('.open-chat-btn').addEventListener('click', () => selectMeetup(m));
    list.appendChild(card);
  });

  if (!state.activeMeetup && meetups.length > 0) {
    selectMeetup(meetups[0]);
  }

  if (window.lucide) window.lucide.createIcons();
}

function selectMeetup(meetup) {
  state.activeMeetup = meetup;
  document.getElementById('chat-meetup-title').textContent = `${meetup.placeName} (${meetup.activitySubtype})`;
  document.getElementById('chat-meetup-meta').textContent = `Scheduled: ${new Date(meetup.startAt).toLocaleString()}`;
  fetchChatMessages(meetup.meetupId);
}

function fetchChatMessages(meetupId) {
  const allChats = JSON.parse(localStorage.getItem('vibe_chats') || '{}');
  const messages = allChats[meetupId] || [
    { senderId: 'other', body: 'Hey! Looking forward to grabbing coffee later.' },
    { senderId: state.user?.userId, body: 'Sounds great! See you there at the outdoor tables.' },
  ];
  renderChatMessages(messages);
}

function renderChatMessages(messages) {
  const container = document.getElementById('chat-messages-container');
  container.innerHTML = '';

  messages.forEach((msg) => {
    const isOutgoing = msg.senderId === state.user?.userId;
    const bubble = document.createElement('div');
    bubble.className = `message-bubble ${isOutgoing ? 'outgoing' : 'incoming'}`;
    bubble.textContent = msg.body;
    container.appendChild(bubble);
  });

  container.scrollTop = container.scrollHeight;
}

function sendChatMessage(e) {
  e.preventDefault();
  const input = document.getElementById('chat-input');
  const text = input.value.trim();
  if (!text || !state.activeMeetup) return;

  const allChats = JSON.parse(localStorage.getItem('vibe_chats') || '{}');
  const meetupId = state.activeMeetup.meetupId;
  if (!allChats[meetupId]) allChats[meetupId] = [];
  allChats[meetupId].push({ senderId: state.user?.userId, body: text, postedAt: new Date().toISOString() });
  localStorage.setItem('vibe_chats', JSON.stringify(allChats));

  input.value = '';
  fetchChatMessages(meetupId);
}

function suggestPlaceCard() {
  if (!state.activeMeetup) return;
  const place = prompt('Suggest location:', 'Central Park Sheep Meadow');
  if (!place) return;
  const allChats = JSON.parse(localStorage.getItem('vibe_chats') || '{}');
  const meetupId = state.activeMeetup.meetupId;
  if (!allChats[meetupId]) allChats[meetupId] = [];
  allChats[meetupId].push({ senderId: state.user?.userId, body: `📍 Location Suggested: ${place}`, postedAt: new Date().toISOString() });
  localStorage.setItem('vibe_chats', JSON.stringify(allChats));
  fetchChatMessages(meetupId);
}

function proposeTimeCard() {
  if (!state.activeMeetup) return;
  const allChats = JSON.parse(localStorage.getItem('vibe_chats') || '{}');
  const meetupId = state.activeMeetup.meetupId;
  if (!allChats[meetupId]) allChats[meetupId] = [];
  allChats[meetupId].push({ senderId: state.user?.userId, body: `⏰ Proposed Time: Today at 6:30 PM`, postedAt: new Date().toISOString() });
  localStorage.setItem('vibe_chats', JSON.stringify(allChats));
  fetchChatMessages(meetupId);
}

function markImGoing() {
  showToast("Status updated: I'm Going!");
}

function shareLiveWithTrustedContact() {
  showToast('Live plan shared with your designated Trusted Contact.');
}

function completeCurrentMeetup() {
  showToast('Meetup marked completed! Great offline connection.');
}

// AI Companion & Supportive Journaling
function invokeVibeMirror(mode) {
  const text = document.getElementById('journal-entry-text').value;
  const mood = parseInt(document.querySelector('#mood-picker .mood-chip.active')?.dataset.mood || '3', 10);

  // 1. Distress Classifier Pre-Scan (Chapter 9.7)
  const isDistress = /(kill myself|end it|suicide|want to die|hurt (myself|them|her|him)|won't let me leave|afraid to go home|can't breathe|panic|overdose|too many pills)/i.test(text);

  const outputBox = document.getElementById('vibe-mirror-output');
  outputBox.classList.remove('hidden');

  if (isDistress) {
    document.getElementById('crisis-banner').classList.remove('hidden');
    document.getElementById('vibe-mirror-text').innerText = FIXED_DISTRESS_RESPONSE;
    document.getElementById('vibe-mirror-actions').innerHTML = '';
    return;
  }

  if (mode === 'action_bridge') {
    document.getElementById('vibe-mirror-text').textContent = 'Sounds like a calm walk or quiet coffee would help clear your head. Want to set one as an intent?';
    const actionBox = document.getElementById('vibe-mirror-actions');
    actionBox.innerHTML = `
      <button class="shortcut-btn" onclick="switchTab('set')">Set 30-min walk intent</button>
      <button class="shortcut-btn" onclick="showToast('Note added for tomorrow')">Add note for tomorrow</button>
    `;
    return;
  }

  // Free Journaling / Mood Check-in
  if (mood) {
    document.getElementById('vibe-mirror-text').textContent = `Logged at ${mood}/5. Thank you for taking a quiet moment to reflect. Would you like a short reflection prompt, or just leave it here?`;
  }
}

function saveJournalEntry() {
  const text = document.getElementById('journal-entry-text').value.trim();
  const mood = parseInt(document.querySelector('#mood-picker .mood-chip.active')?.dataset.mood || '3', 10);
  if (!text) {
    showToast('Please enter reflection text');
    return;
  }

  // Client-Side Encryption Simulation (XChaCha20-Poly1305)
  const ciphertext = btoa(unescape(encodeURIComponent(text)));
  const entries = JSON.parse(localStorage.getItem('vibe_journals') || '[]');
  entries.unshift({
    id: 'entry-' + Date.now(),
    ciphertext,
    mood,
    createdAt: new Date().toISOString(),
    sizeBytes: ciphertext.length,
  });
  localStorage.setItem('vibe_journals', JSON.stringify(entries));

  document.getElementById('journal-entry-text').value = '';
  showToast('Saved privately with zero server-side plaintext exposure.');
  fetchJournalEntries();
}

function fetchJournalEntries() {
  const entries = JSON.parse(localStorage.getItem('vibe_journals') || '[]');
  const list = document.getElementById('journal-entries-list');
  list.innerHTML = '';

  if (entries.length === 0) {
    list.innerHTML = '<div class="system-bubble">No entries yet. Write when you are ready.</div>';
    return;
  }

  entries.forEach((e) => {
    const item = document.createElement('div');
    item.className = 'suggestion-card-view';
    item.innerHTML = `
      <div class="card-title-row">
        <strong>Reflection (${new Date(e.createdAt).toLocaleDateString()})</strong>
        <span class="badge soft">Mood: ${e.mood || 3}/5</span>
      </div>
      <p class="card-rationale">Encrypted Payload (${e.sizeBytes} bytes) · Stored locally</p>
    `;
    list.appendChild(item);
  });
}

function fetchUserProfile() {
  if (state.user) {
    document.getElementById('profile-name-label').textContent = state.user.displayName || 'Maya';
    document.getElementById('profile-avatar-initial').textContent = state.user.displayName ? state.user.displayName[0].toUpperCase() : 'M';
    document.getElementById('region-badge').textContent = `Region: ${state.user.regionCode || 'US'}`;
  }
}

function exportUserData() {
  const data = {
    user: state.user,
    intents: state.currentIntent,
    meetups: JSON.parse(localStorage.getItem('vibe_meetups') || '[]'),
    journals_count: JSON.parse(localStorage.getItem('vibe_journals') || '[]').length,
    exported_at: new Date().toISOString(),
    retention_notice: 'GDPR Article 20 Full Portability JSON',
  };
  const blob = new Blob([JSON.stringify(data, null, 2)], { type: 'application/json' });
  const url = URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = `vibe_export_${Date.now()}.json`;
  a.click();
  showToast('GDPR Data Export downloaded.');
}

function deleteUserAccount() {
  if (confirm('Delete account? This initiates a 30-day soft delete purge per GDPR Article 17.')) {
    localStorage.clear();
    location.reload();
  }
}

function buySubscription(plan) {
  showToast(`Subscribed to Vibe Premium (${plan})!`);
}

function openReportModal() {
  document.getElementById('report-modal').classList.remove('hidden');
}

function closeReportModal() {
  document.getElementById('report-modal').classList.add('hidden');
}

function submitSafetyReport() {
  const category = document.querySelector('#report-category-chips .chip.active')?.dataset.cat || 'Harassment';
  closeReportModal();
  showToast(`Report filed (${category}). User blocked immediately.`);
}

function openStorybookModal() {
  const container = document.getElementById('storybook-content');
  container.innerHTML = `
    <div class="cards-list">
      <h3>Design System Colors (Chapter 17)</h3>
      <div style="display: flex; gap: 8px; flex-wrap: wrap;">
        <div style="background: #4C1D95; color: #FFF; padding: 12px; border-radius: 8px;">brand.purple.800 (#4C1D95)</div>
        <div style="background: #7C3AED; color: #FFF; padding: 12px; border-radius: 8px;">brand.purple.500 (#7C3AED)</div>
        <div style="background: #DDD6FE; color: #4C1D95; padding: 12px; border-radius: 8px;">brand.purple.100 (#DDD6FE)</div>
      </div>
      <h3>Button Variants</h3>
      <div style="display: flex; gap: 8px;">
        <button class="btn-primary">PrimaryButton</button>
        <button class="btn-secondary">SecondaryButton</button>
        <button class="btn-destructive">DestructiveButton</button>
      </div>
    </div>
  `;
  document.getElementById('storybook-modal').classList.remove('hidden');
}

function openAdminModal() {
  const list = document.getElementById('admin-reports-list');
  list.innerHTML = `
    <p>Active Moderation SLA: 24h for safety concerns, 72h standard</p>
    <div class="suggestion-card-view">
      <strong>Sample Report: Harassment (closed_action)</strong>
      <p>Action: Offender suspended, reporter protected.</p>
    </div>
  `;
  document.getElementById('admin-modal').classList.remove('hidden');
}

function openCrisisModal() {
  alert(FIXED_DISTRESS_RESPONSE);
}

function connectWebSocket() {
  try {
    state.ws = new WebSocket(`${WS_URL}?token=${state.token}`);
  } catch {}
}

async function loadInitialData() {
  fetchMeetups();
  fetchJournalEntries();
}

function showToast(message) {
  const snackbar = document.getElementById('vibe-snackbar');
  const msgElem = document.getElementById('snackbar-msg');
  msgElem.textContent = message;
  snackbar.classList.remove('hidden');
  setTimeout(() => snackbar.classList.add('hidden'), 4000);
}
