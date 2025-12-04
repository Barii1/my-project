# Friend System Setup Guide

## ✅ What Was Implemented

### 1. **Real User Search with Firestore**
- Users can now search for other users by name
- Case-insensitive search functionality
- All users in the database are searchable

### 2. **Friend Request System**
- Send friend requests to any user
- Accept or decline incoming requests
- Real-time updates via Firestore streams
- Friend requests persist across devices

### 3. **Real Friends List**
- Friends are stored in Firestore (not hardcoded)
- Friends leaderboard shows actual friends
- Chat with friends via 1:1 messaging

### 4. **No More Hardcoded Data**
- Removed all mock friends and users
- Everything pulls from Firestore in real-time
- Works properly with 2+ devices

---

## 🔧 For Existing Users (Migration Required)

If you have existing users in your Firestore database, you need to add the `searchName` field for search to work properly.

### Option 1: Firebase Console (Manual)

1. Go to Firebase Console → Firestore Database
2. Navigate to the `users` collection
3. For each user document:
   - Click on the user document
   - Click "Add field"
   - Field name: `searchName`
   - Field value: (the user's fullName in lowercase)
   - Example: If `fullName` is "John Doe", set `searchName` to "john doe"

### Option 2: Cloud Function (Automated)

Run this code in Firebase Functions to update all existing users:

```javascript
const functions = require('firebase-functions');
const admin = require('firebase-admin');

exports.addSearchNameToUsers = functions.https.onRequest(async (req, res) => {
  const db = admin.firestore();
  const usersRef = db.collection('users');
  
  try {
    const snapshot = await usersRef.get();
    const batch = db.batch();
    let count = 0;
    
    snapshot.forEach(doc => {
      const data = doc.data();
      if (data.fullName && !data.searchName) {
        batch.update(doc.ref, {
          searchName: data.fullName.toLowerCase()
        });
        count++;
      }
    });
    
    await batch.commit();
    res.send(`Updated ${count} users with searchName field`);
  } catch (error) {
    console.error('Error updating users:', error);
    res.status(500).send('Error: ' + error.message);
  }
});
```

### Option 3: Run from Flutter App (One-time)

Add this to your app as a one-time migration function:

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> migrateExistingUsers() async {
  final firestore = FirebaseFirestore.instance;
  final usersSnapshot = await firestore.collection('users').get();
  
  final batch = firestore.batch();
  int count = 0;
  
  for (var doc in usersSnapshot.docs) {
    final data = doc.data();
    if (data['fullName'] != null && data['searchName'] == null) {
      batch.update(doc.reference, {
        'searchName': (data['fullName'] as String).toLowerCase(),
      });
      count++;
    }
  }
  
  await batch.commit();
  print('Updated $count users with searchName field');
}
```

---

## 🧪 Testing the Friend System

### Test with 2 Devices:

1. **Device 1 - User A:**
   - Sign in with Account A
   - Go to Friends tab
   - Tap "+" icon (Add Friend)
   - Search for User B's name
   - Tap "Add" button
   - Should show "Requested" status

2. **Device 2 - User B:**
   - Sign in with Account B
   - Go to Friends tab
   - Should see "Friend Requests" section
   - Should see request from User A
   - Tap "Accept"

3. **Verify Friendship:**
   - Both devices should now show each other in Friends Leaderboard
   - Both users can chat with each other
   - Friends list persists after app restart

### Expected Behavior:

✅ **Search:**
- Type partial name → matching users appear
- Case doesn't matter ("john" finds "John Doe")
- Only shows users from database (no hardcoded names)

✅ **Friend Requests:**
- Sent requests show "Requested" badge
- Received requests appear in "Friend Requests" section
- Accept → both users become friends
- Decline → request is removed

✅ **Friends List:**
- Shows all accepted friends
- Displays leaderboard with rankings
- Chat button opens 1:1 chat
- Real-time updates when friends are added

---

## 🔐 Firestore Security Rules

Make sure your Firestore has these security rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection - users can read all, write own
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
      
      // Friends subcollection
      match /friends/{friendId} {
        allow read: if request.auth != null && request.auth.uid == userId;
        allow write: if request.auth != null && request.auth.uid == userId;
      }
      
      // Friend requests subcollection
      match /friendRequests/{docId}/{requestId} {
        allow read: if request.auth != null && request.auth.uid == userId;
        allow write: if request.auth != null && 
                      (request.auth.uid == userId || request.auth.uid == requestId);
      }
    }
    
    // Chat messages
    match /chats/{chatId}/messages/{messageId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

---

## 📊 Firestore Data Structure

### Users Collection
```
/users/{userId}
  - email: "user@example.com"
  - fullName: "John Doe"
  - searchName: "john doe"  ← Required for search
  - createdAt: Timestamp
  - updatedAt: Timestamp
```

### Friends Subcollection
```
/users/{userId}/friends/{friendId}
  - friendId: "abc123"
  - friendName: "Jane Smith"
  - addedAt: Timestamp
```

### Friend Requests
```
/users/{userId}/friendRequests/received/requests/{fromUserId}
  - fromUserId: "xyz789"
  - fromUserName: "Bob Johnson"
  - status: "pending" | "accepted" | "rejected"
  - receivedAt: Timestamp

/users/{userId}/friendRequests/sent/requests/{toUserId}
  - toUserId: "abc123"
  - toUserName: "Alice Williams"
  - status: "pending" | "accepted" | "rejected"
  - sentAt: Timestamp
```

---

## 🐛 Troubleshooting

### "No users found" when searching:
- ✓ Check if users have `searchName` field (must be lowercase)
- ✓ Verify Firestore security rules allow reading users collection
- ✓ Check Firebase Console → Authentication (users exist)

### Friend requests not appearing:
- ✓ Verify both users are signed in
- ✓ Check Firestore security rules for friendRequests subcollection
- ✓ Ensure StreamBuilder is listening to the correct path

### Can't chat with friends:
- ✓ Verify Firestore chat rules are set
- ✓ Check if both users are actually friends (check /friends subcollection)
- ✓ Enable Firestore in Firebase Console if not already enabled

### Search is case-sensitive:
- ✓ Ensure `searchName` field is lowercase
- ✓ Run migration script to update existing users
- ✓ New signups automatically get lowercase searchName

---

## 🚀 Next Steps

### Recommended Enhancements:

1. **User Profiles**
   - Add profile pictures
   - Show user stats in search results
   - Display mutual friends

2. **Advanced Search**
   - Filter by school/organization
   - Search by email
   - Tag-based filtering

3. **Friend Management**
   - Remove friends
   - Block users
   - Friend suggestions

4. **Notifications**
   - Push notifications for friend requests
   - Badge count for pending requests
   - In-app notifications

---

## ✅ Summary

All hardcoded friends and users have been removed. The app now uses real Firestore data for:
- ✅ User search (case-insensitive)
- ✅ Friend requests (send/accept/decline)
- ✅ Friends list (real-time sync)
- ✅ 1:1 chat between friends
- ✅ Multi-device support

**Test with 2 devices to verify everything works!**
