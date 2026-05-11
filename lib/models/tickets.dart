import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tuni_train/models/purchase.dart';

enum TicketStatus { active, used, expired, cancelled }

class Ticket extends Purchase {
  final String firestoreId;

  final String ticketCode;

  final String fromStation;
  final String toStation;

  final String departureTime;
  final String arrivalTime;

  final DateTime travelDate;

  final String trainLine;
  final int trainNumber;

  final String ticketClass;
  final int passengers;

  final String paymentMethod;

  final bool isRoundTrip;

  final String? returnFromStation;
  final String? returnToStation;
  final String? returnDepartureTime;
  final String? returnArrivalTime;
  final DateTime? returnDate;

  TicketStatus status;

  Ticket({
    required this.firestoreId,
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
    required double totalPrice,
    required this.paymentMethod,
    required this.status,
    required this.isRoundTrip,
    this.returnFromStation,
    this.returnToStation,
    this.returnDepartureTime,
    this.returnArrivalTime,
    this.returnDate,

    // Purchase optional fields
    int? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
  }) : super(
         id: id,
         startDate: travelDate,
         endDate: returnDate ?? travelDate,
         firstName: firstName,
         lastName: lastName,
         email: email,
         phoneNumber: phoneNumber,
         price: totalPrice,
         qrCode: ticketCode,
       );

  String toQrPayload() {
    return '''
ticketCode:$ticketCode
from:$fromStation
to:$toStation
date:${travelDate.toIso8601String()}
departure:$departureTime
arrival:$arrivalTime
class:$ticketClass
passengers:$passengers
price:$price
roundTrip:$isRoundTrip
''';
  }

  // ─────────────────────────────
  // FIRESTORE
  // ─────────────────────────────

  factory Ticket.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;

    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();

      if (val is String) {
        return DateTime.tryParse(val) ?? DateTime.now();
      }

      return DateTime.now();
    }

    TicketStatus parseStatus(String s) {
      switch (s) {
        case 'used':
          return TicketStatus.used;

        case 'expired':
          return TicketStatus.expired;

        case 'cancelled':
          return TicketStatus.cancelled;

        default:
          return TicketStatus.active;
      }
    }

    return Ticket(
      firestoreId: doc.id,
      ticketCode: d['ticketCode'] ?? doc.id,
      fromStation: d['fromStation'] ?? '',
      toStation: d['toStation'] ?? '',
      departureTime: d['departureTime'] ?? '--:--',
      arrivalTime: d['arrivalTime'] ?? '--:--',
      travelDate: parseDate(d['travelDate']),
      trainLine: d['trainLine'] ?? '',
      trainNumber: (d['trainNumber'] as num?)?.toInt() ?? 0,
      ticketClass: d['ticketClass'] ?? '2nd',
      passengers: (d['passengers'] as num?)?.toInt() ?? 1,
      totalPrice: (d['totalPrice'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: d['paymentMethod'] ?? '',
      status: parseStatus(d['status'] ?? 'active'),
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

  Map<String, dynamic> toMap() {
    return {
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
      'totalPrice': price,
      'paymentMethod': paymentMethod,
      'status': status.name,
      'isRoundTrip': isRoundTrip,

      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phoneNumber': phoneNumber,

      if (returnFromStation != null) 'returnFromStation': returnFromStation,

      if (returnToStation != null) 'returnToStation': returnToStation,

      if (returnDepartureTime != null)
        'returnDepartureTime': returnDepartureTime,

      if (returnArrivalTime != null) 'returnArrivalTime': returnArrivalTime,

      if (returnDate != null) 'returnDate': Timestamp.fromDate(returnDate!),
    };
  }

  // ─────────────────────────────
  // BUSINESS LOGIC
  // ─────────────────────────────

  @override
  bool validate() {
    return status == TicketStatus.active;
  }

  @override
  void markAsUsed() {
    status = TicketStatus.used;
  }

  bool get isExpired {
    return travelDate.isBefore(DateTime.now());
  }
}
