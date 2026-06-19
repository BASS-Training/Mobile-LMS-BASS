import '../entities/user_entity.dart';

/// Kontrak (Domain) untuk autentikasi: login, registrasi, logout, ambil &
/// pantau user saat ini. Implementasinya (`AuthRepositoryImpl`) ada di lapisan
/// Data dan memakai dio + LocalStorage. UI/usecase bergantung pada kontrak ini,
/// bukan implementasinya. Lihat ARCHITECTURE.md §3.
abstract class AuthRepository {
  Future<UserEntity?> login(String email, String password);
  Future<UserEntity?> register(
    String name,
    String email,
    String password,
    String classInterest, {
    required String dateOfBirth,
    required String gender,
    required String institutionName,
    required String occupation,
  });
  Future<void> logout();
  Future<UserEntity?> getCurrentUser();
  Stream<UserEntity?> watchCurrentUser();

  /// Update the current user's profile (data dasar + optional avatar photo).
  /// Returns the updated user, with the local session refreshed.
  Future<UserEntity?> updateProfile({
    required String name,
    required String dateOfBirth,
    required String gender,
    required String institutionName,
    required String occupation,
    String? avatarFilePath,
  });
}
