import 'package:cloud_firestore/cloud_firestore.dart';

class Payment {
  final String? id;

  // Client
  final String userId;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;

  // Payment
  final String paymentMethod; // 'wallet' | 'google' | 'apple' | 'card' | 'd17'
  final double amount;
  final String currency;
  final String status; // 'success' | 'failed' | 'pending'

  // Linked ticket
  final String ticketId;
  final String ticketCode;
  final String fromStation;
  final String toStation;
  final int passengers;
  final String ticketClass;
  final bool isRoundTrip;

  // Date
  final DateTime? paidAt;

  const Payment({
    this.id,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.paymentMethod,
    required this.amount,
    this.currency = 'DT',
    this.status = 'success',
    required this.ticketId,
    required this.ticketCode,
    required this.fromStation,
    required this.toStation,
    required this.passengers,
    required this.ticketClass,
    required this.isRoundTrip,
    this.paidAt,
  });

  String get fullName => '$firstName $lastName';

  // ── To Firestore ──────────────────────────────────────────────
  Map<String, dynamic> toFirestore() => {
    'userId': userId,
    'firstName': firstName,
    'lastName': lastName,
    'fullName': fullName,
    'email': email,
    'phoneNumber': phoneNumber,
    'paymentMethod': paymentMethod,
    'amount': amount,
    'currency': currency,
    'status': status,
    'ticketId': ticketId,
    'ticketCode': ticketCode,
    'fromStation': fromStation,
    'toStation': toStation,
    'passengers': passengers,
    'ticketClass': ticketClass,
    'isRoundTrip': isRoundTrip,
    'paidAt': FieldValue.serverTimestamp(),
    'createdAt': FieldValue.serverTimestamp(),
  };

  // ── From Firestore ────────────────────────────────────────────
  factory Payment.fromFirestore(DocumentSnapshot doc) {
    final m = doc.data() as Map<String, dynamic>;
    return Payment(
      id: doc.id,
      userId: m['userId'] ?? '',
      firstName: m['firstName'] ?? '',
      lastName: m['lastName'] ?? '',
      email: m['email'] ?? '',
      phoneNumber: m['phoneNumber'] ?? '',
      paymentMethod: m['paymentMethod'] ?? '',
      amount: (m['amount'] as num?)?.toDouble() ?? 0,
      currency: m['currency'] ?? 'DT',
      status: m['status'] ?? 'success',
      ticketId: m['ticketId'] ?? '',
      ticketCode: m['ticketCode'] ?? '',
      fromStation: m['fromStation'] ?? '',
      toStation: m['toStation'] ?? '',
      passengers: (m['passengers'] as num?)?.toInt() ?? 1,
      ticketClass: m['ticketClass'] ?? '',
      isRoundTrip: m['isRoundTrip'] ?? false,
      paidAt: (m['paidAt'] as Timestamp?)?.toDate(),
    );
  }
}
