import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:lms_mobile_app/src/core/network/dio_error.dart';
import 'package:lms_mobile_app/src/core/config/constants/api_endpoints.dart';
import 'package:lms_mobile_app/src/core/utils/offline_test_mode.dart';
import 'package:lms_mobile_app/src/core/utils/local_storage.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../mappers/user_mapper.dart';
import '../models/user.dart';

class AuthRepositoryImpl implements AuthRepository {
  static const String _offlineTestPassword = 'bass123';

  final Dio _dio;

  AuthRepositoryImpl({required Dio dio}) : _dio = dio;

  /// Debug-only diagnostic logging for the offline tester flow. Compiled out of
  /// release builds so it never leaks to production.
  void _log(String message) {
    if (kDebugMode) {
      debugPrint('[AUTH][TESTER] $message');
    }
  }

  @override
  Future<UserEntity?> login(String email, String password) async {
    final cleanedEmail = email.trim().toLowerCase();
    if (cleanedEmail.isEmpty || password.isEmpty) {
      return null;
    }

    if (_canUseOfflineTestAccount(cleanedEmail, password)) {
      _log(
        'login -> offline test account used (${OfflineTestMode.describeContext()})',
      );
      final user = _buildOfflineTestUser();
      await LocalStorage.saveAuthSession(
        token: OfflineTestMode.offlineToken,
        user: user.toJson(),
      );
      return UserMapper.toDomain(user);
    }

    try {
      final response = await _dio.post(
        ApiEndpoints.login,
        data: {'email': cleanedEmail, 'password': password},
      );

      final payload = _decodeResponse(response.data);
      return _persistSessionFromPayload(payload);
    } on DioException catch (error) {
      throw Exception(friendlyDioMessage(error, 'Login gagal.'));
    }
  }

  @override
  Future<UserEntity?> register(
    String name,
    String email,
    String password,
    String classInterest, {
    required String dateOfBirth,
    required String gender,
    required String institutionName,
    required String occupation,
  }) async {
    final cleanedName = name.trim();
    final cleanedEmail = email.trim().toLowerCase();
    if (cleanedName.isEmpty || cleanedEmail.isEmpty || password.isEmpty) {
      return null;
    }

    try {
      final response = await _dio.post(
        ApiEndpoints.register,
        data: {
          'name': cleanedName,
          'email': cleanedEmail,
          'password': password,
          'password_confirmation': password,
          'class_interest': classInterest,
          'date_of_birth': dateOfBirth,
          'gender': gender,
          'institution_name': institutionName,
          'occupation': occupation,
        },
      );

      final payload = _decodeResponse(response.data);
      return _persistSessionFromPayload(payload);
    } on DioException catch (error) {
      throw Exception(friendlyDioMessage(error, 'Register gagal.'));
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _dio.post(ApiEndpoints.logout);
    } on DioException {
      // Best effort logout; local session still cleared below.
    }

    await LocalStorage.clearAuthSession();
  }

  @override
  Future<void> deleteAccount({required String password}) async {
    final token = LocalStorage.getAuthToken();
    if (token == null) {
      throw Exception('Sesi berakhir. Silakan masuk kembali.');
    }

    try {
      await _dio.delete(
        ApiEndpoints.deleteAccount,
        data: {'password': password},
      );
    } on DioException catch (error) {
      throw Exception(friendlyDioMessage(error, 'Gagal menghapus akun.'));
    }

    // Akun sudah dihapus di server → bersihkan sesi lokal apa pun yang tersisa.
    await LocalStorage.clearAuthSession();
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final storedUser = LocalStorage.getAuthUser();
    final token = LocalStorage.getAuthToken();

    _log('getCurrentUser -> ${OfflineTestMode.describeContext()}');

    if (storedUser == null) {
      return null;
    }

    if (OfflineTestMode.isActive() || _isOfflineTestUser(storedUser)) {
      return UserMapper.toDomain(User.fromJson(storedUser));
    }

    if (token == null) {
      return UserMapper.toDomain(User.fromJson(storedUser));
    }

    try {
      final response = await _dio.get(ApiEndpoints.getCurrentUser);
      final payload = _decodeResponse(response.data);
      final data = payload['data'];
      if (data is Map<String, dynamic>) {
        final user = _normalizeUser(
          data['user'] is Map<String, dynamic>
              ? data['user'] as Map<String, dynamic>
              : data,
        );
        await LocalStorage.saveAuthSession(token: token, user: user.toJson());
        return UserMapper.toDomain(user);
      }
    } on DioException catch (_) {
      await LocalStorage.clearAuthSession();
      return null;
    } catch (_) {
      return UserMapper.toDomain(User.fromJson(storedUser));
    }

    return UserMapper.toDomain(User.fromJson(storedUser));
  }

