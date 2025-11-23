/// Example usage of DatabaseService
/// 
/// This file demonstrates how to use the DatabaseService in your app.
/// You can delete this file once you understand how to use the service.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'database_service.dart';

class DatabaseServiceExample {
  final DatabaseService _db = DatabaseService();

  // Example 1: Save user data after registration
  Future<void> saveUserAfterRegistration({
    required String userId,
    required String email,
    required String fullName,
  }) async {
    await _db.saveUserData(
      userId: userId,
      userData: {
        'email': email,
        'fullName': fullName,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
    );
  }

  // Example 2: Get user data
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final doc = await _db.getUserData(userId);
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  // Example 3: Stream user data (real-time updates)
  Stream<DocumentSnapshot> watchUserProfile(String userId) {
    return _db.streamUserData(userId);
  }

  // Example 4: Save flashcards to Firestore
  Future<void> saveFlashcard({
    required String userId,
    required String front,
    required String back,
  }) async {
    await _db.setDocument(
      collection: 'flashcards',
      data: {
        'userId': userId,
        'front': front,
        'back': back,
        'createdAt': FieldValue.serverTimestamp(),
      },
    );
  }

  // Example 5: Get all flashcards for a user
  Future<List<Map<String, dynamic>>> getUserFlashcards(String userId) async {
    try {
      final querySnapshot = await _db.queryDocuments(
        collection: 'flashcards',
        field: 'userId',
        value: userId,
      );

      return querySnapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              })
          .toList();
    } catch (e) {
      print('Error getting flashcards: $e');
      return [];
    }
  }

  // Example 6: Stream flashcards (real-time updates)
  Stream<QuerySnapshot> watchUserFlashcards(String userId) {
    return _db.streamCollection(
      collection: 'flashcards',
      orderBy: 'createdAt',
      descending: true,
    );
  }

  // Example 7: Update a document
  Future<void> updateFlashcard({
    required String flashcardId,
    required Map<String, dynamic> updates,
  }) async {
    await _db.updateDocument(
      collection: 'flashcards',
      documentId: flashcardId,
      data: {
        ...updates,
        'updatedAt': FieldValue.serverTimestamp(),
      },
    );
  }

  // Example 8: Delete a document
  Future<void> deleteFlashcard(String flashcardId) async {
    await _db.deleteDocument(
      collection: 'flashcards',
      documentId: flashcardId,
    );
  }

  // Example 9: Query with multiple conditions
  Future<List<Map<String, dynamic>>> getRecentFlashcards(
    String userId,
    int daysAgo,
  ) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: daysAgo));

      final querySnapshot = await _db.queryDocuments(
        collection: 'flashcards',
        field: 'userId',
        value: userId,
        orderBy: 'createdAt',
        descending: true,
        limit: 10,
      );

      return querySnapshot.docs
          .where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
            return createdAt != null && createdAt.isAfter(cutoffDate);
          })
          .map((doc) => {
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              })
          .toList();
    } catch (e) {
      print('Error getting recent flashcards: $e');
      return [];
    }
  }
}

