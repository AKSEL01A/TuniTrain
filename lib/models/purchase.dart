class Purchase {
  int? id;
  DateTime? startDate;
  DateTime? endDate;
  String? firstName;
  String? lastName;
  String? email;
  String? phoneNumber;
  double? price;
  String? qrCode;

  // Constructor
  Purchase({
    this.id,
    this.startDate,
    this.endDate,
    this.firstName,
    this.lastName,
    this.email,
    this.phoneNumber,
    this.price,
    this.qrCode,
  });

  // Methods
  String generateQRCode() {
    return "";
  }

  bool validate() {
    return true;
  }

  void markAsUsed() {
    // logic
  }
}
