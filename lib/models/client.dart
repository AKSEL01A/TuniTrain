import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tuni_train/models/user.dart';

class Client extends User {
  List<String> favoritePlaces;
  int loyaltyPoints;

  Client({
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.email,
    required super.phone,
    required super.createdAt,
    super.isActive,
    this.favoritePlaces = const [],
    this.loyaltyPoints = 0,
  });

  factory Client.fromMap(Map<String, dynamic> data, String id) {
    DateTime parseCreatedAt(dynamic value) {
      try {
        if (value == null) return DateTime.now();

        if (value is Timestamp) {
          return value.toDate();
        }

        if (value is String) {
          return DateTime.parse(value);
        }

        return DateTime.now();
      } catch (_) {
        return DateTime.now();
      }
    }

    return Client(
      id: id,
      firstName: (data['firstName'] ?? '') as String,
      lastName: (data['lastName'] ?? '') as String,
      email: (data['email'] ?? '') as String,
      phone: (data['phone'] ?? '') as String,
      createdAt: parseCreatedAt(data['createdAt']),
      isActive: (data['isActive'] ?? true) as bool,
      favoritePlaces: List<String>.from(data['favoritePlaces'] ?? []),
      loyaltyPoints: (data['loyaltyPoints'] ?? 0) as int,
    );
  }
  // =========================
  // Methods
  // =========================

  void addFavoritePlace(String placeId) {
    favoritePlaces.add(placeId);
  }

  void removeFavoritePlace(String placeId) {
    favoritePlaces.remove(placeId);
  }

  void addPoints(int points) {
    loyaltyPoints += points;
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      "favoritePlaces": favoritePlaces,
      "loyaltyPoints": loyaltyPoints,
    };
  }
}
