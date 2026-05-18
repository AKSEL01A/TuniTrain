import 'package:flutter/material.dart';

/// Canonical color palette for TuniTrain.
/// All feature files should import this file directly.
/// The legacy `lib/const/colors.dart` re-exports from here for backward compat.
class AppColors {
  AppColors._();

  // ── Primary blues ─────────────────────────────────────────────────────────
  static const Color blue1 = Color(0xFF1B4F8A); // Deep navy — primary brand
  static const Color blue2 = Color(0xFF2E6DB4); // Medium blue — secondary brand
  static const Color blue3 = Color(0xFF4A90C4); // Light blue — muted text / icons
  static const Color blueLight = Color(0xFF7AB8D9);
  static const Color bluePale = Color(0xFFE6F1FB); // Pale chip backgrounds

  // ── Backgrounds ───────────────────────────────────────────────────────────
  static const Color bgPage = Color(0xFFF0F4FA);
  static const Color background = Color(0xFFF5F7FA);

  // ── Accent / status ───────────────────────────────────────────────────────
  static const Color green = Color(0xFF1D9E75);
  static const Color greenLight = Color(0xFFE1F5EE);
  static const Color greenBg = Color(0xFFE1F5EE);

  static const Color sand = Color(0xFFC8A96E);
  static const Color sandBg = Color(0xFFFAEEDA);

  static const Color orange = Color(0xFFEF9F27);

  static const Color red = Color(0xFFE53935);
  static const Color redLight = Color(0xFFFCEBEB);
  static const Color redBg = Color(0xFFFFEBEA);

  static const Color white = Color(0xFFFFFFFF);

  // ── Gradient presets ──────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [blue1, blue2],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient ctaGradient = LinearGradient(
    colors: [blue2, blue1],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
