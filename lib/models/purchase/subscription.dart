import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tuni_train/models/purchase/purchase.dart';

enum SubscriptionStatus { active, expired, pending, blocked }

enum SubscriptionType { weekly, monthly, annual }

class Subscription extends Purchase {
  final SubscriptionType type;
  final bool isStudent;
  final SubscriptionStatus status;
  final String lineId;
  final String fromStation;
  final String toStation;

  // Student fields
  final String? university;
  final String? studentId;
  final String? studentCardUrl;

  // User photo
  final String? photoUrl;

  const Subscription({
    super.id,
    super.startDate,
    super.endDate,
    super.firstName,
    super.lastName,
    super.email,
    super.phoneNumber,
    super.price,
    super.qrCode,
    required this.type,
    required this.isStudent,
    required this.status,
    required this.lineId,
    required this.fromStation,
    required this.toStation,
    this.university,
    this.studentId,
    this.studentCardUrl,
    this.photoUrl,
  });

  static DateTime endDateFor(SubscriptionType type, DateTime start) {
    switch (type) {
      case SubscriptionType.weekly:
        return start.add(const Duration(days: 7));
      case SubscriptionType.monthly:
        return DateTime(start.year, start.month + 1, start.day);
      case SubscriptionType.annual:
        return DateTime(start.year + 1, start.month, start.day);
    }
  }

  // Price will come from Firestore — this is just a fallback
  static double fallbackPrice(SubscriptionType type, bool isStudent) {
    const base = {
      SubscriptionType.weekly: 8.0,
      SubscriptionType.monthly: 28.0,
      SubscriptionType.annual: 280.0,
    };
    return isStudent ? base[type]! * 0.5 : base[type]!;
  }

  Map<String, dynamic> toFirestore() => {
    'type': type.name,
    'isStudent': isStudent,
    'status': status.name,
    'lineId': lineId,
    'fromStation': fromStation,
    'toStation': toStation,
    'firstName': firstName,
    'lastName': lastName,
    'email': email,
    'phoneNumber': phoneNumber,
    'price': price,
    'qrCode': qrCode,
    'startDate': startDate != null ? Timestamp.fromDate(startDate!) : null,
    'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
    'university': university,
    'studentId': studentId,
    'studentCardUrl': studentCardUrl,
    'photoUrl': photoUrl,
    'createdAt': FieldValue.serverTimestamp(),
  };

  factory Subscription.fromFirestore(DocumentSnapshot doc) {
    final m = doc.data() as Map<String, dynamic>;
    return Subscription(
      id: int.tryParse(doc.id) ?? 0,
      type: SubscriptionType.values.firstWhere(
        (e) => e.name == (m['type'] ?? 'monthly'),
        orElse: () => SubscriptionType.monthly,
      ),
      isStudent: m['isStudent'] ?? false,
      status: SubscriptionStatus.values.firstWhere(
        (e) => e.name == (m['status'] ?? 'pending'),
        orElse: () => SubscriptionStatus.pending,
      ),
      lineId: m['lineId'] ?? '',
      fromStation: m['fromStation'] ?? '',
      toStation: m['toStation'] ?? '',
      firstName: m['firstName'],
      lastName: m['lastName'],
      email: m['email'],
      phoneNumber: m['phoneNumber'],
      price: (m['price'] as num?)?.toDouble(),
      qrCode: m['qrCode'],
      startDate: (m['startDate'] as Timestamp?)?.toDate(),
      endDate: (m['endDate'] as Timestamp?)?.toDate(),
      university: m['university'],
      studentId: m['studentId'],
      studentCardUrl: m['studentCardUrl'],
      photoUrl: m['photoUrl'],
    );
  }

  // Helpers
  String get statusLabel {
    switch (status) {
      case SubscriptionStatus.active:
        return 'Actif';
      case SubscriptionStatus.pending:
        return 'En attente';
      case SubscriptionStatus.expired:
        return 'Expiré';
      case SubscriptionStatus.blocked:
        return 'Bloqué';
    }
  }

  bool get isActive => status == SubscriptionStatus.active;
  int get remainingDays =>
      endDate == null ? 0 : endDate!.difference(DateTime.now()).inDays;
}
