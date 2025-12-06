// Script to delete user account from Firebase
// Run with: node delete_user.js

const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json'); // You'll need to download this from Firebase Console

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const auth = admin.auth();
const firestore = admin.firestore();

const EMAIL_TO_DELETE = 'hassaanbari90@gmail.com';

async function deleteUserByEmail(email) {
  try {
    console.log(`Looking for user with email: ${email}`);
    
    // Get user by email
    const user = await auth.getUserByEmail(email);
    const uid = user.uid;
    
    console.log(`Found user: ${user.displayName || 'N/A'} (UID: ${uid})`);
    
    // Delete user data from Firestore
    console.log('Deleting Firestore data...');
    
    // Delete user document
    await firestore.collection('users').doc(uid).delete();
    
    // Delete subcollections (friends, requests, etc.)
    const subcollections = ['friends', 'friendRequests'];
    for (const subcol of subcollections) {
      const snapshot = await firestore.collection('users').doc(uid).collection(subcol).get();
      const batch = firestore.batch();
      snapshot.docs.forEach(doc => batch.delete(doc.ref));
      await batch.commit();
      console.log(`Deleted ${snapshot.size} documents from ${subcol}`);
    }
    
    // Delete from Firebase Auth
    console.log('Deleting from Firebase Authentication...');
    await auth.deleteUser(uid);
    
    console.log(`✅ Successfully deleted user: ${email}`);
    
  } catch (error) {
    if (error.code === 'auth/user-not-found') {
      console.log(`❌ No user found with email: ${email}`);
    } else {
      console.error('❌ Error deleting user:', error.message);
    }
  }
}

// Run the deletion
deleteUserByEmail(EMAIL_TO_DELETE)
  .then(() => {
    console.log('Script completed');
    process.exit(0);
  })
  .catch((error) => {
    console.error('Script failed:', error);
    process.exit(1);
  });
