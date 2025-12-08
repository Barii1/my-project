# Firestore Security Rules - Complete Setup

## ⚠️ IMPORTANT: Copy these rules to Firebase Console

Go to: **Firebase Console → Firestore Database → Rules** and paste the rules below.

## Complete Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Helper function to check if user is authenticated
    function isAuthenticated() {
      return request.auth != null;
    }
    
    // Helper function to check if user owns the document
    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }
    
    // Users collection
    match /users/{userId} {
      // Allow authenticated users to read any user document
      allow read: if isAuthenticated();
      
      // Allow users to write their own document
      allow create, update: if isOwner(userId);
      allow delete: if isOwner(userId);
      
      // Friends subcollection
      match /friends/{friendId} {
        allow read, write: if isOwner(userId);
      }
      
      // Friend requests subcollection
      match /friendRequests/{requestType} {
        // requestType is either "sent" or "received"
        allow read, write: if isOwner(userId);
        
        match /requests/{requestId} {
          allow read, write: if isOwner(userId);
        }
      }
    }
    
    // Chats collection
    match /chats/{chatId} {
      // Allow read/write if user is a participant
      allow read: if isAuthenticated() && 
        request.auth.uid in resource.data.participants;
      
      allow create: if isAuthenticated() && 
        request.auth.uid in request.resource.data.participants;
      
      allow update: if isAuthenticated() && 
        request.auth.uid in resource.data.participants;
      
      allow delete: if isAuthenticated() && 
        request.auth.uid in resource.data.participants;
      
      // Messages subcollection
      match /messages/{messageId} {
        allow read: if isAuthenticated() && 
          request.auth.uid in get(/databases/$(database)/documents/chats/$(chatId)).data.participants;
        
        allow create: if isAuthenticated() && 
          request.auth.uid == request.resource.data.senderId &&
          request.auth.uid in get(/databases/$(database)/documents/chats/$(chatId)).data.participants;
        
        allow update: if isAuthenticated() && 
          request.auth.uid in get(/databases/$(database)/documents/chats/$(chatId)).data.participants;
        
        allow delete: if isAuthenticated() && 
          request.auth.uid == request.resource.data.senderId;
      }
    }
  }
}
```

## 🔧 How to Apply Rules

1. **Open Firebase Console:**
   - Go to https://console.firebase.google.com/
   - Select your project: `ostaad-88d1f` (or your project name)

2. **Navigate to Firestore Rules:**
   - Click on **Firestore Database** in the left sidebar
   - Click on the **Rules** tab at the top

3. **Paste the Rules:**
   - Delete all existing rules
   - Paste the complete rules from above
   - Click **Publish**

4. **Verify:**
   - Rules should show "Published" status
   - Try sending a friend request again

## 🐛 Common Issues Fixed

### Issue 1: Permission Denied on User Document Read
**Problem:** Users can't read their own user document.

**Fix:** Rules now allow authenticated users to read any user document:
```javascript
allow read: if isAuthenticated();
```

### Issue 2: Permission Denied on Friend Requests
**Problem:** Users can't write to friendRequests subcollection.

**Fix:** Rules allow users to write to their own friendRequests:
```javascript
match /friendRequests/{requestType} {
  allow read, write: if isOwner(userId);
}
```

### Issue 3: Permission Denied on Chats
**Problem:** Users can't create or read chat documents.

**Fix:** Rules check if user is a participant:
```javascript
allow read: if isAuthenticated() && 
  request.auth.uid in resource.data.participants;
```

## 📝 Rule Breakdown

### Users Collection
- **Read:** Any authenticated user can read user documents (needed for search)
- **Write:** Only the owner can write their own document

### Friends Subcollection
- **Read/Write:** Only the owner can manage their friends list

### Friend Requests Subcollection
- **Read/Write:** Only the owner can manage their friend requests
- Works for both `sent` and `received` request types

### Chats Collection
- **Read:** Only participants can read the chat
- **Create:** User must be in the participants array
- **Update:** Only participants can update (for typing indicators, etc.)

### Messages Subcollection
- **Read:** Only chat participants can read messages
- **Create:** Only if user is sender and participant
- **Update:** Only participants can update (for read receipts)
- **Delete:** Only the sender can delete their message

## ✅ Testing After Rules Update

1. **Test Friend Request:**
   - Send a friend request
   - Should see "Friend request sent" message
   - Check console for success logs

2. **Test Receiving Request:**
   - Other user should see request in Friends screen
   - Should appear in real-time

3. **Test Accepting Request:**
   - Accept the request
   - Both users should appear in each other's friends list

4. **Test Messaging:**
   - Open chat with friend
   - Send a message
   - Should appear for both users in real-time

## 🔍 Debugging Permission Issues

If you still see permission errors:

1. **Check Authentication:**
   ```dart
   print('Current user: ${FirebaseAuth.instance.currentUser?.uid}');
   ```

2. **Check Firestore Rules:**
   - Verify rules are published
   - Check for syntax errors in rules
   - Make sure `rules_version = '2'` is at the top

3. **Check Console Logs:**
   - Look for specific permission errors
   - Check which collection/document is failing

4. **Test in Firebase Console:**
   - Try reading/writing documents manually
   - Check if it's a rules issue or code issue

## 📊 Expected Behavior

After applying these rules:
- ✅ Users can search for other users
- ✅ Users can send friend requests
- ✅ Users can see incoming friend requests
- ✅ Users can accept/reject requests
- ✅ Users can message friends
- ✅ No duplicate users in search results

