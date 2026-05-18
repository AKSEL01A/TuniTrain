library;

import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// BORDER RADIUS
// ─────────────────────────────────────────────────────────────────────────────

/// Named border-radius values extracted from the design system.
/// All values are doubles so they can be used in [BorderRadius.circular].
abstract final class AppRadius {
  static const double xs = 8.0; // chips, small badges
  static const double sm = 10.0; // station order badges, month headers
  static const double md = 12.0; // tiles, inner cards
  static const double lg = 14.0; // buttons, date pickers, medium cards
  static const double xl = 16.0; // standard cards, list items
  static const double xxl = 18.0; // plan cards, class cards
  static const double card = 20.0; // bottom sheets, nav bars
  static const double cardLg = 22.0; // ticket cards
  static const double cardXl = 24.0; // search card, large bottom bars
  static const double avatar = 28.0; // home bottom nav, profile circles
  static const double circle = 50.0; // fully circular
}

// ─────────────────────────────────────────────────────────────────────────────
// ANIMATION DURATIONS
// ─────────────────────────────────────────────────────────────────────────────

/// Named animation durations used throughout the app.
abstract final class AppDurations {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 300);
  static const Duration navigation = Duration(milliseconds: 350);
  static const Duration pulse = Duration(seconds: 2);
  static const Duration qrRefresh = Duration(seconds: 30);
  static const Duration snackbar = Duration(seconds: 3);
}

// ─────────────────────────────────────────────────────────────────────────────
// SPACING / PADDING
// ─────────────────────────────────────────────────────────────────────────────

/// Spacing scale — a consistent set of gaps and insets.
abstract final class AppSpacing {
  static const double xxs = 2.0;
  static const double xs = 4.0;
  static const double sm = 6.0;
  static const double md = 8.0;
  static const double lg = 10.0;
  static const double xl = 12.0;
  static const double xxl = 14.0;
  static const double section = 16.0;
  static const double pagePad = 20.0;
  static const double cardPad = 18.0;

  // ── Common EdgeInsets shortcuts ───────────────────────────────────────────
  static const EdgeInsets screenPadding = EdgeInsets.all(pagePad);
  static const EdgeInsets cardPadding = EdgeInsets.all(cardPad);
  static const EdgeInsets listPadding =
      EdgeInsets.fromLTRB(section, section, section, 30);
  static const EdgeInsets chipPadding =
      EdgeInsets.symmetric(horizontal: xl, vertical: xs);
  static const EdgeInsets buttonPadding =
      EdgeInsets.symmetric(horizontal: 28, vertical: 13);
}

// ─────────────────────────────────────────────────────────────────────────────
// SIZES
// ─────────────────────────────────────────────────────────────────────────────

/// Fixed sizes for commonly reused elements.
abstract final class AppSizes {
  static const double iconSm = 14.0;
  static const double iconMd = 18.0;
  static const double iconLg = 22.0;
  static const double iconXl = 24.0;
  static const double iconXxl = 28.0;

  static const double avatarSm = 36.0;
  static const double avatarMd = 48.0;
  static const double avatarLg = 56.0;
  static const double avatarXl = 80.0;
  static const double avatarXxl = 110.0;

  static const double buttonHeight = 52.0;
  static const double tabBarHeight = 46.0;

  static const double skeletonCardHeight = 180.0;
  static const double emptyIconSize = 100.0;
}
