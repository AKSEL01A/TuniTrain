import 'package:cloud_firestore/cloud_firestore.dart';

class MyTicket {
  final String id; // Firestore doc ID
  final String userId;
  final String ticketCode;
  final String fromStation;
  final String toStation;
  final String departureTime;
  final String arrivalTime;
  final DateTime travelDate;
  final String trainLine;
  final String trainNumber;
  final String ticketClass;
  final int passengers;
  final double totalPrice;
  final String paymentMethod;
  final String status;
  final bool isRoundTrip;

  final String? returnFromStation;
  final String? returnToStation;
  final String? returnDepartureTime;
  final String? returnArrivalTime;
  final DateTime? returnDate;

  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phoneNumber;

  const MyTicket({
    required this.id,
    required this.userId,
    required this.ticketCode,
    required this.fromStation,
    required this.toStation,
    required this.departureTime,
    required this.arrivalTime,
    required this.travelDate,
    required this.trainLine,
    required this.trainNumber,
    required this.ticketClass,
    required this.passengers,
    required this.totalPrice,
    required this.paymentMethod,
    required this.status,
    required this.isRoundTrip,
    this.returnFromStation,
    this.returnToStation,
    this.returnDepartureTime,
    this.returnArrivalTime,
    this.returnDate,
    this.firstName,
    this.lastName,
    this.email,
    this.phoneNumber,
  });

  // ─────────────────────────────
  // FROM FIRESTORE
  // ─────────────────────────────
  factory MyTicket.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;

    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    return MyTicket(
      id: doc.id,
      userId: d['userId'] ?? '',
      ticketCode: d['ticketCode'] ?? doc.id,
      fromStation: d['fromStation'] ?? '',
      toStation: d['toStation'] ?? '',
      departureTime: d['departureTime'] ?? '--:--',
      arrivalTime: d['arrivalTime'] ?? '--:--',
      travelDate: parseDate(d['travelDate']),
      trainLine: d['trainLine'] ?? '',
      trainNumber: d['trainNumber']?.toString() ?? '',
      ticketClass: d['ticketClass'] ?? '2nd',
      passengers: (d['passengers'] as num?)?.toInt() ?? 1,
      totalPrice: (d['totalPrice'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: d['paymentMethod'] ?? '',
      status: d['status'] ?? 'active',
      isRoundTrip: d['isRoundTrip'] ?? false,
      returnFromStation: d['returnFromStation'],
      returnToStation: d['returnToStation'],
      returnDepartureTime: d['returnDepartureTime'],
      returnArrivalTime: d['returnArrivalTime'],
      returnDate: d['returnDate'] != null ? parseDate(d['returnDate']) : null,
      firstName: d['firstName'],
      lastName: d['lastName'],
      email: d['email'],
      phoneNumber: d['phoneNumber'],
    );
  }

  // ─────────────────────────────
  // QR PAYLOAD
  // ─────────────────────────────
  String toQrPayload() {
    return [
      'ticketCode:$ticketCode',
      'from:$fromStation',
      'to:$toStation',
      'date:${travelDate.toIso8601String()}',
      'departure:$departureTime',
      'arrival:$arrivalTime',
      'class:$ticketClass',
      'passengers:$passengers',
      'price:$totalPrice',
      'roundTrip:$isRoundTrip',
    ].join('\n');
  }

  bool get isActive => status == 'active';
  bool get isPast => travelDate.isBefore(
    DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
  );
}
