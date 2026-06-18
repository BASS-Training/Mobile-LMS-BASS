import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String role;
  final List<String> roles;

  // Profil — opsional.
  final String? dateOfBirth; // 'Y-m-d'
  final String? gender; // 'male' | 'female'
  final String? institutionName;
  final String? occupation;
  final String? registrationProgram; // 'regular' | 'avpn_ai'
  final String? avpnVerificationStatus;
  final String? joinedAt; // ISO 8601

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.roles = const [],
    this.dateOfBirth,
    this.gender,
    this.institutionName,
    this.occupation,
    this.registrationProgram,
    this.avpnVerificationStatus,
    this.joinedAt,
  });

  bool get isAvpn => registrationProgram == 'avpn_ai';

  bool hasRole(String value) => roles.contains(value) || role == value;

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    role,
    roles,
    dateOfBirth,
    gender,
    institutionName,
    occupation,
    registrationProgram,
    avpnVerificationStatus,
    joinedAt,
  ];
}
