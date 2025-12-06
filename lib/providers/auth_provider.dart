import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/offline_storage_service.dart';
import '../services/database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isAuthenticated = false;
  String? _email;
  String? _fullName;
  String? _lastError;
  bool _isOfflineMode = false;

  String? get lastError => _lastError;
  bool get isAuthenticated => _isAuthenticated;
  String? get email => _email;
  String? get fullName => _fullName;
  bool get isOfflineMode => _isOfflineMode;

  AuthProvider() {
    // Check if user was logged in offline
    _checkOfflineAuth();
    
    // Keep local state in sync with Firebase auth changes
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        _isAuthenticated = true;
        _email = user.email;
        _fullName = user.displayName;
        _isOfflineMode = false;
        
        // Save credentials for offline use
        OfflineStorageService.saveUserCredentials({
          'email': user.email,
          'fullName': user.displayName,
          'uid': user.uid,
        });
      } else {
        // Only clear if not in offline mode
        if (!_isOfflineMode) {
          _isAuthenticated = false;
          _email = null;
          _fullName = null;
        }
      }
      notifyListeners();
    });
  }

  void _checkOfflineAuth() {
    if (OfflineStorageService.isUserLoggedIn()) {
      final user = OfflineStorageService.getUserCredentials();
      if (user != null) {
        _isAuthenticated = true;
        _email = user['email'];
        _fullName = user['fullName'];
        _isOfflineMode = true;
        notifyListeners();
      }
    }
  }

  /// LOGIN with Firebase Auth (or offline mode)
  /// Returns true on success, false on failure.
  Future<bool> login(String email, String password) async {
    debugPrint('AuthProvider.login called for email: $email');
    
    // ALWAYS try Firebase Auth first, even if offline
    // Only fall back to offline mode if network error occurs
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = cred.user;
      if (user != null) {
        _isAuthenticated = true;
        _email = user.email;
        _fullName = user.displayName;
        _lastError = null;
        _isOfflineMode = false;
        
        // Save for offline use
        await OfflineStorageService.saveUserCredentials({
          'email': user.email,
          'fullName': user.displayName,
          'uid': user.uid,
          'password_hash': password.hashCode.toString(), // Simple hash for offline verification
        });
        
        debugPrint('AuthProvider.login success uid=${user.uid}, email=${user.email}');
        notifyListeners();
        return true;
      } else {
        _lastError = 'No user returned from signInWithEmailAndPassword';
        debugPrint('AuthProvider.login: no user returned');
        return false;
      }
    } on FirebaseAuthException catch (e) {
      // Only try offline login if it's a network error
      if (e.code == 'network-request-failed') {
        debugPrint('Network error detected, trying offline login...');
        return _loginOffline(email, password);
      }
      
      // Provide user-friendly error messages
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No account found with this email. Please create an account.';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password. Please try again.';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email format. Please check your email.';
          break;
        case 'user-disabled':
          errorMessage = 'This account has been disabled.';
          break;
        case 'invalid-credential':
          errorMessage = 'Invalid email or password. Please check your credentials and try again.';
          break;
        default:
          errorMessage = e.message ?? 'Login failed. Please try again.';
      }
      
      _lastError = errorMessage;
      debugPrint('FirebaseAuth login error: ${e.code} - ${e.message}');
      notifyListeners();
      return false;
    } catch (e) {
      _lastError = e.toString();
      debugPrint('Unknown login error: $e');
      notifyListeners();
      return false;
    }
  }

  Future<bool> _loginOffline(String email, String password) async {
    final user = OfflineStorageService.getUserCredentials();
    
    if (user != null && user['email'] == email) {
      // Verify password hash
      final savedHash = user['password_hash'];
      final currentHash = password.hashCode.toString();
      
      if (savedHash == currentHash) {
        _isAuthenticated = true;
        _email = user['email'];
        _fullName = user['fullName'];
        _lastError = null;
        _isOfflineMode = true;
        
        debugPrint('AuthProvider.login offline mode success for $email');
        notifyListeners();
        return true;
      } else {
        // Password hash mismatch - clear cache and require online login
        debugPrint('Password hash mismatch - clearing cached credentials');
        await OfflineStorageService.clearAuthCache();
        _lastError = 'Please connect to the internet to log in with new credentials';
        notifyListeners();
        return false;
      }
    }
    
    _lastError = 'No offline credentials available. Please connect to the internet to log in.';
    notifyListeners();
    return false;
  }

  /// CREATE ACCOUNT with Firebase Auth
  /// Returns true on success, false on failure.
  Future<bool> createAccount(
  String fullName,
  String email,
  String password,
  String phone,
) async {
    debugPrint('AuthProvider.createAccount called for email: $email, name: $fullName');
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = cred.user;

      if (user != null) {
        // Set display name
        await user.updateDisplayName(fullName);
        await user.reload();
        final refreshed = _auth.currentUser;

        _isAuthenticated = true;
        _email = refreshed?.email ?? email;
        _fullName = refreshed?.displayName ?? fullName;
        _lastError = null;

        // Save user data to Firestore with searchable name
        final userData = {
          'email': email,
          'fullName': fullName,
          'searchName': fullName.toLowerCase(), // For case-insensitive search
          'displayName': fullName,
          'provider': 'password',
          'isVerified': false,
          'phone': phone,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          // Initialize XP state for new users
          'xp': 0,
          'dailyXp': 0,
          'dailyAiXp': 0,
          'streakDays': 0,
          'quizCount': 0,
          'aiSessionsWeekCount': 0,
          'achievements': {},
        };
        await DatabaseService().saveUserData(
          userId: user.uid,
          userData: userData,
        );

        debugPrint('AuthProvider.createAccount success uid=${user.uid}, email=${user.email}');
        notifyListeners();
        return true;
      } else {
        _lastError = 'No user returned from createUserWithEmailAndPassword';
        debugPrint('AuthProvider.createAccount: no user returned');
        return false;
      }
    } on FirebaseAuthException catch (e) {
      _lastError = '${e.code}: ${e.message}';
      debugPrint(' FirebaseAuth createAccount error: ${e.code} - ${e.message}');
      notifyListeners();
      return false;
    } catch (e) {
      _lastError = e.toString();
      debugPrint(' Unknown createAccount error: $e');
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    try {
      if (!_isOfflineMode) {
        await _auth.signOut();
      }
      await OfflineStorageService.logout();
    } catch (e) {
      debugPrint('Sign out failed: $e');
      _lastError = e.toString();
    } finally {
      _isAuthenticated = false;
      _email = null;
      _fullName = null;
      _isOfflineMode = false;
      notifyListeners();
    }
  }

  Future<void> updateProfileImage(String uid, String url, String filePath) async {
    try {
      // Update user data in Firestore
      await DatabaseService().saveUserData(
        userId: uid,
        userData: {
          'photoUrl': url,
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );
      // Optionally also add a record:
      await DatabaseService().setDocument(
        collection: 'users/$uid/images',
        data: {
          'url': url,
          'createdAt': FieldValue.serverTimestamp(),
          'storagePath': filePath,
          'type': 'profile', // or 'post'
        },
      );
    } catch (e) {
      debugPrint('Error updating profile image: $e');
      _lastError = e.toString();
    } finally {
      notifyListeners();
    }
  }
}
