class User {
  final String id;
  final String name;
  final String email;
  final String role;
  final List<String> roles;

  // Profil — opsional, dikirim backend di /auth/me & login.
  final String? dateOfBirth; // 'Y-m-d'
  final String? gender; // 'male' | 'female'
  final String? institutionName;
  final String? occupation;
  final String? registrationProgram; // 'regular' | 'avpn_ai'
  final String? avpnVerificationStatus; // pending | verified | not_required
  final String? joinedAt; // ISO 8601 (created_at)
  final String? avatarUrl; // absolute URL foto profil, atau null

  // Verifikasi email (soft enforcement). Backend mengirim ketiganya.
  final bool emailVerified;
  final bool mustVerifyEmail; // akun baru wajib verifikasi sebelum pakai app

  User({
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

  factory User.fromJson(Map<String, dynamic> json) {
    final rawRoles = json['roles'];
    final roles = rawRoles is List
        ? rawRoles
              .map((value) => value.toString())
              .where((value) => value.isNotEmpty)
              .toList()
        : <String>[];

    String? str(dynamic v) {
      if (v == null) return null;
      final s = v.toString().trim();
      return s.isEmpty ? null : s;
    }

    bool boolOf(dynamic v) {
      if (v is bool) return v;
      final s = v?.toString().toLowerCase().trim();
      return s == 'true' || s == '1';
    }

    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['primary_role'] ?? json['role'] ?? 'participant',
      roles: roles,
      dateOfBirth: str(json['date_of_birth']),
      gender: str(json['gender']),
      institutionName: str(json['institution_name']),
      occupation: str(json['occupation']),
      registrationProgram: str(json['registration_program']),
      avpnVerificationStatus: str(json['avpn_verification_status']),
      joinedAt: str(json['created_at'] ?? json['joined_at']),
      avatarUrl: str(json['avatar_url'] ?? json['avatarUrl']),
      emailVerified: boolOf(json['email_verified']),
      mustVerifyEmail: boolOf(json['must_verify_email']),
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
      'date_of_birth': dateOfBirth,
      'gender': gender,
      'institution_name': institutionName,
      'occupation': occupation,
      'registration_program': registrationProgram,
      'avpn_verification_status': avpnVerificationStatus,
      'created_at': joinedAt,
      'avatar_url': avatarUrl,
      'email_verified': emailVerified,
      'must_verify_email': mustVerifyEmail,
    };
  }
}
