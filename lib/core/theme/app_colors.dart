/// Nexus — Color palette.
///
/// Premium color system inspired by the mockup designs.
/// Deep teal primary with navy accents and semantic status colors.
library;

import 'package:flutter/material.dart';

abstract final class AppColors {
  // ── Brand Colors ───────────────────────────────────────────
  static const Color primary = Color(0xFF0D7377);
  static const Color primaryDark = Color(0xFF095456);
  static const Color primaryLight = Color(0xFF14A3A8);
  static const Color accent = Color(0xFF1A3A5C);
  static const Color accentLight = Color(0xFF2B5A8C);

  // ── Surface / Background ──────────────────────────────────
  static const Color background = Color(0xFFF7F9FC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F5F9);
  static const Color cardBorder = Color(0xFFE2E8F0);

  // ── Text ──────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textTertiary = Color(0xFF94A3B8);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ── Semantic / Status ─────────────────────────────────────
  static const Color success = Color(0xFF059669);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color warning = Color(0xFFD97706);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFDC2626);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF2563EB);
  static const Color infoLight = Color(0xFFDBEAFE);

  // ── Cash Flow Badges ──────────────────────────────────────
  static const Color cashReceived = Color(0xFF059669);
  static const Color cashReceivedBg = Color(0xFFECFDF5);
  static const Color cashPaid = Color(0xFFDC2626);
  static const Color cashPaidBg = Color(0xFFFEF2F2);

  // ── Nav ───────────────────────────────────────────────────
  static const Color navBackground = Color(0xFFFFFFFF);
  static const Color navSelected = Color(0xFF0D7377);
  static const Color navUnselected = Color(0xFF94A3B8);

  // ── Dark Theme Overrides ──────────────────────────────────
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkSurfaceVariant = Color(0xFF334155);
  static const Color darkCardBorder = Color(0xFF475569);
  static const Color darkTextPrimary = Color(0xFFF1F5F9);
  static const Color darkTextSecondary = Color(0xFF94A3B8);

  // Dark semantic backgrounds (subtle, for dark mode)
  static const Color darkCashReceivedBg = Color(0xFF064E3B);
  static const Color darkCashPaidBg = Color(0xFF7F1D1D);
  static const Color darkWarningLight = Color(0xFF78350F);

  // ── Brightness-aware helpers ──────────────────────────────
  /// Returns the correct text primary color based on current brightness.
  static Color textPrimaryFor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? darkTextPrimary
          : textPrimary;

  static Color textSecondaryFor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? darkTextSecondary
          : textSecondary;

  static Color textTertiaryFor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF64748B)
          : textTertiary;

  static Color cashReceivedBgFor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? darkCashReceivedBg
          : cashReceivedBg;

  static Color cashPaidBgFor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? darkCashPaidBg
          : cashPaidBg;

  static Color warningLightFor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? darkWarningLight
          : warningLight;
}

