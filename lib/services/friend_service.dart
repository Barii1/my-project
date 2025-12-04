import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Friend Service - Manages friend requests and relationships in Firestore
/// 
/// FIRESTORE STRUCTURE:
/// /users/{userId}
///   - email: String
///   - fullName: String
///   - searchName: String (lowercase for case-insensitive search)
///   - createdAt: Timestamp
/// 
/// /users/{userId}/friends/{friendId}
///   - friendName: String
///   - addedAt: Timestamp
/// 
/// /users/{userId}/friendRequests/sent/{requestId}
///   - toUserId: String
///   - toUserName: String
///   - status: String (pending, accepted, rejected)
///   - sentAt: Timestamp
/// 
/// /users/{userId}/friendRequests/received/{requestId}
///   - fromUserId: String
///   - fromUserName: String
///   - status: String (pending, accepted, rejected)
///   - receivedAt: Timestamp
class FriendService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _currentUserId => _auth.currentUser?.uid;

  /// Search for users by name (case-insensitive)
  /// Returns list of users matching the query
  Future<List<UserSearchResult>> searchUsers(String query) async {
    print('🔍 FriendService.searchUsers called with query: "$query"');
    
    if (query.trim().isEmpty) {
      print('⚠️ Query is empty, returning empty list');
      return [];
    }
    
    final currentUserId = _currentUserId;
    if (currentUserId == null) {
      print('❌ No current user ID, user not authenticated');
      return [];
    }
    
    print('✅ Current user ID: $currentUserId');

    try {
      final lowercaseQuery = query.toLowerCase();
      print('🔎 Searching with lowercase query: "$lowercaseQuery"');
      
      // First try with searchName field (for new users)
      print('📡 Querying Firestore with searchName field...');
      var snapshot = await _firestore
          .collection('users')
          .where('searchName', isGreaterThanOrEqualTo: lowercaseQuery)
          .where('searchName', isLessThanOrEqualTo: '$lowercaseQuery\uf8ff')
          .limit(20)
          .get();

      print('📊 Firestore searchName query returned ${snapshot.docs.length} documents');

      final results = <UserSearchResult>[];
      
      // If no results, try searching all users and filter client-side
      if (snapshot.docs.isEmpty) {
        print('⚠️ No users found with searchName, trying fullName search...');
        print('📡 Fetching all users from Firestore...');
        
        snapshot = await _firestore.collection('users').limit(50).get();
        print('📊 Firestore returned ${snapshot.docs.length} total users');
        
        for (var doc in snapshot.docs) {
          if (doc.id == currentUserId) {
            print('  ⏭️ Skipping current user: ${doc.id}');
            continue;
          }
          
          final data = doc.data();
          final fullName = data['fullName'] ?? '';
          print('  📄 Checking user: $fullName (hasSearchName: ${data.containsKey("searchName")})');
          
          // Client-side case-insensitive search
          if (fullName.toLowerCase().contains(lowercaseQuery)) {
            print('  ✅ MATCH found: $fullName');
            results.add(UserSearchResult(
              userId: doc.id,
              fullName: fullName,
              email: data['email'] ?? '',
            ));
            
            // Auto-add searchName field for future searches
            print('  🔧 Auto-adding searchName field to user ${doc.id}');
            _firestore.collection('users').doc(doc.id).update({
              'searchName': fullName.toLowerCase(),
            }).catchError((e) {
              print('  ❌ Error updating searchName: $e');
              return null;
            });
          } else {
            print('  ❌ No match: "$fullName" does not contain "$lowercaseQuery"');
          }
        }
      } else {
        print('✅ Processing ${snapshot.docs.length} results from searchName query');
        // Process results from searchName query
        for (var doc in snapshot.docs) {
          if (doc.id == currentUserId) {
            print('  ⏭️ Skipping current user: ${doc.id}');
            continue;
          }
          
          final data = doc.data();
          final fullName = data['fullName'] ?? '';
          print('  ✅ Found: $fullName (${data["email"]})');
          
          results.add(UserSearchResult(
            userId: doc.id,
            fullName: fullName,
            email: data['email'] ?? '',
          ));
        }
      }

      print('🎯 Final results: ${results.length} users found');
      for (var user in results) {
        print('  - ${user.fullName} (${user.email})');
      }
      
      return results;
    } catch (e, stackTrace) {
      print('❌ Error searching users: $e');
      print('📜 Stack trace: $stackTrace');
      return [];
    }
  }

  /// Get all users from Firestore (for testing/debugging)
  Future<List<UserSearchResult>> getAllUsers() async {
    print('📋 FriendService.getAllUsers called');
    
    final currentUserId = _currentUserId;
    if (currentUserId == null) {
      print('❌ No current user ID');
      return [];
    }

    try {
      print('📡 Fetching all users from Firestore...');
      final snapshot = await _firestore.collection('users').limit(50).get();
      
      print('📊 Firestore returned ${snapshot.docs.length} documents');
      
      final results = <UserSearchResult>[];
      for (var doc in snapshot.docs) {
        if (doc.id == currentUserId) {
          print('  ⏭️ Skipping current user');
          continue;
        }
        
        final data = doc.data();
        final fullName = data['fullName'] ?? 'Unknown';
        final email = data['email'] ?? 'No email';
        
        print('  👤 Found user: $fullName ($email)');
        
        results.add(UserSearchResult(
          userId: doc.id,
          fullName: fullName,
          email: email,
        ));
      }
      
      print('✅ Total users retrieved: ${results.length}');
      return results;
    } catch (e, stackTrace) {
      print('❌ Error getting all users: $e');
      print('📜 Stack trace: $stackTrace');
      return [];
    }
  }

  /// Send a friend request to another user
  Future<bool> sendFriendRequest({
    required String toUserId,
    required String toUserName,
  }) async {
    final currentUserId = _currentUserId;
    final currentUserName = _auth.currentUser?.displayName ?? 'User';
    
    if (currentUserId == null) return false;
    if (currentUserId == toUserId) return false; // Can't friend yourself

    try {
      // Check if already friends
      final friendDoc = await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('friends')
          .doc(toUserId)
          .get();
      
      if (friendDoc.exists) {
        print('Already friends with this user');
        return false;
      }

      // Check if request already sent
      final existingRequest = await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('friendRequests')
          .doc('sent')
          .collection('requests')
          .doc(toUserId)
          .get();
      
      if (existingRequest.exists) {
        final status = existingRequest.data()?['status'];
        if (status == 'pending') {
          print('Friend request already sent');
          return false;
        }
      }

      final batch = _firestore.batch();
      
      // Add to sender's sent requests
      batch.set(
        _firestore
            .collection('users')
            .doc(currentUserId)
            .collection('friendRequests')
            .doc('sent')
            .collection('requests')
            .doc(toUserId),
        {
          'toUserId': toUserId,
          'toUserName': toUserName,
          'status': 'pending',
          'sentAt': FieldValue.serverTimestamp(),
        },
      );

      // Add to receiver's received requests
      batch.set(
        _firestore
            .collection('users')
            .doc(toUserId)
            .collection('friendRequests')
            .doc('received')
            .collection('requests')
            .doc(currentUserId),
        {
          'fromUserId': currentUserId,
          'fromUserName': currentUserName,
          'status': 'pending',
          'receivedAt': FieldValue.serverTimestamp(),
        },
      );

      await batch.commit();
      print('Friend request sent successfully');
      return true;
    } catch (e) {
      print('Error sending friend request: $e');
      return false;
    }
  }

  /// Accept a friend request
  Future<bool> acceptFriendRequest({
    required String fromUserId,
    required String fromUserName,
  }) async {
    final currentUserId = _currentUserId;
    final currentUserName = _auth.currentUser?.displayName ?? 'User';
    
    if (currentUserId == null) return false;

    try {
      final batch = _firestore.batch();

      // Add to both users' friends collections
      batch.set(
        _firestore
            .collection('users')
            .doc(currentUserId)
            .collection('friends')
            .doc(fromUserId),
        {
          'friendId': fromUserId,
          'friendName': fromUserName,
          'addedAt': FieldValue.serverTimestamp(),
        },
      );

      batch.set(
        _firestore
            .collection('users')
            .doc(fromUserId)
            .collection('friends')
            .doc(currentUserId),
        {
          'friendId': currentUserId,
          'friendName': currentUserName,
          'addedAt': FieldValue.serverTimestamp(),
        },
      );

      // Update request status to accepted
      batch.update(
        _firestore
            .collection('users')
            .doc(currentUserId)
            .collection('friendRequests')
            .doc('received')
            .collection('requests')
            .doc(fromUserId),
        {'status': 'accepted'},
      );

      batch.update(
        _firestore
            .collection('users')
            .doc(fromUserId)
            .collection('friendRequests')
            .doc('sent')
            .collection('requests')
            .doc(currentUserId),
        {'status': 'accepted'},
      );

      await batch.commit();
      print('Friend request accepted');
      return true;
    } catch (e) {
      print('Error accepting friend request: $e');
      return false;
    }
  }

  /// Reject a friend request
  Future<bool> rejectFriendRequest(String fromUserId) async {
    final currentUserId = _currentUserId;
    if (currentUserId == null) return false;

    try {
      final batch = _firestore.batch();

      // Update status to rejected
      batch.update(
        _firestore
            .collection('users')
            .doc(currentUserId)
            .collection('friendRequests')
            .doc('received')
            .collection('requests')
            .doc(fromUserId),
        {'status': 'rejected'},
      );

      batch.update(
        _firestore
            .collection('users')
            .doc(fromUserId)
            .collection('friendRequests')
            .doc('sent')
            .collection('requests')
            .doc(currentUserId),
        {'status': 'rejected'},
      );

      await batch.commit();
      return true;
    } catch (e) {
      print('Error rejecting friend request: $e');
      return false;
    }
  }

  /// Get pending friend requests (received)
  Stream<List<FriendRequest>> getPendingRequestsStream() {
    final currentUserId = _currentUserId;
    if (currentUserId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('friendRequests')
        .doc('received')
        .collection('requests')
        .where('status', isEqualTo: 'pending')
        .orderBy('receivedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return FriendRequest(
          requestId: doc.id,
          fromUserId: data['fromUserId'] ?? '',
          fromUserName: data['fromUserName'] ?? '',
          receivedAt: (data['receivedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
      }).toList();
    });
  }

  /// Get list of friends
  Stream<List<Friend>> getFriendsStream() {
    final currentUserId = _currentUserId;
    if (currentUserId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('friends')
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Friend(
          userId: doc.id,
          friendName: data['friendName'] ?? '',
          addedAt: (data['addedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
      }).toList();
    });
  }

  /// Check if a user is already a friend
  Future<bool> isFriend(String userId) async {
    final currentUserId = _currentUserId;
    if (currentUserId == null) return false;

    try {
      final doc = await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('friends')
          .doc(userId)
          .get();
      
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  /// Check if a friend request was already sent
  Future<String?> getRequestStatus(String toUserId) async {
    final currentUserId = _currentUserId;
    if (currentUserId == null) return null;

    try {
      final doc = await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('friendRequests')
          .doc('sent')
          .collection('requests')
          .doc(toUserId)
          .get();
      
      if (doc.exists) {
        return doc.data()?['status'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Remove a friend
  Future<bool> removeFriend(String friendId) async {
    final currentUserId = _currentUserId;
    if (currentUserId == null) return false;

    try {
      final batch = _firestore.batch();

      // Remove from both users' friends collections
      batch.delete(
        _firestore
            .collection('users')
            .doc(currentUserId)
            .collection('friends')
            .doc(friendId),
      );

      batch.delete(
        _firestore
            .collection('users')
            .doc(friendId)
            .collection('friends')
            .doc(currentUserId),
      );

      await batch.commit();
      return true;
    } catch (e) {
      print('Error removing friend: $e');
      return false;
    }
  }
}

/// User search result model
class UserSearchResult {
  final String userId;
  final String fullName;
  final String email;

  UserSearchResult({
    required this.userId,
    required this.fullName,
    required this.email,
  });
}

/// Friend request model
class FriendRequest {
  final String requestId;
  final String fromUserId;
  final String fromUserName;
  final DateTime receivedAt;

  FriendRequest({
    required this.requestId,
    required this.fromUserId,
    required this.fromUserName,
    required this.receivedAt,
  });
}

/// Friend model
class Friend {
  final String userId;
  final String friendName;
  final DateTime addedAt;

  Friend({
    required this.userId,
    required this.friendName,
    required this.addedAt,
  });
}
