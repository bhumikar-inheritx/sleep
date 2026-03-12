import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String? _error;
  String? _userName;
  String? _userEmail;

  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get userName => _userName;
  String? get userEmail => _userEmail;

  bool get isAuthenticated => _authService.isLoggedIn();

  AuthProvider() {
    _checkInitialState();
  }

  void _checkInitialState() {
    if (_authService.isLoggedIn()) {
      _userEmail = _authService.getCurrentUserEmail();
      // In a real app, we'd fetch the name from elsewhere
      _userName = 'Dreamer'; 
    }
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _error = null;

    final user = await _authService.login(email: email, password: password);
    
    if (user != null) {
      _userName = user['name'];
      _userEmail = user['email'];
      _setLoading(false);
      notifyListeners();
      return true;
    } else {
      _error = 'Invalid email or password';
      _setLoading(false);
      return false;
    }
  }

  Future<bool> signUp(String name, String email, String password) async {
    _setLoading(true);
    _error = null;

    final success = await _authService.signUp(name: name, email: email, password: password);
    
    if (success) {
      // Auto-login after signup
      return await login(email, password);
    } else {
      _error = 'Something went wrong. Please try again.';
      _setLoading(false);
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _userName = null;
    _userEmail = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
