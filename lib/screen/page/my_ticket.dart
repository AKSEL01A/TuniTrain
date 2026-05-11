import 'package:cloud_firestore/cloud_firestore.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  MyTicket model
//  Represents a purchased ticket stored in Firestore → collection 'tickets'
// ─────────────────────────────────────────────────────────────────────────────
class MyTicket {
  final String id;            // Firestore document ID
  final String ticketCode;    // e.g. "TT-20240511-0042"
  final String fromStation;
  final String toStation;
  final String departureTime; // "08:30"
  final String arrivalTime;   // "10:15"
  final DateTime travelDate;  // full DateTime of departure
  final String trainLine;     // e.g. "L1"
  final int trainNumber;      // e.g. 42
  final String ticketClass;   // "1st" | "2nd"
  final int passengers;
  final double totalPrice;
  final String paymentMethod; // "wallet" | "google" | "apple" | "card" | "d17"
  final String status;        // "confirmed" | "cancelled" | "used"
  final bool isRoundTrip;

  // Optional return leg (null if one-way)
  final String? returnFromStation;
  final String? returnToStation;
  final String? returnDepartureTime;
  final String? returnArrivalTime;
  final DateTime? returnDate;

  const MyTicket({
    required this.id,
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
  });

  factory MyTicket.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;

    DateTime _toDateTime(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    return MyTicket(
      id: doc.id,
      ticketCode: d['ticketCode'] as String? ?? doc.id,
      fromStation: d['fromStation'] as String? ?? '',
      toStation: d['toStation'] as String? ?? '',
      departureTime: d['departureTime'] as String? ?? '--:--',
      arrivalTime: d['arrivalTime'] as String? ?? '--:--',
      travelDate: _toDateTime(d['travelDate']),
      trainLine: d['trainLine'] as String? ?? '',
      trainNumber: (d['trainNumber'] as num?)?.toInt() ?? 0,
      ticketClass: d['ticketClass'] as String? ?? '2nd',
      passengers: (d['passengers'] as num?)?.toInt() ?? 1,
      totalPrice: (d['totalPrice'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: d['paymentMethod'] as String? ?? '',
      status: d['status'] as String? ?? 'confirmed',
      isRoundTrip: d['isRoundTrip'] as bool? ?? false,
      returnFromStation: d['returnFromStation'] as String?,
      returnToStation: d['returnToStation'] as String?,
      returnDepartureTime: d['returnDepartureTime'] as String?,
      returnArrivalTime: d['returnArrivalTime'] as String?,
      returnDate: d['returnDate'] != null
          ? _toDateTime(d['returnDate'])
          : null,
    );
  }

  Map<String, dynamic> toMap() => {
        'ticketCode': ticketCode,
        'fromStation': fromStation,
        'toStation': toStation,
        'departureTime': departureTime,
        'arrivalTime': arrivalTime,
        'travelDate': Timestamp.fromDate(travelDate),
        'trainLine': trainLine,
        'trainNumber': trainNumber,
        'ticketClass': ticketClass,
        'passengers': passengers,
        'totalPrice': totalPrice,
        'paymentMethod': paymentMethod,
        'status': status,
        'isRoundTrip': isRoundTrip,
        if (returnFromStation != null) 'returnFromStation': returnFromStation,
        if (returnToStation != null) 'returnToStation': returnToStation,
        if (returnDepartureTime != null)
          'returnDepartureTime': returnDepartureTime,
        if (returnArrivalTime != null) 'returnArrivalTime': returnArrivalTime,
        if (returnDate != null)
          'returnDate': Timestamp.fromDate(returnDate!),
      };
}
