import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String role;
  final List<String> roles;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.roles = const [],
  });

  bool hasRole(String value) => roles.contains(value) || role == value;

  @override
  List<Object?> get props => [id, name, email, role, roles];
}
