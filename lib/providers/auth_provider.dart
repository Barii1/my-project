import 'package:flutter/foundation.dart';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  String? _email;
  String? _fullName;

  bool get isAuthenticated => _isAuthenticated;
  String? get email => _email;
  String? get fullName => _fullName;

  Future<bool> login(String email, String password) async {
    // TODO: Implement actual authentication
    _isAuthenticated = true;
    _email = email;
    notifyListeners();
    return true;
  }

  Future<bool> createAccount(String fullName, String email, String password) async {
    // TODO: Implement actual account creation
    _isAuthenticated = true;
    _email = email;
    _fullName = fullName;
    notifyListeners();
    return true;
  }

  void logout() {
    _isAuthenticated = false;
    _email = null;
    _fullName = null;
    notifyListeners();
  }
}