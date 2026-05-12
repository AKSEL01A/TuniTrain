abstract class User {
  final String id;
  String firstName;
  String lastName;
  String email;
  String phone;
  DateTime createdAt;
  bool isActive;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.createdAt,
    this.isActive = true,
  });

  // =========================
  // Methods
  // =========================

  String get fullName => "$firstName $lastName";

  void activate() {
    isActive = true;
  }

  void deactivate() {
    isActive = false;
  }

  void updateProfile({
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? imageUrl,
  }) {
    this.firstName = firstName ?? this.firstName;
    this.lastName = lastName ?? this.lastName;
    this.email = email ?? this.email;
    this.phone = phone ?? this.phone;
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "firstName": firstName,
      "lastName": lastName,
      "email": email,
      "phone": phone,
      "createdAt": createdAt.toIso8601String(),
      "isActive": isActive,
    };
  }
}
