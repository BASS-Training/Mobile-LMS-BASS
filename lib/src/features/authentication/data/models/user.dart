class User {
  final String id;
  final String name;
  final String email;
  final String role;
  final List<String> roles;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.roles = const [],
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final rawRoles = json['roles'];
    final roles = rawRoles is List
        ? rawRoles
              .map((value) => value.toString())
              .where((value) => value.isNotEmpty)
              .toList()
        : <String>[];

    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['primary_role'] ?? json['role'] ?? 'participant',
      roles: roles,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'primary_role': role,
      'roles': roles,
    };
  }
}
