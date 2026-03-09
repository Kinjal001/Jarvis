import 'package:flutter/material.dart';

/// All Jarvis brand colors in one place.
///
/// Design philosophy: dark navy-purple base with vivid accent colors.
/// Each entity type has its own accent so the UI feels alive at a glance:
///   Goals → pink/rose
///   Projects → blue
///   Tasks → cyan
///   Streaks/XP → amber (Phase 2)
///
/// Never use raw Color literals in widgets — always reference AppColors.
abstract final class AppColors {
  // ── Backgrounds ────────────────────────────────────────────────────────────
  static const background = Color(0xFF0D0D1A); // deep navy — Scaffold bg
  static const surface = Color(0xFF1A1A2E); // dark navy-purple — cards, sheets
  static const cardElevated = Color(
    0xFF252540,
  ); // slightly lighter card variant
  static const divider = Color(0xFF2E2E4A); // subtle separator line

  // ── Brand: purple/violet family ────────────────────────────────────────────
  static const primary = Color(0xFF7C3AED); // violet — main brand color
  static const primaryLight = Color(
    0xFFA855F7,
  ); // lighter purple — active states
  static const indigo = Color(0xFF6366F1); // blue-purple — secondary accent

  // ── Entity accent colors ───────────────────────────────────────────────────
  static const amber = Color(
    0xFFF59E0B,
  ); // gold — XP, streaks, rewards (Phase 2)
  static const pink = Color(0xFFEC4899); // rose — goals
  static const emerald = Color(0xFF10B981); // green — completed/success states
  static const blue = Color(0xFF3B82F6); // blue — projects
  static const cyan = Color(0xFF06B6D4); // cyan — tasks

  // ── Error ──────────────────────────────────────────────────────────────────
  static const error = Color(0xFFEF4444);
  static const errorContainer = Color(0xFF3D1A1A);

  // ── Text ───────────────────────────────────────────────────────────────────
  static const textPrimary = Color(0xFFF0F0FF); // soft white with blue tint
  static const textSecondary = Color(0xFF8B8BAE); // muted lavender-grey
  static const textDisabled = Color(0xFF4A4A6A); // very muted

  // ── Gradients ──────────────────────────────────────────────────────────────

  /// Purple → indigo → blue: used on hero/featured cards.
  static const heroGradient = LinearGradient(
    colors: [primary, indigo, blue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Pink → violet → cyan: used on goal card borders (Habitica-style rainbow).
  static const goalBorderGradient = LinearGradient(
    colors: [pink, primary, cyan],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Violet → indigo: used on the diamond FAB.
  static const fabGradient = LinearGradient(
    colors: [primaryLight, primary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
