import 'package:cloud_firestore/cloud_firestore.dart';

class Controlleur {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String lineId;
  final String lineName;
  final String photoBase64;
  final String matricule;
  final String grade;
  final bool isActive;
  final DateTime? createdAt;

  const Controlleur({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.lineId,
    required this.lineName,
    required this.photoBase64,
    required this.matricule,
    required this.grade,
    required this.isActive,
    this.createdAt,
  });

  String get fullName => '$firstName $lastName';

  factory Controlleur.fromFirestore(DocumentSnapshot doc) {
    final m = doc.data() as Map<String, dynamic>;
    return Controlleur(
      id: doc.id,
      firstName: m['firstName'] ?? '',
      lastName: m['lastName'] ?? '',
      email: m['email'] ?? '',
      phone: m['phone'] ?? '',
      lineId: m['lineId'] ?? '',
      lineName: m['lineName'] ?? '',
      photoBase64: m['photoBase64'] ?? '',
      matricule: m['matricule'] ?? '',
      grade: m['grade'] ?? 'Contrôleur',
      isActive: m['isActive'] ?? true,
      createdAt: (m['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
    'firstName': firstName,
    'lastName': lastName,
    'email': email,
    'phone': phone,
    'lineId': lineId,
    'lineName': lineName,
    'photoBase64': photoBase64,
    'matricule': matricule,
    'grade': grade,
    'isActive': isActive,
    'createdAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  };
}
