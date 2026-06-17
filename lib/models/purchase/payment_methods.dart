import 'package:flutter/material.dart';

abstract final class PaymentMethodIds {
  static const String wallet = 'wallet';
  static const String google = 'google';
  static const String apple = 'apple';
  static const String card = 'card';
  static const String d17 = 'd17';
}

class PaymentMethods {
  static IconData icon(String method) {
    switch (method) {
      case PaymentMethodIds.wallet:
        return Icons.account_balance_wallet_rounded;

      case PaymentMethodIds.google:
        return Icons.g_mobiledata_rounded;

      case PaymentMethodIds.apple:
        return Icons.apple_rounded;

      case PaymentMethodIds.card:
        return Icons.credit_card_rounded;

      case PaymentMethodIds.d17:
        return Icons.phone_android_rounded;

      default:
        return Icons.payment_rounded;
    }
  }

  static String label(String method) {
    switch (method) {
      case PaymentMethodIds.wallet:
        return 'Wallet';

      case PaymentMethodIds.google:
        return 'Google Pay';

      case PaymentMethodIds.apple:
        return 'Apple Pay';

      case PaymentMethodIds.card:
        return 'Card';

      case PaymentMethodIds.d17:
        return 'D17';

      default:
        return 'Payment';
    }
  }

  static Color get chipColor => const Color(0xFF1565C0);

  static Color get chipBg => const Color(0xFFE3F2FD);
}
