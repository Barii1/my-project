import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isAuthenticated = false;
  String? _email;
  String? _fullName;
  String? _lastError;

  String? get lastError => _lastError;

  bool get isAuthenticated => _isAuthenticated;
  String? get email => _email;
  String? get fullName => _fullName;

  AuthProvider() {
<<<<<<< HEAD
    // Keep local state in sync with Firebase auth changes
=======
    // Keep local state in sync with Firebase auth
>>>>>>> c3a1561 (Merge remote main into local main)
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        _isAuthenticated = true;
        _email = user.email;
        _fullName = user.displayName;
      } else {
        _isAuthenticated = false;
        _email = null;
        _fullName = null;
      }
      notifyListeners();
    });
  }
<<<<<<< HEAD
  
  /// LOGIN with Firebase Auth
  /// Returns true on success, false on failure.
  Future<bool> login(String email, String password) async {
    debugPrint('AuthProvider.login called for email: $email');
=======

  // LOGIN with Firebase Auth
  Future<bool> login(String email, String password) async {
>>>>>>> c3a1561 (Merge remote main into local main)
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
<<<<<<< HEAD
        _lastError = null;
        debugPrint('AuthProvider.login success uid=${user.uid}, email=${user.email}');
        notifyListeners();
        return true;
      } else {
        _lastError = 'No user returned from signInWithEmailAndPassword';
        debugPrint('AuthProvider.login: no user returned');
        return false;
      }
    } on FirebaseAuthException catch (e) {
      _lastError = '${e.code}: ${e.message}';
      debugPrint('🔥 FirebaseAuth login error: ${e.code} - ${e.message}');
      notifyListeners();
      return false;
    } catch (e) {
      _lastError = e.toString();
      debugPrint('🔥 Unknown login error: $e');
      notifyListeners();
=======
        notifyListeners();
        return true;
      } else {
        return false;
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('🔥 FirebaseAuth login error: ${e.code} - ${e.message}');
      return false;
    } catch (e) {
      debugPrint('🔥 Unknown login error: $e');
>>>>>>> c3a1561 (Merge remote main into local main)
      return false;
    }
  }

<<<<<<< HEAD
  /// CREATE ACCOUNT with Firebase Auth
  /// Returns true on success, false on failure.
  Future<bool> createAccount(String fullName, String email, String password) async {
    debugPrint('AuthProvider.createAccount called for email: $email, name: $fullName');
=======
  // CREATE ACCOUNT in Firebase Auth
  Future<bool> createAccount(String fullName, String email, String password) async {
>>>>>>> c3a1561 (Merge remote main into local main)
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = cred.user;

      if (user != null) {
<<<<<<< HEAD
        // Set display name
=======
        // Set display name in Firebase
>>>>>>> c3a1561 (Merge remote main into local main)
        await user.updateDisplayName(fullName);
        await user.reload();
        final refreshed = _auth.currentUser;

        _isAuthenticated = true;
        _email = refreshed?.email ?? email;
        _fullName = refreshed?.displayName ?? fullName;
<<<<<<< HEAD
        _lastError = null;

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
      debugPrint('🔥 FirebaseAuth createAccount error: ${e.code} - ${e.message}');
      notifyListeners();
      return false;
    } catch (e) {
      _lastError = e.toString();
      debugPrint('🔥 Unknown createAccount error: $e');
      notifyListeners();
=======

        notifyListeners();
        return true;
      } else {
        return false;
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('🔥 FirebaseAuth createAccount error: ${e.code} - ${e.message}');
      return false;
    } catch (e) {
      debugPrint('🔥 Unknown createAccount error: $e');
>>>>>>> c3a1561 (Merge remote main into local main)
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
<<<<<<< HEAD
      debugPrint('🔥 Sign out failed: $e');
      _lastError = e.toString();
    } finally {
      _isAuthenticated = false;
      _email = null;
      _fullName = null;
      notifyListeners();
    }
=======
      debugPrint('🔥 Error signing out: $e');
    }

    _isAuthenticated = false;
    _email = null;
    _fullName = null;
    notifyListeners();
>>>>>>> c3a1561 (Merge remote main into local main)
  }
}
