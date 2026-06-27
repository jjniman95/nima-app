import 'package:flutter/material.dart';

/// NIMA Design System — Color Tokens
///
/// All colors in the app must be referenced from here.
/// Never use raw hex codes anywhere outside this file.
abstract final class AppColors {
  // ── Brand ────────────────────────────────────────────────────────────────
  static const Color royalPurple = Color(0xFF6C4DFF);
  static const Color royalPurpleLight = Color(0xFF9B85FF);
  static const Color royalPurpleDark = Color(0xFF4A2FE0);

  // ── Backgrounds ──────────────────────────────────────────────────────────
  static const Color lightBackground = Color(0xFFF8F7FF);
  static const Color darkBackground = Color(0xFF0D0B1A);

  // ── Surface (cards, sheets) ───────────────────────────────────────────────
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color darkSurface = Color(0xFF1C1830);

  // ── Text ─────────────────────────────────────────────────────────────────
  static const Color lightTextPrimary = Color(0xFF0D0B1A);
  static const Color lightTextSecondary = Color(0xFF6E6A85);
  static const Color darkTextPrimary = Color(0xFFF0EEFF);
  static const Color darkTextSecondary = Color(0xFF9C98B8);

  // ── Semantic ─────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF34C759);
  static const Color warning = Color(0xFFFF9500);
  static const Color error = Color(0xFFFF3B30);
  static const Color info = Color(0xFF007AFF);

  // ── Radar / Geo UI ───────────────────────────────────────────────────────
  static const Color radarRing = Color(0x266C4DFF);  // royalPurple @ 15% opacity
  static const Color radarPulse = Color(0x4D6C4DFF); // royalPurple @ 30% opacity
}
