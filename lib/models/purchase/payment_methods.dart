import 'package:flutter/material.dart';

/// Known payment method identifiers stored in Firestore tickets.
abstract final class PaymentMethodIds {
  static const String google = 'google';
  static const String apple = 'apple';
  static const String card = 'card';
  static const String d17 = 'd17';
}

/// Helpers for mapping a Firestore payment-method string to UI icon / label.
abstract final class PaymentMethods {
  /// Returns the [IconData] that represents [method] in the UI.
  static IconData icon(String method) {
    switch (method) {
      case PaymentMethodIds.google:
        return Icons.g_mobiledata_rounded;
      case PaymentMethodIds.apple:
        return Icons.apple_rounded;
      case PaymentMethodIds.card:
        return Icons.credit_card_rounded;
      case PaymentMethodIds.d17:
        return Icons.smartphone_rounded;
      default:
        return Icons.account_balance_wallet_rounded;
    }
  }

  /// Returns the human-readable label for [method].
  static String label(String method) {
    switch (method) {
      case PaymentMethodIds.google:
        return 'G Pay';
      case PaymentMethodIds.apple:
        return 'Apple Pay';
      case PaymentMethodIds.card:
        return 'Carte';
      case PaymentMethodIds.d17:
        return 'D17';
      default:
        return 'Wallet';
    }
  }

  /// Accent colour used for the payment chip in ticket cards.
  static const Color chipColor = Color(0xFF7B2FBE);

  /// Background colour used for the payment chip in ticket cards.
  static const Color chipBg = Color(0xFFF3E8FF);
}
