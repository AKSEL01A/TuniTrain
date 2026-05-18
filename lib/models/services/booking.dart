// ─── Enums ───────────────────────────────────────────────────────────────────

enum BookingType { carRental, ticket, promoOffer, subscription }

enum BookingStatus { pending, confirmed, cancelled, completed, expired }

enum PaymentStatus { pending, paid, failed, refunded }

extension BookingTypeX on BookingType {
  String get label => switch (this) {
    BookingType.carRental    => 'Location de voiture',
    BookingType.ticket       => 'Billet d\'entrée',
    BookingType.promoOffer   => 'Offre promotionnelle',
    BookingType.subscription => 'Abonnement',
  };
}

extension BookingStatusX on BookingStatus {
  String get label => switch (this) {
    BookingStatus.pending   => 'En attente',
    BookingStatus.confirmed => 'Confirmé',
    BookingStatus.cancelled => 'Annulé',
    BookingStatus.completed => 'Terminé',
    BookingStatus.expired   => 'Expiré',
  };

  bool get isActive =>
      this == BookingStatus.confirmed || this == BookingStatus.pending;

  bool get isFinal =>
      this == BookingStatus.completed ||
      this == BookingStatus.cancelled ||
      this == BookingStatus.expired;
}

extension PaymentStatusX on PaymentStatus {
  String get label => switch (this) {
    PaymentStatus.pending  => 'En attente',
    PaymentStatus.paid     => 'Payé',
    PaymentStatus.failed   => 'Échoué',
    PaymentStatus.refunded => 'Remboursé',
  };
}

// ─── Model ───────────────────────────────────────────────────────────────────

class Booking {
  final String id;
  final String reference;
  final DateTime startDate;
  final DateTime endDate;
  final double subtotal;
  final double taxes;
  final double discount;
  final double totalPrice;
  final BookingType type;
  final BookingStatus status;
  final PaymentStatus paymentStatus;
  final String paymentMethod;
  final String qrCodeData;
  final bool isUsed;
  final String? cancellationReason;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? expiresAt;
  final Map<String, dynamic> serviceDetails;
  final String userId;
  final String? userName;

  const Booking({
    required this.id,
    required this.reference,
    required this.startDate,
    required this.endDate,
    required this.subtotal,
    this.taxes = 0.0,
    this.discount = 0.0,
    required this.totalPrice,
    required this.type,
    this.status = BookingStatus.pending,
    this.paymentStatus = PaymentStatus.pending,
    this.paymentMethod = 'card',
    this.qrCodeData = '',
    this.isUsed = false,
    this.cancellationReason,
    required this.createdAt,
    this.updatedAt,
    this.expiresAt,
    this.serviceDetails = const {},
    required this.userId,
    this.userName,
  });

  bool get isActive => status.isActive;
  bool get isPast => status.isFinal;
  bool get isExpired =>
      expiresAt != null && DateTime.now().isAfter(expiresAt!);
  double get netTotal => subtotal + taxes - discount;

  Booking copyWith({
    String? id,
    String? reference,
    DateTime? startDate,
    DateTime? endDate,
    double? subtotal,
    double? taxes,
    double? discount,
    double? totalPrice,
    BookingType? type,
    BookingStatus? status,
    PaymentStatus? paymentStatus,
    String? paymentMethod,
    String? qrCodeData,
    bool? isUsed,
    String? cancellationReason,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? expiresAt,
    Map<String, dynamic>? serviceDetails,
    String? userId,
    String? userName,
  }) {
    return Booking(
      id: id ?? this.id,
      reference: reference ?? this.reference,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      subtotal: subtotal ?? this.subtotal,
      taxes: taxes ?? this.taxes,
      discount: discount ?? this.discount,
      totalPrice: totalPrice ?? this.totalPrice,
      type: type ?? this.type,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      qrCodeData: qrCodeData ?? this.qrCodeData,
      isUsed: isUsed ?? this.isUsed,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      serviceDetails: serviceDetails ?? this.serviceDetails,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
    );
  }

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] as String,
      reference: json['reference'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      subtotal: (json['subtotal'] as num).toDouble(),
      taxes: (json['taxes'] as num?)?.toDouble() ?? 0.0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      totalPrice: (json['totalPrice'] as num).toDouble(),
      type: BookingType.values.byName(json['type'] as String),
      status: BookingStatus.values.byName(json['status'] as String),
      paymentStatus: PaymentStatus.values.byName(json['paymentStatus'] as String),
      paymentMethod: json['paymentMethod'] as String? ?? 'card',
      qrCodeData: json['qrCodeData'] as String? ?? '',
      isUsed: json['isUsed'] as bool? ?? false,
      cancellationReason: json['cancellationReason'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String)
          : null,
      serviceDetails:
          (json['serviceDetails'] as Map<String, dynamic>?) ?? const {},
      userId: json['userId'] as String,
      userName: json['userName'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'reference': reference,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
    'subtotal': subtotal,
    'taxes': taxes,
    'discount': discount,
    'totalPrice': totalPrice,
    'type': type.name,
    'status': status.name,
    'paymentStatus': paymentStatus.name,
    'paymentMethod': paymentMethod,
    'qrCodeData': qrCodeData,
    'isUsed': isUsed,
    'cancellationReason': cancellationReason,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
    'expiresAt': expiresAt?.toIso8601String(),
    'serviceDetails': serviceDetails,
    'userId': userId,
    'userName': userName,
  };
}
