import 'package:flutter/material.dart';

/// DreamDrift color palette — deep, calming, sleep-focused.
class SleepColors {
  SleepColors._();

  // ─── Core Backgrounds ─────────────────────────────
  static const Color background = Color(0xFF0F0B1E); // Midnight Violet
  static const Color surface = Color(0xFF1B1431); // Deep Violet
  static const Color surfaceLight = Color(0xFF281E46); // Medium Violet
  static const Color surfaceGlass = Color(
    0x66281E46,
  ); // Increased opacity for legibility

  // ─── Primary Palette ──────────────────────────────
  static const Color primary = Color(0xFFB358D7); // Vibrant Violet-Pink
  static const Color primaryLight = Color(0xFFD69AD9); // Soft Lavender
  static const Color primaryDark = Color(0xFF7E30B7); // Solid Purple
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
  static const Color textPrimary = Color(0xFFF5F5FF); // Brightened
  static const Color textSecondary = Color(
    0xFFF5F5FF,
  ); // Lightened for contrast
  static const Color textMuted = Color(0xFFF5F5FF); // Lightened for contrast

  // ─── Gradients ────────────────────────────────────
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF281E46), Color(0xFF0F0B1E)],
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
    colors: [Color(0xFF281E46), Color(0xFF1B1431)],
  );

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFB358D7), Color(0xFF7E30B7)],
  );

  static const LinearGradient nightGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF281E46), Color(0xFF1B1431), Color(0xFF0F0B1E)],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF5C842), Color(0xFFE8A317)],
  );
}
