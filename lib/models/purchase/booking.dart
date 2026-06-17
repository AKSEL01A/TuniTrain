import 'package:cloud_firestore/cloud_firestore.dart';

class Booking {
  final String id;
  final String userId;
  final String type; // 'car' | 'place'
  final String itemId;
  final String title;
  final String imageUrl;
  final double amount;
  final String method; // méthode de paiement
  final String status; // pending | confirmed | cancelled
  final DateTime createdAt;
  final DateTime updatedAt;

  const Booking({
    required this.id,
    required this.userId,
    required this.type,
    required this.itemId,
    required this.title,
    required this.imageUrl,
    required this.amount,
    required this.method,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Booking.fromFirestore(DocumentSnapshot doc) {
    final m = doc.data() as Map<String, dynamic>;
    return Booking(
      id: doc.id,
      userId: m['userId'] as String? ?? '',
      type: m['type'] as String? ?? '',
      itemId: m['itemId'] as String? ?? '',
      title: m['title'] as String? ?? '',
      imageUrl: m['imageUrl'] as String? ?? '',
      amount: (m['amount'] as num?)?.toDouble() ?? 0,
      method: m['method'] as String? ?? '',
      status: m['status'] as String? ?? 'pending',
      createdAt: (m['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (m['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  String get statusLabel => switch (status) {
    'confirmed' => 'Confirmée',
    'cancelled' => 'Annulée',
    _ => 'En attente',
  };

  bool get isCar => type == 'car';
  bool get isPlace => type == 'place';
}
