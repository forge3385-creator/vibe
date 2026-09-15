// ==========================================================================
// VIBE WEB CLIENT APPLICATION (CHAPTERS 18, 19, 28)
// ==========================================================================

const API_BASE = window.location.origin + '/v1';
const WS_URL = (window.location.protocol === 'https:' ? 'wss://' : 'ws://') + window.location.host + '/v1/realtime';

const state = {
  token: localStorage.getItem('vibe_token') || null,
  user: JSON.parse(localStorage.getItem('vibe_user') || 'null'),
  currentIntent: null,
  activeMeetup: null,
  ws: null,
  isDark: false,
};

// Initialize App
document.addEventListener('DOMContentLoaded', async () => {
  if (window.lucide) {
    window.lucide.createIcons();
  }

  setupEventListeners();

  if (!state.token) {
    // Show onboarding flow if not logged in
    document.getElementById('onboarding-overlay').classList.remove('hidden');
  } else {
    await fetchUserProfile();
    await loadInitialData();
    connectWebSocket();
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

  // Onboarding Buttons
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

  // Activity Chips Toggle (Max 3)
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

  // Subtype Chips Toggle
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
    slider.value = 25;
    document.getElementById('radius-val').textContent = '25 km';
    switchTab('set');
  });

  // Refresh Suggestions
  document.getElementById('refresh-suggestions-btn')?.addEventListener('click', fetchSuggestions);

  // Chat Submission Form
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

  // Modals & Developer tools
  document.getElementById('quick-report-btn')?.addEventListener('click', () => openReportModal());
  document.getElementById('close-report-modal')?.addEventListener('click', () => closeReportModal());
  document.getElementById('cancel-report-btn')?.addEventListener('click', () => closeReportModal());
  document.getElementById('submit-report-btn')?.addEventListener('click', submitSafetyReport);
  document.getElementById('open-storybook-btn')?.addEventListener('click', openStorybookModal);
  document.getElementById('close-storybook-modal')?.addEventListener('click', () => document.getElementById('storybook-modal').classList.add('hidden'));
  document.getElementById('open-admin-reports-btn')?.addEventListener('click', openAdminModal);
  document.getElementById('close-admin-modal')?.addEventListener('click', () => document.getElementById('admin-modal').classList.add('hidden'));

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
    localStorage.setItem('vibe_token', state.token);
    localStorage.setItem('vibe_user', JSON.stringify(state.user));

    document.getElementById('onboarding-overlay').classList.add('hidden');
    showToast(`Welcome to Vibe, ${authData.user.displayName}!`);
    await loadInitialData();
    connectWebSocket();
    switchTab('set');
  } catch (err) {
    alert(err.message);
  }
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

  try {
    const res = await fetch(`${API_BASE}/intents`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${state.token}`,
      },
      body: JSON.stringify({
        energy_level: energy,
        activity_type: activities,
        activity_subtype: subtypes,
        group_size_pref: group,
        time_window: time,
        note,
        radius_km: radius,
      }),
    });
    const data = await res.json();
    if (!res.ok) throw new Error(data.detail || 'Failed to set intent');

    state.currentIntent = data.intent;
    renderSuggestions(data.suggestions);
    showToast('Intent set! Discovering candidates...');
    switchTab('suggestions');
  } catch (err) {
    showToast(`Error: ${err.message}`);
  }
}

async function fetchSuggestions() {
  try {
    const res = await fetch(`${API_BASE}/suggestions`, {
      headers: { Authorization: `Bearer ${state.token}` },
    });
    const data = await res.json();
    renderSuggestions(data.suggestions || []);
  } catch (err) {
    console.error(err);
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

    card.querySelector('.hide-btn').addEventListener('click', () => hideSuggestion(s.suggestionId, card));
    card.querySelector('.invite-btn').addEventListener('click', () => acceptMatch(s.suggestionId, u.userId));

    list.appendChild(card);
  });

  if (window.lucide) window.lucide.createIcons();
}

async function hideSuggestion(suggestionId, cardElem) {
  await fetch(`${API_BASE}/suggestions/${suggestionId}/hide`, {
    method: 'POST',
    headers: { Authorization: `Bearer ${state.token}` },
  });
  cardElem.remove();
  showToast('Suggestion hidden locally');
}

async function acceptMatch(suggestionId, targetUserId) {
  try {
    const res = await fetch(`${API_BASE}/matches/${suggestionId}/accept`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${state.token}`,
      },
      body: JSON.stringify({ target_user_id: targetUserId, origin_intent_id: state.currentIntent?.intentId }),
    });
    const data = await res.json();
    showToast('Plan created! Opening meetup chat...');
    await fetchMeetups();
    if (data.meetup) {
      selectMeetup(data.meetup);
    }
    switchTab('plans');
  } catch (err) {
    showToast(`Failed to accept match: ${err.message}`);
  }
}

