import 'user.dart';

class Client extends User {
  List<String> favoritePlaces;
  int loyaltyPoints;

  Client({
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.email,
    required super.phone,
    required super.password,
    required super.createdAt,
    super.isActive,
    this.favoritePlaces = const [],
    this.loyaltyPoints = 0,
  });

  // =========================
  // Favorite Places
  // =========================
  void addFavoritePlace(String placeId) {
    favoritePlaces.add(placeId);
  }

  void removeFavoritePlace(String placeId) {
    favoritePlaces.remove(placeId);
  }

  // =========================
  // Loyalty Points
  // =========================
  void addPoints(int points) {
    loyaltyPoints += points;
  }

  // =========================
  // Ticket Features
  // =========================

  Ticket scanQRCode(String code) {
    return Ticket.fromQRCode(code);
  }

  bool verifyTicket(int ticketId) {
    return ticketId > 0;
  }

  // =========================
  // Mapping
  // =========================
  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      "favoritePlaces": favoritePlaces,
      "loyaltyPoints": loyaltyPoints,
    };
  }
}

// =========================
// Ticket Class (same file)
// =========================
class Ticket {
  final int id;
  final int userId;
  final bool isValid;

  Ticket({required this.id, required this.userId, required this.isValid});

  factory Ticket.fromQRCode(String code) {
    return Ticket(id: code.hashCode, userId: 0, isValid: true);
  }
}
