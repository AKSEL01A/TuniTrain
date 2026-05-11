enum BookingType { carRental, ticket, promoOffer, subscription }

enum BookingStatus { pending, confirmed, cancelled, completed, expired }

class Booking {
  int? id;
  DateTime? startDate;
  DateTime? endDate;
  double? totalPrice;
  BookingType? type;
  BookingStatus? status;
  double? discount;
  String? qrCodeData;
  bool isUsed;

  Booking({
    this.id,
    this.startDate,
    this.endDate,
    this.totalPrice,
    this.type,
    this.status,
    this.discount,
    this.qrCodeData,
    this.isUsed = false,
  });

  void createBooking() {}

  void cancelBooking() {
    status = BookingStatus.cancelled;
  }

  String generateQRCode() {
    return qrCodeData ?? "";
  }

  double calculateTotal() {
    return totalPrice ?? 0.0;
  }

  bool validateBooking() {
    return true;
  }
}
