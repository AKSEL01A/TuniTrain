abstract class User {
  final String id;
  String firstName;
  String lastName;
  String email;
  String phone;
  String password;
  DateTime createdAt;
  bool isActive;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.password,
    required this.createdAt,
    this.isActive = true,
  });

  String get fullName => "$firstName $lastName";

  void activate() => isActive = true;

  void deactivate() => isActive = false;

  void updateProfile({
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
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
      "password": password,
      "createdAt": createdAt.toIso8601String(),
      "isActive": isActive,
    };
  }
}
