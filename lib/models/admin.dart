import 'user.dart';

class Admin extends User {
  String role;
  List<String> permissions;

  Admin({
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.email,
    required super.phone,
    required super.createdAt,
    super.isActive,
    this.role = "admin",
    this.permissions = const [],
  });

  // =========================
  // Methods
  // =========================

  void addPermission(String permission) {
    permissions.add(permission);
  }

  void removePermission(String permission) {
    permissions.remove(permission);
  }

  bool hasPermission(String permission) {
    return permissions.contains(permission);
  }

  @override
  Map<String, dynamic> toMap() {
    return {...super.toMap(), "role": role, "permissions": permissions};
  }
}
