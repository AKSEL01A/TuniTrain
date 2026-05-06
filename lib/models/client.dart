import 'user.dart';

class Client extends User {
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
    this.loyaltyPoints = 0,
  });

  void addPoints(int points) {
    loyaltyPoints += points;
  }

  @override
  Map<String, dynamic> toMap() {
    return {...super.toMap(), "loyaltyPoints": loyaltyPoints};
  }
}
