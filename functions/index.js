import functions from 'firebase-functions';
import admin from 'firebase-admin';
import { createWorker } from 'tesseract.js';

if (!admin.apps.length) {
  admin.initializeApp();
}
const db = admin.firestore();

// Utility: ISO week key (YYYY-Www)
function weekKey(date = new Date()) {
  const d = new Date(Date.UTC(date.getFullYear(), date.getMonth(), date.getDate()));
  const dayNum = d.getUTCDay() || 7; // Monday=1
  d.setUTCDate(d.getUTCDate() + 4 - dayNum);
  const yearStart = new Date(Date.UTC(d.getUTCFullYear(), 0, 1));
  const weekNo = Math.ceil((((d - yearStart) / 86400000) + 1) / 7);
  return `${d.getUTCFullYear()}-W${String(weekNo).padStart(2, '0')}`;
}

// Scheduled: Generate weekly quiz document.
export const generateWeeklyQuiz = functions.pubsub.schedule('every monday 00:00').onRun(async () => {
  const key = weekKey();
  const existing = await db.collection('weekly_quizzes').doc(key).get();
  if (existing.exists) return null; // Already generated

  // Fetch candidate questions (simplified: latest 50)
  const snap = await db.collection('questions').orderBy('createdAt', 'desc').limit(50).get();
  const ids = snap.docs.map(d => d.id);
  // Pick first 15 (implement better selection later)
  const selected = ids.slice(0, 15);

  await db.collection('weekly_quizzes').doc(key).set({
    id: key,
    questionIds: selected,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    status: 'active'
  });
  return null;
});

// Scheduled: Aggregate leaderboards (daily snapshot)
export const aggregateLeaderboards = functions.pubsub.schedule('every 24 hours').onRun(async () => {
  const usersSnap = await db.collection('users').orderBy('xp', 'desc').limit(100).get();
  const leaders = usersSnap.docs.map(d => ({ id: d.id, xp: d.get('xp') || 0, username: d.get('username') || null }));
  const wk = weekKey();
  await db.collection('leaderboards_global').doc('weekly').set({ week: wk, leaders, updatedAt: admin.firestore.FieldValue.serverTimestamp() }, { merge: true });
  await db.collection('leaderboards_global').doc('all_time').set({ leaders, updatedAt: admin.firestore.FieldValue.serverTimestamp() }, { merge: true });
  return null;
});

// Firestore Trigger: Award XP on quiz attempt creation.
export const awardXpOnQuizAttempt = functions.firestore.document('quiz_attempts/{attemptId}').onCreate(async (snap, context) => {
  const data = snap.data();
  const userId = data.userId;
  const score = data.score || 0; // e.g., fraction 0-1
  const difficulty = data.difficulty || 'medium';
  let baseXp = Math.round((score * 100));
  if (difficulty === 'hard') baseXp = Math.round(baseXp * 1.3);
  else if (difficulty === 'easy') baseXp = Math.round(baseXp * 0.8);

  const userRef = db.collection('users').doc(userId);
  await db.runTransaction(async (tx) => {
    const userDoc = await tx.get(userRef);
    const currentXp = userDoc.exists ? (userDoc.get('xp') || 0) : 0;
    tx.set(userRef, { xp: currentXp + baseXp, lastXpAwardAt: admin.firestore.FieldValue.serverTimestamp() }, { merge: true });
  });
  return null;
});

// HTTP OCR fallback for web/desktop (base64 PNG/JPEG)
export const ocrImage = functions.https.onRequest(async (req, res) => {
  try {
    if (req.method !== 'POST') return res.status(405).send('Method Not Allowed');
    const { imageBase64 } = req.body || {};
    if (!imageBase64) return res.status(400).send('imageBase64 required');
    const worker = await createWorker();
    await worker.loadLanguage('eng');
    await worker.initialize('eng');
    const result = await worker.recognize(Buffer.from(imageBase64, 'base64'));
    await worker.terminate();
    return res.json({ text: result.data.text });
  } catch (e) {
    console.error(e);
    return res.status(500).send('OCR error');
  }
});