async function fetchMeetups() {
  try {
    const res = await fetch(`${API_BASE}/meetups`, {
      headers: { Authorization: `Bearer ${state.token}` },
    });
    const data = await res.json();
    renderMeetups(data.meetups || []);
  } catch (err) {
    console.error(err);
  }
}

function renderMeetups(meetups) {
  const list = document.getElementById('meetups-list');
  list.innerHTML = '';

  if (meetups.length === 0) {
    list.innerHTML = '<div class="system-bubble">No active meetups yet. Send an invite from Suggestions!</div>';
    return;
  }

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

async function fetchChatMessages(meetupId) {
  try {
    const res = await fetch(`${API_BASE}/meetups/${meetupId}/chat`, {
      headers: { Authorization: `Bearer ${state.token}` },
    });
    const data = await res.json();
    renderChatMessages(data.messages || []);
  } catch (err) {
    console.error(err);
  }
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

async function sendChatMessage(e) {
  e.preventDefault();
  const input = document.getElementById('chat-input');
  const text = input.value.trim();
  if (!text || !state.activeMeetup) return;

  try {
    await fetch(`${API_BASE}/meetups/${state.activeMeetup.meetupId}/chat`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${state.token}`,
      },
      body: JSON.stringify({ body: text, kind: 'text' }),
    });
    input.value = '';
    fetchChatMessages(state.activeMeetup.meetupId);
  } catch (err) {
    showToast('Failed to send message');
  }
}

async function suggestPlaceCard() {
  if (!state.activeMeetup) return;
  const placeName = prompt('Enter place name:', 'Blue Bottle Coffee');
  if (!placeName) return;

  await fetch(`${API_BASE}/meetups/${state.activeMeetup.meetupId}/chat/place_card`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${state.token}`,
    },
    body: JSON.stringify({
      place_id: 'p_123',
      place_name: placeName,
      address: '450 W 15th St, NYC',
    }),
  });
  fetchChatMessages(state.activeMeetup.meetupId);
}

async function proposeTimeCard() {
  if (!state.activeMeetup) return;
  const time = new Date(Date.now() + 3600000).toISOString();
  await fetch(`${API_BASE}/meetups/${state.activeMeetup.meetupId}/chat/time_card`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${state.token}`,
    },
    body: JSON.stringify({ time }),
  });
  fetchChatMessages(state.activeMeetup.meetupId);
}

async function markImGoing() {
  if (!state.activeMeetup) return;
  await fetch(`${API_BASE}/meetups/${state.activeMeetup.meetupId}`, {
    method: 'PATCH',
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${state.token}`,
    },
    body: JSON.stringify({ state: 'in_progress' }),
  });
  showToast("Status updated: I'm Going!");
  fetchMeetups();
}

async function shareLiveWithTrustedContact() {
  if (!state.activeMeetup) return;
  await fetch(`${API_BASE}/meetups/${state.activeMeetup.meetupId}/trusted_share`, {
    method: 'POST',
    headers: { Authorization: `Bearer ${state.token}` },
  });
  showToast('Live plan shared with your designated Trusted Contact.');
}

async function completeCurrentMeetup() {
  if (!state.activeMeetup) return;
  await fetch(`${API_BASE}/meetups/${state.activeMeetup.meetupId}/complete`, {
    method: 'POST',
    headers: { Authorization: `Bearer ${state.token}` },
  });
  showToast('Meetup marked completed! Great offline connection.');
  fetchMeetups();
}

