import 'package:equatable/equatable.dart';

/// Objek bisnis murni untuk pengguna (Domain). Tanpa logika JSON/Flutter —
/// pemetaan dari respons API dilakukan di lapisan Data (`User` model +
/// `user_mapper`). Contoh entity kanonik. Lihat ARCHITECTURE.md §3.
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
  final String? avatarUrl; // absolute URL foto profil, atau null

  // Verifikasi email (soft enforcement).
  final bool emailVerified;
  final bool mustVerifyEmail; // akun baru wajib verifikasi sebelum pakai app

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
    this.avatarUrl,
    this.emailVerified = false,
    this.mustVerifyEmail = false,
  });

  bool get isAvpn => registrationProgram == 'avpn_ai';

  /// Saran (nudge) verifikasi untuk akun mana pun yang belum verified.
  bool get shouldNudgeVerifyEmail => !emailVerified;

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
    avatarUrl,
    emailVerified,
    mustVerifyEmail,
  ];
}