  @override
  Stream<UserEntity?> watchCurrentUser() async* {
    yield await getCurrentUser();
  }

  @override
  Future<UserEntity?> updateProfile({
    required String name,
    required String dateOfBirth,
    required String gender,
    required String institutionName,
    required String occupation,
    String? avatarFilePath,
  }) async {
    final token = LocalStorage.getAuthToken();
    if (token == null) {
      throw Exception('Sesi berakhir. Silakan masuk kembali.');
    }

    try {
      final fields = <String, dynamic>{
        'name': name.trim(),
        'date_of_birth': dateOfBirth,
        'gender': gender,
        'institution_name': institutionName.trim(),
        'occupation': occupation.trim(),
      };
      if (avatarFilePath != null && avatarFilePath.isNotEmpty) {
        fields['avatar'] = await MultipartFile.fromFile(
          avatarFilePath,
          filename: avatarFilePath.split(RegExp(r'[\\/]')).last,
        );
      }

      final response = await _dio.post(
        ApiEndpoints.updateProfile,
        data: FormData.fromMap(fields),
      );

      final payload = _decodeResponse(response.data);
      final data = payload['data'];
      if (data is Map<String, dynamic> &&
          data['user'] is Map<String, dynamic>) {
        final user = _normalizeUser(data['user'] as Map<String, dynamic>);
        await LocalStorage.saveAuthSession(token: token, user: user.toJson());
        return UserMapper.toDomain(user);
      }
      throw Exception('Respons profil tidak valid.');
    } on DioException catch (error) {
      throw Exception(friendlyDioMessage(error, 'Gagal memperbarui profil.'));
    }
  }

  @override
  Future<void> sendEmailOtp() async {
    try {
      await _dio.post(ApiEndpoints.sendEmailOtp);
    } on DioException catch (error) {
      throw Exception(friendlyDioMessage(error, 'Gagal mengirim kode.'));
    }
  }

