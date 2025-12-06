import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Firestore Chat Service
/// Handles all chat-related operations with Firebase Firestore
class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Generate consistent chat ID from two user names
  /// Alphabetically sorted to ensure both users access same chat
  String _generateChatId(String user1, String user2) {
    final users = [user1, user2]..sort();
    return 'chat_${users[0]}_${users[1]}';
  }

  /// Get current user ID (email or uid)
  String _getCurrentUserId() {
    final user = _auth.currentUser;
    return user?.email ?? user?.uid ?? 'anonymous';
  }

  /// Initialize chat document with participants
  Future<void> _ensureChatExists(String chatId, String user1, String user2) async {
    final chatDoc = _firestore.collection('chats').doc(chatId);
    final snapshot = await chatDoc.get();

    if (!snapshot.exists) {
      await chatDoc.set({
        'participants': [user1, user2],
        'participantNames': [user1, user2],
        'createdAt': FieldValue.serverTimestamp(),
        'lastMessage': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
      });
    }
  }

  /// Send a message
  Future<void> sendMessage({
    required String currentUserName,
    required String friendName,
    required String messageText,
  }) async {
    final chatId = _generateChatId(currentUserName, friendName);
    final userId = _getCurrentUserId();

    // Ensure chat exists
    await _ensureChatExists(chatId, currentUserName, friendName);

    // Add message to subcollection
    final messagesRef = _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages');

    await messagesRef.add({
      'sender': currentUserName,
      'senderId': userId,
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
    required String currentUserName,
    required String friendName,
  }) {
    // Check if this is a demo friend
    if (friendName == 'Sara Hameed' || 
        friendName == 'Fahad Saeed' || 
        friendName == 'Alina Tariq' ||
        friendName == 'Ali Ahmed' ||
        friendName == 'Zainab Hussain') {
      return Stream.value(_getDemoMessages(friendName));
    }
    
    final chatId = _generateChatId(currentUserName, friendName);

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
          text: data['text'] ?? '',
          timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
          read: data['read'] ?? false,
        );
      }).toList();
    });
  }
  
  // Demo messages for demo friends
  List<ChatMessage> _getDemoMessages(String friendName) {
    final now = DateTime.now();
    
    if (friendName == 'Sara Hameed') {
      return [
        ChatMessage(
          id: 'demo1',
          sender: 'Sara Hameed',
          text: 'Hey! Want to study together for the CS quiz?',
          timestamp: now.subtract(const Duration(hours: 2)),
          read: false,
        ),
      ];
    } else if (friendName == 'Fahad Saeed') {
      return [
        ChatMessage(
          id: 'demo2',
          sender: 'Fahad Saeed',
          text: 'Did you complete today\'s quiz yet?',
          timestamp: now.subtract(const Duration(hours: 5)),
          read: false,
        ),
      ];
    } else if (friendName == 'Alina Tariq') {
      return [
        ChatMessage(
          id: 'demo3',
          sender: 'Alina Tariq',
          text: 'Can you help me with the Biology questions?',
          timestamp: now.subtract(const Duration(hours: 3)),
          read: false,
        ),
      ];
    } else if (friendName == 'Ali Ahmed') {
      return [
        ChatMessage(
          id: 'demo4',
          sender: 'Ali Ahmed',
          text: 'Let\'s compete on the leaderboard this week',
          timestamp: now.subtract(const Duration(hours: 6)),
          read: false,
        ),
      ];
    } else if (friendName == 'Zainab Hussain') {
      return [
        ChatMessage(
          id: 'demo5',
          sender: 'Zainab Hussain',
          text: 'Are you free to study Pakistan Studies together?',
          timestamp: now.subtract(const Duration(hours: 4)),
          read: false,
        ),
      ];
    }
    
    return [];
  }

  /// Mark messages as read
  Future<void> markMessagesAsRead({
    required String currentUserName,
    required String friendName,
    required String messageId,
  }) async {
    final chatId = _generateChatId(currentUserName, friendName);

    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .update({'read': true});
  }

  /// Delete a message
  Future<void> deleteMessage({
    required String currentUserName,
    required String friendName,
    required String messageId,
  }) async {
    final chatId = _generateChatId(currentUserName, friendName);

    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .delete();
  }

  /// Get unread message count
  Future<int> getUnreadCount({
    required String currentUserName,
    required String friendName,
  }) async {
    final chatId = _generateChatId(currentUserName, friendName);

    final snapshot = await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .where('sender', isNotEqualTo: currentUserName)
        .where('read', isEqualTo: false)
        .get();

    return snapshot.docs.length;
  }

  /// Set typing status
  Future<void> setTypingStatus({
    required String currentUserName,
    required String friendName,
    required bool isTyping,
  }) async {
    final chatId = _generateChatId(currentUserName, friendName);

    await _firestore.collection('chats').doc(chatId).update({
      '${currentUserName}_typing': isTyping,
      '${currentUserName}_typingTime': FieldValue.serverTimestamp(),
    });
  }

  /// Get typing status stream
  Stream<bool> getTypingStatusStream({
    required String currentUserName,
    required String friendName,
  }) {
    final chatId = _generateChatId(currentUserName, friendName);

    return _firestore
        .collection('chats')
        .doc(chatId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) return false;
      final data = snapshot.data();
      if (data == null) return false;

      final isTyping = data['${friendName}_typing'] ?? false;
      final typingTime = data['${friendName}_typingTime'] as Timestamp?;

      // Only show typing if it was updated in last 5 seconds
      if (typingTime != null && isTyping) {
        final diff = DateTime.now().difference(typingTime.toDate());
        return diff.inSeconds < 5;
      }

      return false;
    });
  }
}

/// Chat Message Model
class ChatMessage {
  final String id;
  final String sender;
  final String text;
  final DateTime timestamp;
  final bool read;

  ChatMessage({
    required this.id,
    required this.sender,
    required this.text,
    required this.timestamp,
    this.read = false,
  });

  /// Check if message is from current user
  bool isFromUser(String currentUserName) => sender == currentUserName;
}
