enum PaymentStatus { success, failed, pending }

class Payment {
  int? id;
  double? amount;
  PaymentStatus? status;

  Payment({this.id, this.amount, this.status = PaymentStatus.pending});

  bool processPayment() {
    // Logic bech t-connecti m3a Stripe wala ay payment gateway
    return true;
  }
}
