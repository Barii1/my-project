# 🔴 CRITICAL: Fix Permission Error - 2 Minutes

## The Error You're Seeing
```
PERMISSION_DENIED: Write failed at users/.../friendRequests/sent/requests/...
```

## ✅ The Fix (Copy & Paste in Firebase Console)

### Step 1: Open Firebase Console
👉 https://console.firebase.google.com/

### Step 2: Go to Firestore Rules
1. Click **"Firestore Database"** (left sidebar)
2. Click **"Rules"** tab (top)

### Step 3: DELETE Everything, Then PASTE This:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read: if request.auth != null;
      allow create, update, delete: if request.auth != null && request.auth.uid == userId;
      
      match /friends/{friendId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
      
      match /friendRequests/{requestType} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
        match /requests/{requestId} {
          allow read, write: if request.auth != null && request.auth.uid == userId;
        }
      }
    }
    
    match /chats/{chatId} {
      allow read: if request.auth != null && request.auth.uid in resource.data.participants;
      allow create: if request.auth != null && request.auth.uid in request.resource.data.participants;
      allow update: if request.auth != null && request.auth.uid in resource.data.participants;
      allow delete: if request.auth != null && request.auth.uid in resource.data.participants;
      
      match /messages/{messageId} {
        allow read: if request.auth != null && request.auth.uid in get(/databases/$(database)/documents/chats/$(chatId)).data.participants;
        allow create: if request.auth != null && request.auth.uid == request.resource.data.senderId && request.auth.uid in get(/databases/$(database)/documents/chats/$(chatId)).data.participants;
        allow update: if request.auth != null && request.auth.uid in get(/databases/$(database)/documents/chats/$(chatId)).data.participants;
        allow delete: if request.auth != null && request.auth.uid == request.resource.data.senderId;
      }
    }
  }
}
```

### Step 4: Click "Publish" Button
**This is critical - rules won't work until you click Publish!**

### Step 5: Test
Try sending a friend request - it should work now! ✅

---

## ⚠️ Why This Is Happening

Your current Firestore rules are blocking writes to:
- `users/{userId}/friendRequests/sent/requests/{requestId}`
- `users/{userId}/friendRequests/received/requests/{requestId}`

The rules above allow users to write to their own friendRequests subcollection.

## 🎯 What These Rules Allow

- ✅ Users can read any user profile (for search)
- ✅ Users can write their own profile
- ✅ Users can manage their own friends list
- ✅ **Users can write to their own friendRequests** ← This fixes your error!
- ✅ Users can read/write chats they're in
- ✅ Users can send/receive messages

## 🚨 Still Not Working?

1. **Did you click "Publish"?** - Rules must be published
2. **Check for syntax errors** - Red underlines in rules editor
3. **Verify you're in the correct project** - Check project name
4. **Wait 10 seconds** - Rules can take a moment to propagate

---

## 📋 Quick Copy-Paste (Just the Rules)

If you just need the rules to copy:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read: if request.auth != null;
      allow create, update, delete: if request.auth != null && request.auth.uid == userId;
      
      match /friends/{friendId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
      
      match /friendRequests/{requestType} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
        match /requests/{requestId} {
          allow read, write: if request.auth != null && request.auth.uid == userId;
        }
      }
    }
    
    match /chats/{chatId} {
      allow read: if request.auth != null && request.auth.uid in resource.data.participants;
      allow create: if request.auth != null && request.auth.uid in request.resource.data.participants;
      allow update: if request.auth != null && request.auth.uid in resource.data.participants;
      allow delete: if request.auth != null && request.auth.uid in resource.data.participants;
      
      match /messages/{messageId} {
        allow read: if request.auth != null && request.auth.uid in get(/databases/$(database)/documents/chats/$(chatId)).data.participants;
        allow create: if request.auth != null && request.auth.uid == request.resource.data.senderId && request.auth.uid in get(/databases/$(database)/documents/chats/$(chatId)).data.participants;
        allow update: if request.auth != null && request.auth.uid in get(/databases/$(database)/documents/chats/$(chatId)).data.participants;
        allow delete: if request.auth != null && request.auth.uid == request.resource.data.senderId;
      }
    }
  }
}
```

---

**This is the ONLY fix needed. Your code is correct!**

