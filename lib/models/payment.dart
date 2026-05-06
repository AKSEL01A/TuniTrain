enum PaymentStatus { SUCCESS, FAILED, PENDING }

class Payment {
  int? id; // Long wallat int f'Dart
  double? amount;
  PaymentStatus? status;

  Payment({this.id, this.amount, this.status = PaymentStatus.PENDING});

  bool processPayment() {
    // Logic bech t-connecti m3a stripe wala ay payment gateway
    return true;
  }
}
