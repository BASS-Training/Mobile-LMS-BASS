import 'package:dio/dio.dart';
import 'package:lms_mobile_app/src/core/config/constants/api_endpoints.dart';
import 'package:lms_mobile_app/src/core/utils/local_storage.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../mappers/user_mapper.dart';
import '../models/user.dart';

class AuthRepositoryImpl implements AuthRepository {
  final Dio _dio;

  AuthRepositoryImpl({required Dio dio}) : _dio = dio;

  @override
  Future<UserEntity?> login(String email, String password) async {
    final cleanedEmail = email.trim().toLowerCase();
    if (cleanedEmail.isEmpty || password.isEmpty) {
      return null;
    }

    try {
      final response = await _dio.post(
        ApiEndpoints.login,
        data: {'email': cleanedEmail, 'password': password},
      );

      final payload = _decodeResponse(response.data);
      return _persistSessionFromPayload(payload);
    } on DioException catch (error) {
      throw Exception(_extractMessageFromException(error, 'Login gagal.'));
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
      throw Exception(_extractMessageFromException(error, 'Register gagal.'));
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
  Future<UserEntity?> getCurrentUser() async {
    final storedUser = LocalStorage.getAuthUser();
    final token = LocalStorage.getAuthToken();

    if (storedUser == null) {
      return null;
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

  User _normalizeUser(Map<String, dynamic> json) {
    final rawRoles = json['roles'];
    final roles = rawRoles is List
        ? rawRoles
              .map((value) => value.toString())
              .where((value) => value.isNotEmpty)
              .toList()
        : <String>[];

    return User(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role:
          json['primary_role']?.toString() ??
          json['role']?.toString() ??
          'participant',
      roles: roles,
    );
  }

  Map<String, dynamic> _decodeResponse(dynamic body) {
    if (body is Map<String, dynamic>) {
      return body;
    }
    if (body is Map) {
      return body.map((key, value) => MapEntry(key.toString(), value));
    }
    return <String, dynamic>{};
  }

  String _extractMessageFromException(DioException error, String fallback) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message']?.toString().trim();
      if (message != null && message.isNotEmpty) {
        return message;
      }
    }

    final message = error.message?.trim();
    return message != null && message.isNotEmpty ? message : fallback;
  }
}
