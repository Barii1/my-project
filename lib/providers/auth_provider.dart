import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/offline_storage_service.dart';
import '../services/connectivity_service.dart';
import '../services/database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  ConnectivityService? _connectivityService;

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

  void setConnectivityService(ConnectivityService service) {
    _connectivityService = service;
  }

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
    
    // Check if offline
    final isOffline = _connectivityService?.isOffline ?? false;
    
    if (isOffline) {
      // Offline login - check cached credentials
      return _loginOffline(email, password);
    }
    
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
      // If offline, try offline login as fallback
      if (e.code == 'network-request-failed') {
        return _loginOffline(email, password);
      }
      _lastError = '${e.code}: ${e.message}';
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
      }
    }
    
    _lastError = 'Invalid credentials or no offline data available';
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

        // Save user data to Firestore
        final userData = {
          'email': email,
          'fullName': fullName,
          'displayName': fullName,
          'provider': 'password',
          'isVerified': false,
          'phone': phone,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
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
