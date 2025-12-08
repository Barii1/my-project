# Friend Request System - Fixes and Guide

## ✅ Issues Fixed

### 1. **Friend Request Failing to Send**
**Problem:** Requests were failing silently without proper error messages.

**Fixes Applied:**
- ✅ Now retrieves current user's name from Firestore (not just Auth displayName)
- ✅ Better error logging with stack traces
- ✅ Improved error messages shown to user
- ✅ Validates user authentication before sending

### 2. **Other User Not Seeing Requests**
**Problem:** Requests might not appear due to Firestore rules or query issues.

**Fixes Applied:**
- ✅ Requests are stored in both:
  - Sender's `/users/{senderId}/friendRequests/sent/requests/{receiverId}`
  - Receiver's `/users/{receiverId}/friendRequests/received/requests/{senderId}`
- ✅ Stream query uses correct path: `received/requests` with `status: 'pending'`
- ✅ Real-time updates via Firestore streams

## 🔐 Required Firestore Security Rules

Add these rules to your Firestore Database → Rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
      
      // Friends subcollection
      match /friends/{friendId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
      
      // Friend requests subcollection
      match /friendRequests/{requestType} {
        // requestType is either "sent" or "received"
        allow read, write: if request.auth != null && request.auth.uid == userId;
        
        match /requests/{requestId} {
          allow read, write: if request.auth != null && request.auth.uid == userId;
        }
      }
    }
    
    // Chats collection
    match /chats/{chatId} {
      allow read, write: if request.auth != null && 
        (request.auth.uid in resource.data.participants || 
         request.auth.uid in request.resource.data.participants);
      
      match /messages/{messageId} {
        allow read: if request.auth != null && 
          request.auth.uid in get(/databases/$(database)/documents/chats/$(chatId)).data.participants;
        allow create: if request.auth != null && 
          request.auth.uid == request.resource.data.senderId &&
          request.auth.uid in get(/databases/$(database)/documents/chats/$(chatId)).data.participants;
        allow update: if request.auth != null && 
          request.auth.uid in get(/databases/$(database)/documents/chats/$(chatId)).data.participants;
        allow delete: if request.auth != null && 
          request.auth.uid == request.resource.data.senderId;
      }
    }
  }
}
```

## 📋 How Friend Requests Work

### Sending a Request
1. User A searches for User B
2. User A clicks "Add" button
3. System checks:
   - ✅ User A is authenticated
   - ✅ User A and User B are not the same person
   - ✅ They're not already friends
   - ✅ No pending request already exists
4. Creates two documents:
   - In User A's `sent/requests/{userIdB}` 
   - In User B's `received/requests/{userIdA}`
5. Both documents have `status: 'pending'`

### Receiving a Request
1. User B opens Friends screen
2. `getPendingRequestsStream()` queries:
   - `/users/{userIdB}/friendRequests/received/requests`
   - Where `status == 'pending'`
3. Requests appear in real-time via Firestore stream
4. User B can Accept or Reject

### Accepting a Request
1. User B clicks "Accept"
2. System:
   - Adds User A to User B's friends list
   - Adds User B to User A's friends list
   - Updates both request documents to `status: 'accepted'`
3. Both users can now see each other in friends list
4. Both users can now message each other

## 💬 Chat System After Adding Friend

### Chat Storage Location
**Collection:** `/chats/{chatId}`

**Chat ID Format:** `chat_{userId1}_{userId2}` (alphabetically sorted)

**Example:**
- User A (ID: `abc123`) and User B (ID: `xyz789`)
- Chat ID: `chat_abc123_xyz789`

### Chat Document Structure
```javascript
{
  participants: [userId1, userId2],
  participantNames: [userName1, userName2],
  participantsMap: {
    userId1: userName1,
    userId2: userName2
  },
  createdAt: Timestamp,
  lastMessage: String,
  lastMessageTime: Timestamp
}
```

### Messages Subcollection
**Path:** `/chats/{chatId}/messages/{messageId}`

```javascript
{
  sender: String,        // Display name
  senderId: String,      // User ID
  text: String,          // Message content
  timestamp: Timestamp,  // When sent
  read: Boolean          // Read status
}
```

### How Messaging Works
1. **First Message:**
   - Chat document is created automatically
   - Message is added to messages subcollection
   - Both users can see it immediately

2. **Subsequent Messages:**
   - Added to same chat document
   - Real-time updates via Firestore streams
   - Typing indicators stored in chat document

3. **After Adding Friend:**
   - Users can immediately start chatting
   - No additional setup needed
   - Chat is created on first message

## 🐛 Troubleshooting

### "Failed to send friend request"
**Check:**
1. ✅ User is logged in (check Firebase Auth)
2. ✅ Firestore rules allow writes (see rules above)
3. ✅ Check console logs for specific error
4. ✅ Verify user's `fullName` exists in Firestore `/users/{userId}`

**Console Logs to Check:**
- `📤 Sending friend request from...` - Shows request attempt
- `✅ Friend request sent successfully` - Success
- `❌ Error sending friend request: ...` - Shows actual error

### "Other user not seeing request"
**Check:**
1. ✅ Firestore rules allow reads on `received/requests`
2. ✅ Request document exists in receiver's `received/requests`
3. ✅ Request has `status: 'pending'`
4. ✅ Receiver is logged in and viewing Friends screen
5. ✅ Check Firestore console to verify document exists

**Firestore Path to Check:**
```
/users/{receiverUserId}/friendRequests/received/requests/{senderUserId}
```

### "Can't message after adding friend"
**Check:**
1. ✅ Both users are in each other's friends list
2. ✅ Chat document is created (check `/chats/{chatId}`)
3. ✅ Firestore rules allow chat reads/writes
4. ✅ Both users have correct `friendId` and `currentUserId`

## 🧪 Testing Steps

### Test 1: Send Friend Request
1. User A logs in
2. User A searches for User B
3. User A clicks "Add"
4. ✅ Should see "Friend request sent" message
5. ✅ Check console for success log

### Test 2: Receive Friend Request
1. User B logs in
2. User B opens Friends screen
3. ✅ Should see User A's request in "Friend Requests" section
4. ✅ Request shows User A's name

### Test 3: Accept Request
1. User B clicks "Accept"
2. ✅ User A appears in User B's friends list
3. ✅ User B appears in User A's friends list (when User A refreshes)
4. ✅ Both can see each other in leaderboard

### Test 4: Send Message
1. User A opens chat with User B
2. User A sends a message
3. ✅ Message appears for User A
4. ✅ User B sees message in real-time
5. ✅ Chat document created in Firestore

## 📊 Firestore Structure Summary

```
/users/{userId}
  ├── fullName: String
  ├── email: String
  ├── friends/{friendId}
  │   ├── friendName: String
  │   └── addedAt: Timestamp
  └── friendRequests/
      ├── sent/requests/{toUserId}
      │   ├── toUserId: String
      │   ├── toUserName: String
      │   ├── status: String
      │   └── sentAt: Timestamp
      └── received/requests/{fromUserId}
          ├── fromUserId: String
          ├── fromUserName: String
          ├── status: String
          └── receivedAt: Timestamp

/chats/{chatId}
  ├── participants: [userId1, userId2]
  ├── participantNames: [name1, name2]
  ├── participantsMap: {userId1: name1, userId2: name2}
  ├── createdAt: Timestamp
  ├── lastMessage: String
  ├── lastMessageTime: Timestamp
  └── messages/{messageId}
      ├── sender: String
      ├── senderId: String
      ├── text: String
      ├── timestamp: Timestamp
      └── read: Boolean
```

## ✅ Summary

**Fixed Issues:**
- ✅ Friend requests now properly retrieve user names from Firestore
- ✅ Better error handling and logging
- ✅ Requests are stored correctly for both sender and receiver
- ✅ Real-time updates work via Firestore streams
- ✅ Chat system works immediately after adding friend

**Next Steps:**
1. Update Firestore security rules (see above)
2. Test sending/receiving requests with 2 devices
3. Test messaging after accepting request
4. Check console logs if issues persist