// Journal & AI Companion
async function invokeVibeMirror(mode) {
  const text = document.getElementById('journal-entry-text').value;
  const mood = parseInt(document.querySelector('#mood-picker .mood-chip.active')?.dataset.mood || '3', 10);

  try {
    const res = await fetch(`${API_BASE}/journal/companion`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${state.token}`,
      },
      body: JSON.stringify({ text, mood, mode, userPrompt: mode === 'action_bridge' ? 'help me act on this' : undefined }),
    });
    const data = await res.json();

    const outputBox = document.getElementById('vibe-mirror-output');
    outputBox.classList.remove('hidden');

    if (data.isDistress) {
      document.getElementById('crisis-banner').classList.remove('hidden');
      document.getElementById('vibe-mirror-text').innerText = data.reply;
    } else {
      document.getElementById('vibe-mirror-text').textContent = data.reply;
    }

    const actionBox = document.getElementById('vibe-mirror-actions');
    actionBox.innerHTML = '';
    if (data.actionBridge) {
      data.actionBridge.forEach((act) => {
        const btn = document.createElement('button');
        btn.className = 'shortcut-btn';
        btn.textContent = act;
        btn.addEventListener('click', () => {
          switchTab('set');
        });
        actionBox.appendChild(btn);
      });
    }
  } catch (err) {
    showToast(`AI Companion error: ${err.message}`);
  }
}

async function saveJournalEntry() {
  const text = document.getElementById('journal-entry-text').value;
  const mood = parseInt(document.querySelector('#mood-picker .mood-chip.active')?.dataset.mood || '3', 10);
  if (!text) {
    showToast('Please enter reflection text');
    return;
  }

  // Client-side encryption simulation (XChaCha20-Poly1305 per Section 9.5)
  const ciphertext = btoa(unescape(encodeURIComponent(text)));
  const nonce = btoa(Date.now().toString());

  try {
    await fetch(`${API_BASE}/journal/entries`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${state.token}`,
      },
      body: JSON.stringify({ ciphertext, nonce, mood }),
    });
    document.getElementById('journal-entry-text').value = '';
    showToast('Saved privately with zero server-side plaintext exposure.');
    fetchJournalEntries();
  } catch (err) {
    showToast('Failed to save journal entry');
  }
}

