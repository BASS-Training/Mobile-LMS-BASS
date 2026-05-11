import 'user_session_entity.dart';

/// Repository contract untuk authentication
abstract class AuthRepository {
  /// Login dengan email dan password
  /// Returns UserSessionEntity jika berhasil
  Future<UserSessionEntity?> login(String email, String password);

  /// Logout user
  Future<void> logout();

  /// Get current user session
  /// Returns null jika tidak ada session
  Future<UserSessionEntity?> getCurrentUser();

  /// Check apakah user sudah login
  Future<bool> isLoggedIn();
}
