import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:lms_mobile_app/src/core/config/constants/api_endpoints.dart';
import 'package:lms_mobile_app/src/core/config/flavor_config.dart';
import 'package:lms_mobile_app/src/core/utils/local_storage.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../mappers/user_mapper.dart';
import '../models/user.dart';

class AuthRepositoryImpl implements AuthRepository {
  final http.Client _client;

  AuthRepositoryImpl({http.Client? client}) : _client = client ?? http.Client();

  @override
  Future<UserEntity?> login(String email, String password) async {
    final cleanedEmail = email.trim().toLowerCase();
    if (cleanedEmail.isEmpty || password.isEmpty) {
      return null;
    }

    final response = await _client.post(
      Uri.parse('${FlavorConfig.instance.apiBaseUrl}${ApiEndpoints.login}'),
      headers: _jsonHeaders(),
      body: jsonEncode({'email': cleanedEmail, 'password': password}),
    );

    final payload = _decodeResponse(response.body);
    if (!_isSuccessStatus(response.statusCode)) {
      throw Exception(_extractMessage(payload, 'Login gagal.'));
    }

    return _persistSessionFromPayload(payload);
  }

  @override
  Future<UserEntity?> register(
    String name,
    String email,
    String password,
    String role,
  ) async {
    final cleanedName = name.trim();
    final cleanedEmail = email.trim().toLowerCase();
    if (cleanedName.isEmpty || cleanedEmail.isEmpty || password.isEmpty) {
      return null;
    }

    final response = await _client.post(
      Uri.parse('${FlavorConfig.instance.apiBaseUrl}${ApiEndpoints.register}'),
      headers: _jsonHeaders(),
      body: jsonEncode({
        'name': cleanedName,
        'email': cleanedEmail,
        'password': password,
        'role': role,
      }),
    );

    final payload = _decodeResponse(response.body);
    if (!_isSuccessStatus(response.statusCode)) {
      throw Exception(_extractMessage(payload, 'Register gagal.'));
    }

    return _persistSessionFromPayload(payload);
  }

  @override
  Future<void> logout() async {
    final token = LocalStorage.getAuthToken();
    if (token != null) {
      try {
        await _client.post(
          Uri.parse(
            '${FlavorConfig.instance.apiBaseUrl}${ApiEndpoints.logout}',
          ),
          headers: _jsonHeaders(token: token),
        );
      } catch (_) {
        // Best effort logout; local session still cleared below.
      }
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
      final response = await _client.get(
        Uri.parse(
          '${FlavorConfig.instance.apiBaseUrl}${ApiEndpoints.getCurrentUser}',
        ),
        headers: _jsonHeaders(token: token),
      );

      final payload = _decodeResponse(response.body);
      if (!_isSuccessStatus(response.statusCode)) {
        await LocalStorage.clearAuthSession();
        return null;
      }

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

  Map<String, dynamic> _decodeResponse(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      if (decoded is Map) {
        return decoded.map((key, value) => MapEntry(key.toString(), value));
      }
    } catch (_) {}
    return <String, dynamic>{};
  }

  Map<String, String> _jsonHeaders({String? token}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  bool _isSuccessStatus(int statusCode) {
    return statusCode == 200 || statusCode == 201;
  }

  String _extractMessage(Map<String, dynamic> payload, String fallback) {
    final message = payload['message']?.toString().trim();
    return message != null && message.isNotEmpty ? message : fallback;
  }
}
