import 'package:flutter/foundation.dart';

import './storage_service.dart';

/// A mock authentication service that uses SharedPreferences for persistence.
class AuthService {
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyUserPrefix = 'user_';
  static const String _keyCurrentUser = 'current_user_email';

  /// Register a new user locally.
  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // Save user details: user_email -> name|password
      // Save user details: user_email -> name|password
      await StorageService.setString(
        '${_keyUserPrefix}$email',
        '$name|$password',
      );
      return true;
    } catch (e) {
      debugPrint('SignUp Error: $e');
      return false;
    }
  }

  /// Authenticate a user.
  Future<Map<String, String>?> login({
    required String email,
    required String password,
  }) async {
    try {
      await Future.delayed(const Duration(seconds: 1));

      final userData = StorageService.getString('${_keyUserPrefix}$email');
      if (userData != null) {
        final parts = userData.split('|');
        if (parts.length == 2 && parts[1] == password) {
          await StorageService.setBool(_keyIsLoggedIn, true);
          await StorageService.setString(_keyCurrentUser, email);
          return {'name': parts[0], 'email': email};
        }
      }
      return null;
    } catch (e) {
      debugPrint('Login Error: $e');
      return null;
    }
  }

  /// Clear session.
  Future<void> logout() async {
    await StorageService.setBool(_keyIsLoggedIn, false);
    await StorageService.setString(_keyCurrentUser, '');
  }

  /// Check if user is already logged in.
  bool isLoggedIn() {
    return StorageService.getBool(_keyIsLoggedIn);
  }

  /// Get current user email.
  String? getCurrentUserEmail() {
    return StorageService.getString(_keyCurrentUser);
  }
}
