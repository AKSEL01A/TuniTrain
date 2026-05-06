// 1. El-Enum f'Dart ma fihach kelmet "public"
import 'package:tuni_train/models/purchase.dart';

enum TicketStatus { ACTIVE, USED, EXPIRED }

// 2. Class Ticket extends Purchase
class Ticket extends Purchase {
  TicketStatus? status;

  // Constructor (lezem dima f'Dart)
  Ticket({
    this.status,
    super.id, 
    super.startDate,
    super.endDate,
  });

  @override 
  String generateQRCode() {
    return super.generateQRCode();
  }

  @override
  bool validate() {
    // f'Dart nasta3mlou "bool" mouch "boolean"
    return super.validate();
  }

  @override
  void markAsUsed() {
    super.markAsUsed();
  }
}
