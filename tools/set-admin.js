// Usage:
// 1) Place your Firebase service account JSON at project root or in tools/ (e.g., serviceAccountKey.json)
// 2) Provide UID via CLI arg or env var
//    - CLI: node tools/set-admin.js <UID>
//    - Env:  $env:FIREBASE_TARGET_UID="<UID>"; node tools/set-admin.js
// 3) After running, ask the user to log out/in to refresh token

const admin = require('firebase-admin');
const path = require('path');

// Adjust the path to your service account file as needed
const serviceAccountPath = path.resolve(__dirname, '../serviceAccountKey.json');
const serviceAccount = require(serviceAccountPath);

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

async function main() {
  const cliUid = process.argv[2];
  const uid = cliUid || process.env.FIREBASE_TARGET_UID;

  if (!uid) {
    console.error('ERROR: Missing UID. Provide via CLI (node tools/set-admin.js <UID>) or env (FIREBASE_TARGET_UID).');
    process.exit(1);
  }

  // Optional: print project info for clarity
  const tokenInfo = serviceAccount.project_id ? `project_id=${serviceAccount.project_id}` : 'project_id not found in key';
  console.log(`Using service account (${tokenInfo}). Setting admin claim for UID: ${uid}`);

  await admin.auth().setCustomUserClaims(uid, { admin: true });
  console.log(`SUCCESS: Admin claim set for UID: ${uid}`);
  console.log('Reminder: User must log out and back in to refresh token.');
}

main().catch((err) => {
  console.error('Failed to set admin claim:', err);
  process.exit(1);
});
