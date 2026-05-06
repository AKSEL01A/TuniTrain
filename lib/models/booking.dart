enum BookingType { CAR_RENTAL, TICKET, PROMO_OFFER, SUBSCRIPTION }

enum BookingStatus { PENDING, CONFIRMED, CANCELLED, COMPLETED, EXPIRED }

class Booking {
  int? id; // Long fil-UML wallat int f'Dart
  DateTime? startDate; // Date wallat DateTime
  DateTime? endDate;
  double? totalPrice;
  BookingType? type;
  BookingStatus? status;
  double? discount;
  String? qrCodeData;
  bool isUsed; // boolean wallat bool

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

  // Methods
  void createBooking() {
    // logic bech tasma3 booking jdid
  }

  void cancelBooking() {
    // logic bech tfaskh el booking
    this.status = BookingStatus.CANCELLED;
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
