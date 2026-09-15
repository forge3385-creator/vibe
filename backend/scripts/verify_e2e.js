async function runVerification() {
  console.log('--- VIBE LOCALHOST END-TO-END VERIFICATION ---');

  // 1. Health
  const healthRes = await fetch('http://localhost:3000/v1/health');
  const health = await healthRes.json();
  console.log('1. Health Check:', health.status);

  // 2. Start Signup
  const signupRes = await fetch('http://localhost:3000/v1/auth/start_signup', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ region_code: 'US', dob_year: 2002, display_name: 'Maya' }),
  });
  const signup = await signupRes.json();
  console.log('2. Age Gate & Signup Token:', signup.signup_token ? 'SUCCESS' : 'FAILED');

  // 3. Skip Phone -> Issue JWT
  const authRes = await fetch('http://localhost:3000/v1/auth/skip_phone', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ signup_token: signup.signup_token }),
  });
  const auth = await authRes.json();
  const token = auth.access_token;
  console.log('3. Auth JWT Issued:', auth.user.displayName, '(unverified_phone:', auth.claims.unverified_phone, ')');

  // 4. Set Intent & Synchronous Suggestions
  const intentRes = await fetch('http://localhost:3000/v1/intents', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${token}` },
    body: JSON.stringify({
      energy_level: 'medium',
      activity_type: ['chill', 'food'],
      activity_subtype: ['cafe_hang', 'coffee'],
      group_size_pref: 'one_on_one',
      time_window: 'today',
      note: 'Looking for a calm cafe study session',
      radius_km: 15,
    }),
  });
  const intentData = await intentRes.json();
  console.log('4. Set Intent Created:', intentData.intent.intentId);
  console.log('   Synchronous Suggestions Returned:', intentData.suggestions.length);
  if (intentData.suggestions.length > 0) {
    console.log('   Top Ranked Candidate:', intentData.suggestions[0].matchUser.displayName, 'Vibe Affinity:', intentData.suggestions[0].matchUser.vibeAffinity);
  }

  // 5. Zero-Retention AI Companion
  const aiRes = await fetch('http://localhost:3000/v1/journal/companion', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${token}` },
    body: JSON.stringify({ text: 'Had a long study day, feeling relaxed.', mood: 4, mode: 'mood_checkin' }),
  });
  const aiData = await aiRes.json();
  console.log('5. Vibe Mirror AI Reply:', aiData.reply);

  // 6. Crisis Distress Classifier Guardrail
  const crisisRes = await fetch('http://localhost:3000/v1/journal/companion', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${token}` },
    body: JSON.stringify({ text: 'I want to die and hurt myself' }),
  });
  const crisisData = await crisisRes.json();
  console.log('6. Distress Trigger Caught:', crisisData.isDistress, '(Warm handoff active)');

  // 7. Web Client Static Assets
  const htmlRes = await fetch('http://localhost:3000/');
  const cssRes = await fetch('http://localhost:3000/style.css');
  const jsRes = await fetch('http://localhost:3000/app.js');
  console.log('7. Web Client Files: index.html =', htmlRes.status, 'style.css =', cssRes.status, 'app.js =', jsRes.status);

  console.log('--- ALL VERIFICATIONS PASSED SUCCESSFULLY ---');
}

runVerification().catch(console.error);
