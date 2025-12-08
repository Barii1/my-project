import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Firestore Chat Service
/// Handles all chat-related operations with Firebase Firestore
class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Generate consistent chat ID from two userIds
  /// Alphabetically sorted to ensure both users access same chat
  String _generateChatId(String userId1, String userId2) {
    final users = [userId1, userId2]..sort();
    return 'chat_${users[0]}_${users[1]}';
  }

  /// Initialize chat document with participants
  Future<void> _ensureChatExists({
    required String chatId,
    required String currentUserId,
    required String currentUserName,
    required String friendUserId,
    required String friendName,
  }) async {
    final chatDoc = _firestore.collection('chats').doc(chatId);
    final snapshot = await chatDoc.get();

    if (!snapshot.exists) {
      await chatDoc.set({
        'participants': [currentUserId, friendUserId],
        'participantNames': [currentUserName, friendName],
        'participantsMap': {
          currentUserId: currentUserName,
          friendUserId: friendName,
        },
        'createdAt': FieldValue.serverTimestamp(),
        'lastMessage': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
      });
    }
  }

  /// Send a message
  Future<void> sendMessage({
    required String currentUserId,
    required String currentUserName,
    required String friendUserId,
    required String friendName,
    required String messageText,
  }) async {
    final chatId = _generateChatId(currentUserId, friendUserId);

    // Ensure chat exists
    await _ensureChatExists(
      chatId: chatId,
      currentUserId: currentUserId,
      currentUserName: currentUserName,
      friendUserId: friendUserId,
      friendName: friendName,
    );

    // Add message to subcollection
    final messagesRef = _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages');

    await messagesRef.add({
      'sender': currentUserName,
      'senderId': currentUserId,
      'text': messageText,
      'timestamp': FieldValue.serverTimestamp(),
      'read': false,
    });

    // Update chat metadata
    await _firestore.collection('chats').doc(chatId).update({
      'lastMessage': messageText,
      'lastMessageTime': FieldValue.serverTimestamp(),
    });
  }

  /// Get messages stream for real-time updates
  Stream<List<ChatMessage>> getMessagesStream({
    required String currentUserId,
    required String friendUserId,
    required String friendName,
  }) {
    final chatId = _generateChatId(currentUserId, friendUserId);
    print('💬 Getting messages stream for chat: $chatId');

    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return ChatMessage(
          id: doc.id,
          sender: data['sender'] ?? '',
          senderId: data['senderId'] ?? '',
          text: data['text'] ?? '',
          timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
          read: data['read'] ?? false,
        );
      }).toList();
    });
  }
  

  /// Mark messages as read
  Future<void> markMessagesAsRead({
    required String currentUserId,
    required String friendUserId,
    required String messageId,
  }) async {
    final chatId = _generateChatId(currentUserId, friendUserId);

    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .update({'read': true});
  }

  /// Delete a message
  Future<void> deleteMessage({
    required String currentUserId,
    required String friendUserId,
    required String messageId,
  }) async {
    final chatId = _generateChatId(currentUserId, friendUserId);

    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .delete();
  }

  /// Get unread message count
  Future<int> getUnreadCount({
    required String currentUserId,
    required String friendUserId,
  }) async {
    final chatId = _generateChatId(currentUserId, friendUserId);

    final snapshot = await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .where('senderId', isNotEqualTo: currentUserId)
        .where('read', isEqualTo: false)
        .get();

    return snapshot.docs.length;
  }

  /// Set typing status
  Future<void> setTypingStatus({
    required String currentUserId,
    required String friendUserId,
    required String currentUserName,
    required String friendName,
    required bool isTyping,
  }) async {
    final chatId = _generateChatId(currentUserId, friendUserId);

    await _firestore.collection('chats').doc(chatId).set({
      'participants': [currentUserId, friendUserId],
      'participantNames': [currentUserName, friendName],
      'participantsMap': {
        currentUserId: currentUserName,
        friendUserId: friendName,
      },
      '${currentUserId}_typing': isTyping,
      '${currentUserId}_typingTime': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Get typing status stream
  Stream<bool> getTypingStatusStream({
    required String currentUserId,
    required String friendUserId,
  }) {
    final chatId = _generateChatId(currentUserId, friendUserId);

    return _firestore
        .collection('chats')
        .doc(chatId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) return false;
      final data = snapshot.data();
      if (data == null) return false;

      final isTyping = data['${friendUserId}_typing'] ?? false;
      final typingTime = data['${friendUserId}_typingTime'] as Timestamp?;

      // Only show typing if it was updated in last 5 seconds
      if (typingTime != null && isTyping) {
        final diff = DateTime.now().difference(typingTime.toDate());
        return diff.inSeconds < 5;
      }

      return false;
    });
  }

  /// Backfill existing chat docs to ensure senderId and participant maps exist.
  /// Returns number of message documents updated.
  Future<int> backfillChatMetadata() async {
    final user = _auth.currentUser;
    if (user == null) return 0;

    final uid = user.uid;
    final displayName = user.displayName ?? user.email ?? 'User';
    int updatedMessages = 0;

    // Find chats that include the current user
    final chats = await _firestore
        .collection('chats')
        .where('participants', arrayContains: uid)
        .get();

    for (final chatDoc in chats.docs) {
      final chatData = chatDoc.data();
      final participants = (chatData['participants'] as List?)?.cast<String>() ?? [];
      final participantNames = (chatData['participantNames'] as List?)?.cast<String>() ?? [];

      // Ensure participants map is present
      final participantsMap = Map<String, dynamic>.from(chatData['participantsMap'] ?? {});
      if (participants.isNotEmpty && participantNames.length == participants.length) {
        for (var i = 0; i < participants.length; i++) {
          participantsMap[participants[i]] = participantNames[i];
        }
      }
      // Make sure current user is present
      participantsMap[uid] = displayName;

      final batch = _firestore.batch();
      batch.set(chatDoc.reference, {
        'participantsMap': participantsMap,
        'participants': participants.isNotEmpty ? participants : [uid],
        'participantNames': participantNames.isNotEmpty ? participantNames : [displayName],
      }, SetOptions(merge: true));

      // Backfill messages missing senderId
      final messages = await chatDoc.reference.collection('messages').get();
      for (final msg in messages.docs) {
        final data = msg.data();
        if (!data.containsKey('senderId')) {
          batch.update(msg.reference, {
            'senderId': data['sender'] ?? uid,
          });
          updatedMessages++;
        }
      }

      await batch.commit();
    }

    return updatedMessages;
  }
}

/// Chat Message Model
class ChatMessage {
  final String id;
  final String sender;
  final String senderId;
  final String text;
  final DateTime timestamp;
  final bool read;

  ChatMessage({
    required this.id,
    required this.sender,
    required this.senderId,
    required this.text,
    required this.timestamp,
    this.read = false,
  });

  /// Check if message is from current user
  bool isFromUser(String currentUserId) => senderId == currentUserId;
}
