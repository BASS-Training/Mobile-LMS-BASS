import 'package:equatable/equatable.dart';

/// Token value object untuk auth token
class AuthToken extends Equatable {
  final String token;
  final DateTime? expiresAt;

  const AuthToken({required this.token, this.expiresAt});

  /// Check apakah token sudah expired
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// Check apakah token valid (not expired)
  bool get isValid => !isExpired;

  @override
  List<Object?> get props => [token, expiresAt];
}
