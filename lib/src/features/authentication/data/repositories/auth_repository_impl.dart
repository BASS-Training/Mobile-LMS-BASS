import 'dart:async';

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
  final Duration _credentialRequestTimeout;
  int _authOperation = 0;
  CancelToken? _credentialCancelToken;

  AuthRepositoryImpl({
    required Dio dio,
    Duration credentialRequestTimeout = const Duration(seconds: 15),
  }) : _dio = dio,
       _credentialRequestTimeout = credentialRequestTimeout;

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

    final operation = ++_authOperation;
    final sessionRevision = LocalStorage.authSessionRevision;
    _credentialCancelToken?.cancel('Digantikan operasi auth baru.');
    final cancelToken = CancelToken();
    _credentialCancelToken = cancelToken;

    try {
      if (_canUseOfflineTestAccount(cleanedEmail, password)) {
        _log(
          'login -> offline test account used (${OfflineTestMode.describeContext()})',
        );
        final user = _buildOfflineTestUser();
        final saved = await LocalStorage.saveAuthSessionIfUnchanged(
          expectedRevision: sessionRevision,
          token: OfflineTestMode.offlineToken,
          user: user.toJson(),
        );
        return saved && operation == _authOperation
            ? UserMapper.toDomain(user)
            : null;
      }

      final response = await _sendCredentialRequest(
        ApiEndpoints.login,
        data: {'email': cleanedEmail, 'password': password},
        cancelToken: cancelToken,
      );

      final payload = _decodeResponse(response.data);
      return _persistSessionFromPayload(
        payload,
        operation: operation,
        sessionRevision: sessionRevision,
      );
    } on TimeoutException {
      if (operation == _authOperation) _authOperation++;
      rethrow;
    } on DioException catch (error) {
      throw Exception(friendlyDioMessage(error, 'Login gagal.'));
    } finally {
      if (identical(_credentialCancelToken, cancelToken)) {
        _credentialCancelToken = null;
      }
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

    final operation = ++_authOperation;
    final sessionRevision = LocalStorage.authSessionRevision;
    _credentialCancelToken?.cancel('Digantikan operasi auth baru.');
    final cancelToken = CancelToken();
    _credentialCancelToken = cancelToken;

    try {
      final response = await _sendCredentialRequest(
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
        cancelToken: cancelToken,
      );

      final payload = _decodeResponse(response.data);
      return _persistSessionFromPayload(
        payload,
        operation: operation,
        sessionRevision: sessionRevision,
      );
    } on TimeoutException {
      if (operation == _authOperation) _authOperation++;
      rethrow;
    } on DioException catch (error) {
      throw Exception(friendlyDioMessage(error, 'Register gagal.'));
    } finally {
      if (identical(_credentialCancelToken, cancelToken)) {
        _credentialCancelToken = null;
      }
    }
  }

  @override
  Future<void> logout() async {
    final token = LocalStorage.getAuthToken();
    _authOperation++;
    _credentialCancelToken?.cancel('Logout.');
    _credentialCancelToken = null;

    // Keluar secara lokal lebih dulu supaya response auth yang masih berjalan
    // langsung kehilangan revision dan tidak dapat menyimpan sesi lagi.
    await LocalStorage.clearAuthSession();

    unawaited(_revokeRemoteSession(token));
  }

  Future<void> _revokeRemoteSession(String? token) async {
    try {
      await _dio.post(
        ApiEndpoints.logout,
        options: token == null
            ? null
            : Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } catch (_) {
      // Best effort logout; sesi lokal sudah dibersihkan di atas.
    }
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final operation = _authOperation;
    final sessionRevision = LocalStorage.authSessionRevision;
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
      if (operation != _authOperation) return null;

      final payload = _decodeResponse(response.data);
      final data = payload['data'];
      if (data is Map<String, dynamic>) {
        final user = _normalizeUser(
          data['user'] is Map<String, dynamic>
              ? data['user'] as Map<String, dynamic>
              : data,
        );
        final saved = await LocalStorage.saveAuthSessionIfUnchanged(
          expectedRevision: sessionRevision,
          token: token,
          user: user.toJson(),
        );
        return saved && operation == _authOperation
            ? UserMapper.toDomain(user)
            : null;
      }
    } on DioException catch (_) {
      if (operation == _authOperation) {
        await LocalStorage.clearAuthSessionIfUnchanged(
          expectedRevision: sessionRevision,
        );
      }
      return null;
    } catch (_) {
      if (operation != _authOperation ||
          LocalStorage.authSessionRevision != sessionRevision) {
        return null;
      }
      return UserMapper.toDomain(User.fromJson(storedUser));
    }

    if (operation != _authOperation ||
        LocalStorage.authSessionRevision != sessionRevision) {
      return null;
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
    final sessionRevision = LocalStorage.authSessionRevision;
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

      if (LocalStorage.authSessionRevision != sessionRevision) {
        throw Exception('Sesi berubah. Silakan coba lagi.');
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
        final saved = await LocalStorage.saveAuthSessionIfUnchanged(
          expectedRevision: sessionRevision,
          token: token,
          user: user.toJson(),
        );
        if (saved) return UserMapper.toDomain(user);
        throw Exception('Sesi berubah. Silakan coba lagi.');
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
    final sessionRevision = LocalStorage.authSessionRevision;
    final token = LocalStorage.getAuthToken();
    if (token == null) {
      throw Exception('Sesi berakhir. Silakan masuk kembali.');
    }

    try {
      final response = await _dio.post(
        ApiEndpoints.verifyEmailOtp,
        data: {'code': code.trim()},
      );

      final payload = _decodeResponse(response.data);
      final data = payload['data'];
      if (data is Map<String, dynamic> &&
          data['user'] is Map<String, dynamic>) {
        final user = _normalizeUser(data['user'] as Map<String, dynamic>);
        final saved = await LocalStorage.saveAuthSessionIfUnchanged(
          expectedRevision: sessionRevision,
          token: token,
          user: user.toJson(),
        );
        if (saved) return UserMapper.toDomain(user);
        throw Exception('Sesi berubah. Silakan coba lagi.');
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
    final sessionRevision = LocalStorage.authSessionRevision;
    final token = LocalStorage.getAuthToken();
    if (token == null) {
      throw Exception('Sesi berakhir. Silakan masuk kembali.');
    }

    try {
      final response = await _dio.post(
        ApiEndpoints.changeEmail,
        data: {'new_email': newEmail.trim().toLowerCase(), 'code': code.trim()},
      );

      final payload = _decodeResponse(response.data);
      final data = payload['data'];
      if (data is Map<String, dynamic> &&
          data['user'] is Map<String, dynamic>) {
        final user = _normalizeUser(data['user'] as Map<String, dynamic>);
        final saved = await LocalStorage.saveAuthSessionIfUnchanged(
          expectedRevision: sessionRevision,
          token: token,
          user: user.toJson(),
        );
        if (saved) return UserMapper.toDomain(user);
        throw Exception('Sesi berubah. Silakan coba lagi.');
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

  Future<Response<dynamic>> _sendCredentialRequest(
    String path, {
    required Map<String, dynamic> data,
    required CancelToken cancelToken,
  }) {
    return _dio
        .post<dynamic>(path, data: data, cancelToken: cancelToken)
        .timeout(
          _credentialRequestTimeout,
          onTimeout: () {
            cancelToken.cancel('Auth request timeout.');
            throw TimeoutException('Auth request timeout.');
          },
        );
  }

  Future<UserEntity?> _persistSessionFromPayload(
    Map<String, dynamic> payload, {
    required int operation,
    required int sessionRevision,
  }) async {
    if (operation != _authOperation) return null;

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
    final saved = await LocalStorage.saveAuthSessionIfUnchanged(
      expectedRevision: sessionRevision,
      token: token,
      user: user.toJson(),
    );
    return saved && operation == _authOperation
        ? UserMapper.toDomain(user)
        : null;
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