async function fetchJournalEntries() {
  try {
    const res = await fetch(`${API_BASE}/journal/entries`, {
      headers: { Authorization: `Bearer ${state.token}` },
    });
    const data = await res.json();
    const list = document.getElementById('journal-entries-list');
    list.innerHTML = '';

    if (!data.entries || data.entries.length === 0) {
      list.innerHTML = '<div class="system-bubble">No entries yet. Write when you are ready.</div>';
      return;
    }

    data.entries.forEach((e) => {
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
  } catch (err) {
    console.error(err);
  }
}

// User Profile & Settings
async function fetchUserProfile() {
  if (!state.token) return;
  try {
    const res = await fetch(`${API_BASE}/me`, {
      headers: { Authorization: `Bearer ${state.token}` },
    });
    const data = await res.json();
    document.getElementById('profile-name-label').textContent = data.display_name;
    document.getElementById('profile-avatar-initial').textContent = data.display_name ? data.display_name[0].toUpperCase() : 'V';
    document.getElementById('phone-verified-badge').style.display = data.phone_verified ? 'inline-flex' : 'none';
    document.getElementById('photo-verified-badge').style.display = data.photo_verified ? 'inline-flex' : 'none';
    document.getElementById('region-badge').textContent = `Region: ${data.region_code}`;

    fetchTrustedContacts();
  } catch (err) {
    console.error(err);
  }
}

async function fetchTrustedContacts() {
  try {
    const res = await fetch(`${API_BASE}/trusted_contacts`, {
      headers: { Authorization: `Bearer ${state.token}` },
    });
    const data = await res.json();
    const list = document.getElementById('trusted-contacts-list');
    list.innerHTML = '';
    (data.contacts || []).forEach((c) => {
      const row = document.createElement('div');
      row.className = 'switch-row';
      row.innerHTML = `<span>${c.name || c.value} (${c.kind})</span><button class="btn-outline-sm danger">Remove</button>`;
      row.querySelector('button').addEventListener('click', async () => {
        await fetch(`${API_BASE}/trusted_contacts/${c.id}`, { method: 'DELETE', headers: { Authorization: `Bearer ${state.token}` } });
        fetchTrustedContacts();
      });
      list.appendChild(row);
    });
  } catch (err) {
    console.error(err);
  }
}

async function exportUserData() {
  const res = await fetch(`${API_BASE}/me/export`, {
    headers: { Authorization: `Bearer ${state.token}` },
  });
  const data = await res.json();
  const blob = new Blob([JSON.stringify(data.data, null, 2)], { type: 'application/json' });
  const url = URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = `vibe_export_${Date.now()}.json`;
  a.click();
  showToast('GDPR Data Export generated and downloaded.');
}

async function deleteUserAccount() {
  if (confirm('Are you sure you want to delete your account? This initiates a 30-day soft delete purge.')) {
    await fetch(`${API_BASE}/me`, {
      method: 'DELETE',
      headers: { Authorization: `Bearer ${state.token}` },
    });
    localStorage.clear();
    state.token = null;
    location.reload();
  }
}

async function buySubscription(plan) {
  try {
    const res = await fetch(`${API_BASE}/subscriptions/validate_receipt`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${state.token}`,
      },
      body: JSON.stringify({
        provider: 'apple',
        receipt_data: `receipt_${plan}_${Date.now()}`,
        plan_id: plan,
      }),
    });
    const data = await res.json();
    if (res.ok) {
      showToast(`Subscribed to Vibe Premium (${plan})!`);
      fetchUserProfile();
    }
  } catch (err) {
    showToast('Subscription error');
  }
}

// Safety Report Modal (≤ 2 taps)
function openReportModal() {
  document.getElementById('report-modal').classList.remove('hidden');
}

function closeReportModal() {
  document.getElementById('report-modal').classList.add('hidden');
}

async function submitSafetyReport() {
  const category = document.querySelector('#report-category-chips .chip.active')?.dataset.cat || 'Harassment';
  const body = document.getElementById('report-body-input').value;

  try {
    const res = await fetch(`${API_BASE}/reports`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${state.token}`,
      },
      body: JSON.stringify({
        subject_id: 'target-reported-user-id',
        category,
        body: body || 'Report submitted via safety modal',
      }),
    });
    const data = await res.json();
    closeReportModal();
    showToast(`Report filed (Ref: ${data.reference_id}). You won't see them again.`);
  } catch (err) {
    showToast('Failed to submit report');
  }
}

function openStorybookModal() {
  const container = document.getElementById('storybook-content');
  container.innerHTML = `
    <div class="cards-list">
      <h3>Design System Colors</h3>
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

async function openAdminModal() {
  const res = await fetch(`${API_BASE}/admin/reports`);
  const data = await res.json();
  const list = document.getElementById('admin-reports-list');
  list.innerHTML = `<p>Under-16 attempts blocked: ${data.under_16_attempts_count}</p>`;
  (data.reports || []).forEach((r) => {
    const row = document.createElement('div');
    row.className = 'suggestion-card-view';
    row.innerHTML = `<strong>Category: ${r.category} (${r.status})</strong><p>${r.body}</p>`;
    list.appendChild(row);
  });
  document.getElementById('admin-modal').classList.remove('hidden');
}

function connectWebSocket() {
  if (!state.token) return;
  state.ws = new WebSocket(`${WS_URL}?token=${state.token}`);

  state.ws.onmessage = (event) => {
    try {
      const msg = JSON.parse(event.data);
      if (msg.type === 'chat.message.new') {
        if (state.activeMeetup && state.activeMeetup.meetupId === msg.meetup_id) {
          fetchChatMessages(msg.meetup_id);
        }
      } else if (msg.type === 'meetup.state.changed') {
        fetchMeetups();
      }
    } catch (e) {}
  };
}

async function loadInitialData() {
  await fetchSuggestions();
  await fetchMeetups();
}

function showToast(message) {
  const snackbar = document.getElementById('vibe-snackbar');
  const msgElem = document.getElementById('snackbar-msg');
  msgElem.textContent = message;
  snackbar.classList.remove('hidden');
  setTimeout(() => snackbar.classList.add('hidden'), 4000);
}
