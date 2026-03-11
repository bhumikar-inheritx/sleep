import 'package:flutter/material.dart';

/// DreamDrift color palette — deep, calming, sleep-focused.
class SleepColors {
  SleepColors._();

  // ─── Core Backgrounds ─────────────────────────────
  static const Color background = Color(0xFF0A0E27);
  static const Color surface = Color(0xFF141836);
  static const Color surfaceLight = Color(0xFF1E2350);
  static const Color surfaceGlass = Color(0x331E2350);

  // ─── Primary Palette ──────────────────────────────
  static const Color primary = Color(0xFF9D50BB); // Vibrant Purple
  static const Color primaryLight = Color(0xFFBE93C5); // Soft Purple
  static const Color primaryDark = Color(0xFF6E48AA); // Deep Purple
  static const Color accent = Color(
    0xFFFF8A65,
  ); // Coral/Orange accent from reference

  // ─── Accent Colors ───────────────────────────────
  static const Color gold = Color(0xFFF5C842);
  static const Color sleepBlue = Color(0xFF3B82F6);
  static const Color moonGlow = Color(0xFFE8D5B7);
  static const Color starWhite = Color(0xFFE0E7FF);

  // ─── Semantic Colors ──────────────────────────────
  static const Color success = Color(0xFF34D399);
  static const Color warning = Color(0xFFFBBF24);
  static const Color error = Color(0xFFEF4444);

  // ─── Text ─────────────────────────────────────────
  static const Color textPrimary = Color(0xFFEEEEFF);
  static const Color textSecondary = Color(0xFF8B8FAD);
  static const Color textMuted = Color(0xFF5A5E7A);

  // ─── Gradients ────────────────────────────────────
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1A1B4B), Color(0xFF0A0E27)],
  );

  static const LinearGradient vibrantGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF9D50BB),
      Color(0xFFFF8A65),
    ], // Purple to Coral as seen in splash
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E2350), Color(0xFF141836)],
  );

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF9D50BB), Color(0xFF6E48AA)],
  );

  static const LinearGradient nightGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1a1a4e), Color(0xFF0F1338), Color(0xFF0A0E27)],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF5C842), Color(0xFFE8A317)],
  );
}
