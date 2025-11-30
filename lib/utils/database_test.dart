import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/database_service.dart';

/// Utility class to test and verify Firestore database connection
class DatabaseTest {
  final DatabaseService _db = DatabaseService();

  /// Test basic Firestore connection by writing and reading a test document
  /// Returns true if successful, false otherwise
  Future<bool> testConnection() async {
    try {
      print('🔍 Testing Firestore connection...');

      // Test 1: Check if Firebase is initialized
      // Touch the instance to avoid unused local warning
      FirebaseFirestore.instance;
      print('✅ Firebase Firestore available');

      // Test 2: Write a test document
      final testDocId = 'test_${DateTime.now().millisecondsSinceEpoch}';
      await _db.setDocument(
        collection: 'connection_test',
        documentId: testDocId,
        data: {
          'test': true,
          'timestamp': FieldValue.serverTimestamp(),
          'message': 'Database connection test',
        },
      );
      print('✅ Test document written successfully');

      // Test 3: Read the test document back
      final doc = await _db.getDocumentData(
        collection: 'connection_test',
        documentId: testDocId,
      );

      if (doc.exists) {
        print('✅ Test document read successfully');
        print('   Document data: ${doc.data()}');

        // Test 4: Delete the test document
        await _db.deleteDocument(
          collection: 'connection_test',
          documentId: testDocId,
        );
        print('✅ Test document deleted successfully');

        print('🎉 All database tests passed! Database is working correctly.');
        return true;
      } else {
        print('❌ Test document not found after writing');
        return false;
      }
    } catch (e) {
      print('❌ Database test failed: $e');
      print('\n💡 Troubleshooting tips:');
      print('   1. Make sure Firestore is enabled in Firebase Console');
      print('   2. Check your internet connection');
      print('   3. Verify Firebase initialization in main.dart');
      print('   4. Check Firestore security rules allow read/write');
      return false;
    }
  }

  /// Test real-time streaming connection
  Future<bool> testStreaming() async {
    try {
      print('🔍 Testing Firestore streaming...');

      final testDocId = 'stream_test_${DateTime.now().millisecondsSinceEpoch}';
      
      // Create a stream listener
      bool streamReceived = false;
      final subscription = _db.streamDocument(
        collection: 'connection_test',
        documentId: testDocId,
      ).listen(
        (snapshot) {
          if (snapshot.exists) {
            print('✅ Stream update received: ${snapshot.data()}');
            streamReceived = true;
          }
        },
        onError: (error) {
          print('❌ Stream error: $error');
        },
      );

      // Write a document to trigger the stream
      await Future.delayed(Duration(milliseconds: 500));
      await _db.setDocument(
        collection: 'connection_test',
        documentId: testDocId,
        data: {
          'test': true,
          'timestamp': FieldValue.serverTimestamp(),
        },
      );

      // Wait for stream to receive update
      await Future.delayed(Duration(seconds: 2));

      // Cleanup
      await subscription.cancel();
      await _db.deleteDocument(
        collection: 'connection_test',
        documentId: testDocId,
      );

      if (streamReceived) {
        print('✅ Streaming test passed!');
        return true;
      } else {
        print('❌ Stream did not receive update');
        return false;
      }
    } catch (e) {
      print('❌ Streaming test failed: $e');
      return false;
    }
  }

  /// Test user-specific operations (requires authentication)
  Future<bool> testUserOperations() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      
      if (user == null) {
        print('⚠️  No user logged in. Skipping user operations test.');
        print('   (This is normal if you haven\'t logged in yet)');
        return true; // Not a failure, just skip
      }

      print('🔍 Testing user-specific operations...');
      print('   User ID: ${user.uid}');

      // Test saving user data
      await _db.saveUserData(
        userId: user.uid,
        userData: {
          'email': user.email,
          'displayName': user.displayName ?? 'Test User',
          'lastTested': FieldValue.serverTimestamp(),
        },
      );
      print('✅ User data saved successfully');

      // Test reading user data
      final userDoc = await _db.getUserData(user.uid);
      if (userDoc.exists) {
        print('✅ User data retrieved successfully');
        print('   User data: ${userDoc.data()}');
        return true;
      } else {
        print('❌ User data not found');
        return false;
      }
    } catch (e) {
      print('❌ User operations test failed: $e');
      return false;
    }
  }

  /// Run all database tests
  Future<Map<String, bool>> runAllTests() async {
    print('\n${'=' * 50}');
    print('🧪 Starting Database Connection Tests');
    print('=' * 50 + '\n');

    final results = <String, bool>{};

    results['Basic Connection'] = await testConnection();
    print('');

    results['Streaming'] = await testStreaming();
    print('');

    results['User Operations'] = await testUserOperations();
    print('');

    // Summary
    print('\n${'=' * 50}');
    print('📊 Test Results Summary');
    print('=' * 50);
    results.forEach((test, passed) {
      final icon = passed ? '✅' : '❌';
      print('$icon $test: ${passed ? "PASSED" : "FAILED"}');
    });

    final allPassed = results.values.every((passed) => passed);
    if (allPassed) {
      print('\n🎉 All tests passed! Your database is working correctly.');
    } else {
      print('\n⚠️  Some tests failed. Check the errors above.');
    }
    print('=' * 50 + '\n');

    return results;
  }
}

