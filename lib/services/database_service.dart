import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Database service for Firestore operations
/// This service provides methods to interact with Firebase Firestore database
class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  /// Get a reference to a collection
  CollectionReference getCollection(String collectionName) {
    return _firestore.collection(collectionName);
  }

  /// Get a reference to a document
  DocumentReference getDocument(String collectionName, String documentId) {
    return _firestore.collection(collectionName).doc(documentId);
  }

  /// Create or update a document
  /// Returns the document ID
  Future<String> setDocument({
    required String collection,
    String? documentId,
    required Map<String, dynamic> data,
  }) async {
    try {
      final docRef = documentId != null
          ? _firestore.collection(collection).doc(documentId)
          : _firestore.collection(collection).doc();

      await docRef.set(data, SetOptions(merge: true));
      return docRef.id;
    } catch (e) {
      throw Exception('Error setting document: $e');
    }
  }

  /// Get a single document
  Future<DocumentSnapshot> getDocumentData({
    required String collection,
    required String documentId,
  }) async {
    try {
      return await _firestore.collection(collection).doc(documentId).get();
    } catch (e) {
      throw Exception('Error getting document: $e');
    }
  }

  /// Get all documents from a collection
  Future<QuerySnapshot> getCollectionData({
    required String collection,
    String? orderBy,
    bool descending = false,
    int? limit,
  }) async {
    try {
      Query query = _firestore.collection(collection);

      if (orderBy != null) {
        query = query.orderBy(orderBy, descending: descending);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      return await query.get();
    } catch (e) {
      throw Exception('Error getting collection: $e');
    }
  }

  /// Stream a single document (real-time updates)
  Stream<DocumentSnapshot> streamDocument({
    required String collection,
    required String documentId,
  }) {
    return _firestore.collection(collection).doc(documentId).snapshots();
  }

  /// Stream a collection (real-time updates)
  Stream<QuerySnapshot> streamCollection({
    required String collection,
    String? whereField,
    dynamic whereValue,
    String? whereOperator, // '==', '!=', '<', '<=', '>', '>=', 'array-contains', etc.
    String? orderBy,
    bool descending = false,
    int? limit,
  }) {
    Query query = _firestore.collection(collection);

    if (whereField != null) {
      if (whereOperator == null || whereOperator == '==') {
        query = query.where(whereField, isEqualTo: whereValue);
      } else {
        switch (whereOperator) {
          case '!=':
            query = query.where(whereField, isNotEqualTo: whereValue);
            break;
          case '<':
            query = query.where(whereField, isLessThan: whereValue);
            break;
          case '<=':
            query = query.where(whereField, isLessThanOrEqualTo: whereValue);
            break;
          case '>':
            query = query.where(whereField, isGreaterThan: whereValue);
            break;
          case '>=':
            query = query.where(whereField, isGreaterThanOrEqualTo: whereValue);
            break;
          case 'array-contains':
            query = query.where(whereField, arrayContains: whereValue);
            break;
          default:
            query = query.where(whereField, isEqualTo: whereValue);
        }
      }
    }

    if (orderBy != null) {
      query = query.orderBy(orderBy, descending: descending);
    }

    if (limit != null) {
      query = query.limit(limit);
    }

    return query.snapshots();
  }

  /// Update a document
  Future<void> updateDocument({
    required String collection,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _firestore.collection(collection).doc(documentId).update(data);
    } catch (e) {
      throw Exception('Error updating document: $e');
    }
  }

  /// Delete a document
  Future<void> deleteDocument({
    required String collection,
    required String documentId,
  }) async {
    try {
      await _firestore.collection(collection).doc(documentId).delete();
    } catch (e) {
      throw Exception('Error deleting document: $e');
    }
  }

  /// Query documents with where clause
  Future<QuerySnapshot> queryDocuments({
    required String collection,
    required String field,
    required dynamic value,
    String? operator, // '==', '!=', '<', '<=', '>', '>=', 'array-contains', etc.
    String? orderBy,
    bool descending = false,
    int? limit,
  }) async {
    try {
      Query query = _firestore.collection(collection);

      if (operator == null || operator == '==') {
        query = query.where(field, isEqualTo: value);
      } else {
        switch (operator) {
          case '!=':
            query = query.where(field, isNotEqualTo: value);
            break;
          case '<':
            query = query.where(field, isLessThan: value);
            break;
          case '<=':
            query = query.where(field, isLessThanOrEqualTo: value);
            break;
          case '>':
            query = query.where(field, isGreaterThan: value);
            break;
          case '>=':
            query = query.where(field, isGreaterThanOrEqualTo: value);
            break;
          case 'array-contains':
            query = query.where(field, arrayContains: value);
            break;
          default:
            query = query.where(field, isEqualTo: value);
        }
      }

      if (orderBy != null) {
        query = query.orderBy(orderBy, descending: descending);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      return await query.get();
    } catch (e) {
      throw Exception('Error querying documents: $e');
    }
  }

  // ========== User-specific helper methods ==========

  /// Save user data to Firestore
  Future<void> saveUserData({
    required String userId,
    required Map<String, dynamic> userData,
  }) async {
    await setDocument(
      collection: 'users',
      documentId: userId,
      data: {
        ...userData,
        'updatedAt': FieldValue.serverTimestamp(),
      },
    );
  }

  /// Get user data from Firestore
  Future<DocumentSnapshot> getUserData(String userId) async {
    return await getDocumentData(collection: 'users', documentId: userId);
  }

  /// Stream user data (real-time updates)
  Stream<DocumentSnapshot> streamUserData(String userId) {
    return streamDocument(collection: 'users', documentId: userId);
  }
}

