# Chat Storage Guide

## 📁 Firestore Structure

### Chat Documents
**Collection:** `/chats/{chatId}`

**Chat ID Format:** `chat_{userId1}_{userId2}` (alphabetically sorted)

**Example:** If User A (ID: `abc123`) chats with User B (ID: `xyz789`), the chat ID will be `chat_abc123_xyz789` (sorted alphabetically).

**Chat Document Fields:**
```javascript
{
  participants: [userId1, userId2],           // Array of user IDs
  participantNames: [userName1, userName2],   // Array of user names
  participantsMap: {                          // Map for quick lookup
    userId1: userName1,
    userId2: userName2
  },
  createdAt: Timestamp,                       // When chat was created
  lastMessage: String,                        // Last message text
  lastMessageTime: Timestamp,                // When last message was sent
  userId1_typing: Boolean,                    // Typing indicator for user 1
  userId1_typingTime: Timestamp,              // When user 1 started typing
  userId2_typing: Boolean,                    // Typing indicator for user 2
  userId2_typingTime: Timestamp              // When user 2 started typing
}
```

### Messages Subcollection
**Collection:** `/chats/{chatId}/messages/{messageId}`

**Message Document Fields:**
```javascript
{
  sender: String,           // Sender's display name
  senderId: String,         // Sender's user ID
  text: String,             // Message content
  timestamp: Timestamp,      // When message was sent
  read: Boolean             // Whether message has been read
}
```

## 🔄 How It Works

### 1. **Sending a Message**
When User A sends a message to User B:
1. Chat ID is generated: `chat_{sortedUserId1}_{sortedUserId2}`
2. If chat doesn't exist, it's created with participant info
3. Message is added to `/chats/{chatId}/messages/`
4. Chat document is updated with `lastMessage` and `lastMessageTime`

### 2. **Receiving Messages**
- Both users listen to the same chat document
- Messages are ordered by `timestamp` (ascending)
- Real-time updates via Firestore streams

### 3. **Typing Indicators**
- Stored in the chat document itself
- Format: `{userId}_typing` and `{userId}_typingTime`
- Automatically expires after 5 seconds

### 4. **Read Receipts**
- Each message has a `read` boolean field
- When User B opens the chat, messages from User A are marked as read
- Updated via `markMessagesAsRead()`

## 🔐 Security Rules Required

Make sure your Firestore rules allow:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Chat documents - only participants can read/write
    match /chats/{chatId} {
      allow read, write: if request.auth != null && 
        (request.auth.uid in resource.data.participants || 
         request.auth.uid in request.resource.data.participants);
      
      // Messages subcollection
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

## 📝 Code Usage

### Sending a Message
```dart
await chatService.sendMessage(
  currentUserId: currentUserId,
  currentUserName: currentUserName,
  friendUserId: friendUserId,
  friendName: friendName,
  messageText: 'Hello!',
);
```

### Listening to Messages
```dart
StreamBuilder<List<ChatMessage>>(
  stream: chatService.getMessagesStream(
    currentUserId: currentUserId,
    friendUserId: friendUserId,
    friendName: friendName,
  ),
  builder: (context, snapshot) {
    // Handle messages
  },
)
```

### Typing Indicator
```dart
// Set typing status
await chatService.setTypingStatus(
  currentUserId: currentUserId,
  friendUserId: friendUserId,
  currentUserName: currentUserName,
  friendName: friendName,
  isTyping: true,
);

// Listen to typing status
StreamBuilder<bool>(
  stream: chatService.getTypingStatusStream(
    currentUserId: currentUserId,
    friendUserId: friendUserId,
  ),
  builder: (context, snapshot) {
    // Show typing indicator
  },
)
```

## ✅ Benefits of This Structure

1. **Consistent Chat IDs**: Alphabetical sorting ensures both users access the same chat
2. **Real-time Updates**: Firestore streams provide instant message delivery
3. **Scalable**: Subcollections keep messages organized and performant
4. **Efficient Queries**: Can query by participants, last message time, etc.
5. **Typing Indicators**: Stored in chat doc for fast access
6. **Read Receipts**: Per-message read status tracking

## 🚀 After Adding as Friend

Once two users become friends:
1. They can immediately start chatting
2. Chat document is created on first message
3. Both users see the same chat
4. Messages are synced in real-time
5. Typing indicators work automatically

