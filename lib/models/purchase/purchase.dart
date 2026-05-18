class Purchase {
  final int? id;

  final DateTime? startDate;
  final DateTime? endDate;

  final String? firstName;
  final String? lastName;

  final String? email;
  final String? phoneNumber;

  final double? price;

  final String? qrCode;

  const Purchase({
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

  bool validate() => true;

  void markAsUsed() {}
}
