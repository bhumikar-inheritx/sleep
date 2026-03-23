import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/routine.dart';
import '../models/user_profile.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  static const String _profileKey = 'user_profile';

  bool _isLoading = false;
  String? _error;
  StreamSubscription<User?>? _authSub;
  UserProfile? _profile;

  bool get isLoading => _isLoading;
  String? get error => _error;
  UserProfile? get profile => _profile;

  /// True when a Firebase user is currently signed in.
  bool get isAuthenticated => _authService.currentUser != null;

  /// Display name of the current user.
  String? get userName => _authService.currentUser?.displayName ?? 'Dreamer';

  /// Email of the current user.
  String? get userEmail => _authService.currentUser?.email;

  /// The raw Firebase [User] object.
  User? get currentUser => _authService.currentUser;

  AuthProvider() {
    _loadProfile();
    // Listen for auth state changes so the UI rebuilds reactively.
    _authSub = _authService.authStateChanges.listen((_) {
      _loadProfile();
      notifyListeners();
    });
  }

  void _loadProfile() {
    final profileJson = StorageService.getString(_profileKey);
    if (profileJson != null) {
      try {
        _profile = UserProfile.fromJson(jsonDecode(profileJson));
        _checkStreak();
        _ensureDefaultRoutine();
      } catch (e) {
        _profile = UserProfile(name: userName ?? 'Dreamer');
        _checkStreak();
        _ensureDefaultRoutine();
      }
    } else {
      _profile = UserProfile(name: userName ?? 'Dreamer');
      _checkStreak();
      _ensureDefaultRoutine();
    }
  }

  Future<void> _ensureDefaultRoutine() async {
    if (_profile == null || _profile!.windDownRoutine != null) return;

    final defaultRoutine = SleepRoutine(
      id: 'default_routine',
      name: 'Sleep Ritual',
      steps: [
        const RoutineStep(
          id: 'step_1',
          type: RoutineStepType.breathing,
          title: 'Calm Breathing',
          duration: Duration(minutes: 2),
        ),
        const RoutineStep(
          id: 'step_2',
          type: RoutineStepType.journal,
          title: 'Quick Reflect',
          duration: Duration(minutes: 3),
        ),
        const RoutineStep(
          id: 'step_3',
          type: RoutineStepType.soundscape,
          title: 'Night Ambience',
          duration: Duration(minutes: 10),
        ),
      ],
    );
    await updateProfile(_profile!.copyWith(windDownRoutine: defaultRoutine));
  }

  Future<void> _checkStreak() async {
    if (_profile == null) return;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (_profile!.lastActiveDate == null) {
      // First time active
      await updateProfile(
        _profile!.copyWith(streakDays: 1, lastActiveDate: today),
      );
      return;
    }

    final lastActive = _profile!.lastActiveDate!;
    final lastActiveDay = DateTime(
      lastActive.year,
      lastActive.month,
      lastActive.day,
    );

    final difference = today.difference(lastActiveDay).inDays;

    if (difference == 1) {
      // Continued streak
      await updateProfile(
        _profile!.copyWith(
          streakDays: _profile!.streakDays + 1,
          lastActiveDate: today,
        ),
      );
    } else if (difference > 1) {
      // Broken streak
      await updateProfile(
        _profile!.copyWith(streakDays: 1, lastActiveDate: today),
      );
    }
  }

  Future<void> updateProfile(UserProfile newProfile) async {
    _profile = newProfile;
    await StorageService.setString(
      _profileKey,
      jsonEncode(newProfile.toJson()),
    );
    notifyListeners();
  }

  Future<void> toggleFavorite(String contentId) async {
    if (_profile == null) return;

    final currentFavorites = List<String>.from(_profile!.favorites);
    if (currentFavorites.contains(contentId)) {
      currentFavorites.remove(contentId);
    } else {
      currentFavorites.add(contentId);
    }

    await updateProfile(_profile!.copyWith(favorites: currentFavorites));
  }

  Future<void> addToRecentlyPlayed(String contentId) async {
    if (_profile == null) return;

    final currentHistory = List<String>.from(_profile!.recentlyPlayed);

    // Remove if exists to move to top
    currentHistory.remove(contentId);

    // Add to top
    currentHistory.insert(0, contentId);

    // Keep only last 10
    if (currentHistory.length > 10) {
      currentHistory.removeLast();
    }

    await updateProfile(_profile!.copyWith(recentlyPlayed: currentHistory));
  }

  Future<void> updateRoutine(SleepRoutine routine) async {
    if (_profile == null) return;
    await updateProfile(_profile!.copyWith(windDownRoutine: routine));
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
      await _authService.signInWithEmail(email: email, password: password);
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
