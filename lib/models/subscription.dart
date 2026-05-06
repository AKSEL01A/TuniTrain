import 'package:tuni_train/models/purchase.dart';

enum SubscriptionStatus { ACTIVE, EXPIRED, PENDING, BLOCKED }

class Subscription extends Purchase {
  bool isStudent;
  SubscriptionStatus status;

  Subscription({required this.isStudent, required this.status, super.id});

  bool isActive() {
    return status == SubscriptionStatus.ACTIVE;
  }

  int calculateRemainingDays() {
    if (endDate == null) return 0;
    return endDate!.difference(DateTime.now()).inDays;
  }

  @override
  String generateQRCode() {
    return super.generateQRCode();
  }
}