  @override
  Future<UserEntity> verifyEmailOtp(String code) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.verifyEmailOtp,
        data: {'code': code.trim()},
      );

      final payload = _decodeResponse(response.data);
      final data = payload['data'];
      final token = LocalStorage.getAuthToken();
      if (data is Map<String, dynamic> &&
          data['user'] is Map<String, dynamic> &&
          token != null) {
        final user = _normalizeUser(data['user'] as Map<String, dynamic>);
        await LocalStorage.saveAuthSession(token: token, user: user.toJson());
        return UserMapper.toDomain(user);
      }
      throw Exception('Respons verifikasi tidak valid.');
    } on DioException catch (error) {
      throw Exception(friendlyDioMessage(error, 'Verifikasi gagal.'));
    }
  }

  @override
  Future<void> sendChangeEmailOtp(String newEmail) async {
    try {
      await _dio.post(
        ApiEndpoints.sendChangeEmailOtp,
        data: {'new_email': newEmail.trim().toLowerCase()},
      );
    } on DioException catch (error) {
      throw Exception(friendlyDioMessage(error, 'Gagal mengirim kode.'));
    }
  }

  @override
  Future<UserEntity> changeEmail({
    required String newEmail,
    required String code,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.changeEmail,
        data: {'new_email': newEmail.trim().toLowerCase(), 'code': code.trim()},
      );

      final payload = _decodeResponse(response.data);
      final data = payload['data'];
      final token = LocalStorage.getAuthToken();
      if (data is Map<String, dynamic> &&
          data['user'] is Map<String, dynamic> &&
          token != null) {
        final user = _normalizeUser(data['user'] as Map<String, dynamic>);
        await LocalStorage.saveAuthSession(token: token, user: user.toJson());
        return UserMapper.toDomain(user);
      }
      throw Exception('Respons ubah email tidak valid.');
    } on DioException catch (error) {
      throw Exception(friendlyDioMessage(error, 'Gagal mengubah email.'));
    }
  }

  @override
  Future<void> sendPasswordOtp(String email) async {
    try {
      await _dio.post(
        ApiEndpoints.sendPasswordOtp,
        data: {'email': email.trim().toLowerCase()},
      );
    } on DioException catch (error) {
      throw Exception(friendlyDioMessage(error, 'Gagal mengirim kode.'));
    }
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String code,
    required String password,
  }) async {
    try {
      await _dio.post(
        ApiEndpoints.resetPassword,
        data: {
          'email': email.trim().toLowerCase(),
          'code': code.trim(),
          'password': password,
          'password_confirmation': password,
        },
      );
    } on DioException catch (error) {
      throw Exception(friendlyDioMessage(error, 'Reset password gagal.'));
    }
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _dio.post(
        ApiEndpoints.changePassword,
        data: {
          'current_password': currentPassword,
          'password': newPassword,
          'password_confirmation': newPassword,
        },
      );
    } on DioException catch (error) {
      throw Exception(friendlyDioMessage(error, 'Gagal mengubah password.'));
    }
  }

  Future<UserEntity?> _persistSessionFromPayload(
    Map<String, dynamic> payload,
  ) async {
    final data = payload['data'];
    if (data is! Map<String, dynamic>) {
      throw Exception('Respons auth tidak valid.');
    }

    final token = data['token']?.toString() ?? '';
    final userData = data['user'];
    if (token.isEmpty || userData is! Map<String, dynamic>) {
      throw Exception('Token atau data user tidak ditemukan.');
    }

    final user = _normalizeUser(userData);
    await LocalStorage.saveAuthSession(token: token, user: user.toJson());
    return UserMapper.toDomain(user);
  }

  // Delegate to User.fromJson so ALL profile fields (date_of_birth, gender,
  // institution_name, occupation, avatar_url, created_at, …) survive the
  // session round-trip — not just id/name/email/role.
  User _normalizeUser(Map<String, dynamic> json) => User.fromJson(json);

  Map<String, dynamic> _decodeResponse(dynamic body) {
    if (body is Map<String, dynamic>) {
      return body;
    }
    if (body is Map) {
      return body.map((key, value) => MapEntry(key.toString(), value));
    }
    return <String, dynamic>{};
  }

  bool _canUseOfflineTestAccount(String email, String password) {
    return _isOfflineTestEmail(email) && password == _offlineTestPassword;
  }

  bool _isOfflineTestUser(Map<String, dynamic> user) {
    final email = user['email']?.toString().trim().toLowerCase();
    return _isOfflineTestEmail(email);
  }

  bool _isOfflineTestEmail(String? email) {
    if (email == null) {
      return false;
    }

    return email == OfflineTestMode.offlineEmail ||
        email == OfflineTestMode.offlineEmailAlias;
  }

  User _buildOfflineTestUser() {
    return User(
      id: '999',
      name: 'Bass Tester',
      email: OfflineTestMode.offlineEmail,
      role: 'participant',
      roles: const ['participant'],
    );
  }
}
