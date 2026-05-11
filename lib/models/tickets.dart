import 'package:tuni_train/models/purchase.dart';

enum TicketStatus { active, used, expired }

class Ticket extends Purchase {
  TicketStatus status;

  Ticket({
    required int id,
    required DateTime startDate,
    required String lastName,
    required String firstName,
    required String email,
    required DateTime endDate,
    required double price,
    required String phoneNumber,
    required String qrCode,
    required this.status,
  }) : super(
         id: id,
         startDate: startDate,
         lastName: lastName,
         firstName: firstName,
         email: email,
         endDate: endDate,
         price: price,
         phoneNumber: phoneNumber,
         qrCode: qrCode,
       );

  @override
  bool validate() {
    // Overriding to check both dates (from parent) AND status
    return super.validate() && status == TicketStatus.active;
  }

  @override
  void markAsUsed() {
    status = TicketStatus.used;
    super.markAsUsed();
  }
}
