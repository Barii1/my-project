# Database Connection Test Guide

## Quick Test Methods

### Method 1: Using the Test Screen (Recommended)

1. **Navigate to the test screen** in your app:
   ```dart
   Navigator.pushNamed(context, '/database-test');
   ```
   
   Or add a button in your settings/profile screen:
   ```dart
   ListTile(
     leading: Icon(Icons.storage),
     title: Text('Test Database Connection'),
     onTap: () => Navigator.pushNamed(context, '/database-test'),
   )
   ```

2. **Click "Run Database Tests"** button
3. **Check the results** - you'll see:
   - ✅ Basic Connection Test
   - ✅ Streaming Test  
   - ✅ User Operations Test

### Method 2: Using the Test Utility in Code

Add this to any screen or provider to test programmatically:

```dart
import 'package:flutter/material.dart';
import '../utils/database_test.dart';

// In your widget or provider
final databaseTest = DatabaseTest();

// Run all tests
final results = await databaseTest.runAllTests();

// Or run individual tests
final connectionOk = await databaseTest.testConnection();
final streamingOk = await databaseTest.testStreaming();
final userOpsOk = await databaseTest.testUserOperations();
```

### Method 3: Quick Console Test

Add this to your `main.dart` temporarily:

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Quick test
  final test = DatabaseTest();
  await test.runAllTests();
  
  // ... rest of your code
}
```

## What the Tests Check

1. **Basic Connection Test**
   - ✅ Creates a test document in Firestore
   - ✅ Reads it back
   - ✅ Deletes it
   - Verifies basic read/write operations work

2. **Streaming Test**
   - ✅ Tests real-time document updates
   - ✅ Verifies stream listeners work
   - Checks if you can receive live updates

3. **User Operations Test**
   - ✅ Tests saving user data
   - ✅ Tests retrieving user data
   - Only runs if a user is logged in

## Troubleshooting

### If tests fail:

1. **Check Firestore is enabled:**
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Select your project: `ostaad-88d1f`
   - Navigate to "Firestore Database"
   - If you see "Create database", click it and choose:
     - Start in **test mode** (for development)
     - Choose a location (closest to your users)

2. **Check Security Rules:**
   - In Firestore Database → Rules tab
   - For testing, you can use:
     ```javascript
     rules_version = '2';
     service cloud.firestore {
       match /databases/{database}/documents {
         match /{document=**} {
           allow read, write: if request.time < timestamp.date(2025, 12, 31);
         }
       }
     }
     ```
   - ⚠️ **Warning:** This allows anyone to read/write. Only use for testing!

3. **Check Internet Connection:**
   - Make sure your device/emulator has internet access
   - Try accessing Firebase Console in a browser

4. **Check Firebase Initialization:**
   - Verify `Firebase.initializeApp()` is called in `main.dart`
   - Check that `firebase_options.dart` has correct project ID

5. **Check Console Logs:**
   - Look for error messages in your debug console
   - The test utility prints detailed error messages

## Expected Output (Success)

When tests pass, you should see:

```
==================================================
🧪 Starting Database Connection Tests
==================================================

🔍 Testing Firestore connection...
✅ Firebase Firestore instance created
✅ Test document written successfully
✅ Test document read successfully
   Document data: {test: true, timestamp: ..., message: Database connection test}
✅ Test document deleted successfully
🎉 All database tests passed! Database is working correctly.

🔍 Testing Firestore streaming...
✅ Stream update received: {test: true, timestamp: ...}
✅ Streaming test passed!

🔍 Testing user-specific operations...
   User ID: abc123...
✅ User data saved successfully
✅ User data retrieved successfully
   User data: {email: ..., displayName: ..., ...}

==================================================
📊 Test Results Summary
==================================================
✅ Basic Connection: PASSED
✅ Streaming: PASSED
✅ User Operations: PASSED

🎉 All tests passed! Your database is working correctly.
==================================================
```

## Next Steps

Once tests pass:

1. ✅ Your database is connected and working
2. ✅ You can start using `DatabaseService` in your providers
3. ✅ Real-time updates will work
4. ✅ User data can be saved/retrieved

## Using the Database in Your App

Now you can use the database service anywhere:

```dart
import '../services/database_service.dart';

final db = DatabaseService();

// Save data
await db.setDocument(
  collection: 'users',
  documentId: userId,
  data: {'name': 'John', 'email': 'john@example.com'},
);

// Get data
final doc = await db.getDocumentData(
  collection: 'users',
  documentId: userId,
);
```

