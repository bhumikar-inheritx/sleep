import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String? _error;
  StreamSubscription<User?>? _authSub;

  bool get isLoading => _isLoading;
  String? get error => _error;

  /// True when a Firebase user is currently signed in.
  bool get isAuthenticated => _authService.currentUser != null;

  /// Display name of the current user.
  String? get userName =>
      _authService.currentUser?.displayName ?? 'Dreamer';

  /// Email of the current user.
  String? get userEmail => _authService.currentUser?.email;

  /// The raw Firebase [User] object.
  User? get currentUser => _authService.currentUser;

  AuthProvider() {
    // Listen for auth state changes so the UI rebuilds reactively.
    _authSub = _authService.authStateChanges.listen((_) {
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Email & Password
  // ---------------------------------------------------------------------------

  /// Sign up with email and password. Returns `true` on success.
  Future<bool> signUp(String name, String email, String password) async {
    _setLoading(true);
    _error = null;

    try {
      await _authService.signUpWithEmail(
        email: email,
        password: password,
        displayName: name,
      );
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _error = AuthService.getFirebaseErrorMessage(e.code);
      _setLoading(false);
      return false;
    } catch (e) {
      _error = 'Something went wrong. Please try again.';
      _setLoading(false);
      return false;
    }
  }

  /// Log in with email and password. Returns `true` on success.
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _error = null;

    try {
      await _authService.signInWithEmail(
        email: email,
        password: password,
      );
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _error = AuthService.getFirebaseErrorMessage(e.code);
      _setLoading(false);
      return false;
    } catch (e) {
      _error = 'Something went wrong. Please try again.';
      _setLoading(false);
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Google Sign-In
  // ---------------------------------------------------------------------------

  /// Sign in with Google. Returns `true` on success, `false` if cancelled or
  /// failed.
  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _error = null;

    try {
      final credential = await _authService.signInWithGoogle();
      _setLoading(false);

      if (credential == null) {
        // User cancelled the Google sign-in picker.
        return false;
      }
      return true;
    } on FirebaseAuthException catch (e) {
      _error = AuthService.getFirebaseErrorMessage(e.code);
      _setLoading(false);
      return false;
    } catch (e) {
      _error = 'Google Sign-In failed. Please try again.';
      _setLoading(false);
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Forgot Password
  // ---------------------------------------------------------------------------

  /// Send a password-reset email. Returns `true` on success.
  Future<bool> forgotPassword(String email) async {
    _setLoading(true);
    _error = null;

    try {
      await _authService.sendPasswordReset(email: email);
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _error = AuthService.getFirebaseErrorMessage(e.code);
      _setLoading(false);
      return false;
    } catch (e) {
      _error = 'Could not send reset email. Please try again.';
      _setLoading(false);
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Sign Out
  // ---------------------------------------------------------------------------

  /// Sign out from Firebase (and Google if applicable).
  Future<void> logout() async {
    await _authService.signOut();
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
