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

  /// Hapus permanen akun user saat ini (butuh konfirmasi [password]). Setelah
  /// server menghapus akun & seluruh data pribadinya, sesi lokal dibersihkan.
  /// Dipakai fitur "Hapus Akun" — wajib untuk App Store.
  Future<void> deleteAccount({required String password});

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

  // ── Verifikasi email (butuh login) ──────────────────────────────────────
  /// Kirim/kirim ulang OTP verifikasi ke email user saat ini.
  Future<void> sendEmailOtp();

  /// Verifikasi OTP email; mengembalikan user terbaru (email_verified=true).
  Future<UserEntity> verifyEmailOtp(String code);

  /// Kirim OTP konfirmasi ke EMAIL BARU (email akun belum berubah di sini).
  Future<void> sendChangeEmailOtp(String newEmail);

  /// Verifikasi OTP email baru; memindahkan email akun & mengembalikan user
  /// terbaru (email baru, email_verified=true). Sesi lokal ikut diperbarui.
  Future<UserEntity> changeEmail({
    required String newEmail,
    required String code,
  });

  // ── Lupa & ganti password ───────────────────────────────────────────────
  /// Kirim OTP reset password (publik). Selalu sukses (tidak bocorkan email).
  Future<void> sendPasswordOtp(String email);

  /// Reset password memakai OTP (publik).
  Future<void> resetPassword({
    required String email,
    required String code,
    required String password,
  });

  /// Ganti password saat sudah login (butuh password lama).
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });
}
