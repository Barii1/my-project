# ⚠️ URGENT: Update Firestore Rules to Fix Friend Requests

## The Problem
Your app is getting `PERMISSION_DENIED` errors because Firestore security rules are blocking writes to friend requests.

## ✅ Quick Fix (5 Minutes)

### Step 1: Open Firebase Console
1. Go to: https://console.firebase.google.com/
2. Select your project (likely `ostaad-88d1f` or similar)

### Step 2: Navigate to Firestore Rules
1. Click **"Firestore Database"** in the left sidebar
2. Click the **"Rules"** tab at the top

### Step 3: Replace ALL Rules
**DELETE everything** in the rules editor, then **PASTE this:**

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Users collection - allow authenticated users to read, owners to write
    match /users/{userId} {
      allow read: if request.auth != null;
      allow create, update, delete: if request.auth != null && request.auth.uid == userId;
      
      // Friends subcollection
      match /friends/{friendId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
      
      // Friend requests subcollection
      match /friendRequests/{requestType} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
        
        match /requests/{requestId} {
          allow read, write: if request.auth != null && request.auth.uid == userId;
        }
      }
    }
    
    // Chats collection
    match /chats/{chatId} {
      allow read: if request.auth != null && 
        request.auth.uid in resource.data.participants;
      allow create: if request.auth != null && 
        request.auth.uid in request.resource.data.participants;
      allow update: if request.auth != null && 
        request.auth.uid in resource.data.participants;
      allow delete: if request.auth != null && 
        request.auth.uid in resource.data.participants;
      
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

### Step 4: Publish Rules
1. Click the **"Publish"** button (top right, usually orange/blue)
2. Wait for confirmation: "Rules published successfully"

### Step 5: Test
1. Go back to your app
2. Try sending a friend request
3. Should work now! ✅

## 🎯 What These Rules Do

- ✅ **Users can read any user document** (needed for search)
- ✅ **Users can write their own user document** (profile updates)
- ✅ **Users can manage their own friends list** (add/remove friends)
- ✅ **Users can manage their own friend requests** (send/receive/accept/reject)
- ✅ **Users can read/write chats they're participants in** (messaging)
- ✅ **Users can read/write messages in their chats** (send/receive messages)

## ⚠️ Common Mistakes

1. **Not clicking "Publish"** - Rules must be published to take effect
2. **Syntax errors** - Make sure you copied the entire rules block
3. **Old rules still active** - Delete everything before pasting new rules
4. **Wrong project** - Make sure you're in the correct Firebase project

## ✅ Verification

After publishing rules, check:
1. Rules show "Published" status
2. No red error messages in rules editor
3. Try sending friend request - should work
4. Check console - should see `✅ Friend request sent successfully`

## 🆘 Still Not Working?

If you still see permission errors after updating rules:

1. **Check Rules Status:**
   - Rules should show "Published"
   - No syntax errors (red underlines)

2. **Verify User is Logged In:**
   - Check Firebase Auth → Users
   - Make sure your user exists

3. **Check Console Logs:**
   - Look for the exact error message
   - It will tell you which collection/document is failing

4. **Test in Firebase Console:**
   - Try manually creating a document in Firestore
   - See if it works or gives permission error

## 📸 Visual Guide

```
Firebase Console
  └── Your Project
      └── Firestore Database
          └── Rules Tab ← CLICK HERE
              └── [Paste rules above]
              └── [Click Publish]
```

## 🎉 After Rules Are Updated

Your app will be able to:
- ✅ Send friend requests
- ✅ Receive friend requests
- ✅ Accept/reject requests
- ✅ Message friends
- ✅ All in real-time!

**This is the ONLY thing blocking your friend requests from working!**

