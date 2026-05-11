import 'package:dartz/dartz.dart';
import 'package:lms_mobile_app/src/core/error/failures.dart';
import 'package:lms_mobile_app/src/features/authentication/data/datasources/auth_remote_data_source.dart';
import 'package:lms_mobile_app/src/features/authentication/data/mappers/user_mapper.dart';
import 'package:lms_mobile_app/src/features/authentication/domain/entities/user_session_entity.dart';
import 'package:lms_mobile_app/src/features/authentication/domain/repositories/auth_repository.dart';

/// Implementation AuthRepository menggunakan remote data source
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<UserSessionEntity?> login(String email, String password) async {
    try {
      final userModel = await remoteDataSource.login(email, password);
      return UserMapper.toEntity(userModel);
    } on Exception catch (e) {
      return null;
    }
  }

  @override
  Future<void> logout() async {
    try {
      await remoteDataSource.logout();
    } on Exception {
      // Handle error if needed
    }
  }

  @override
  Future<UserSessionEntity?> getCurrentUser() async {
    try {
      final userModel = await remoteDataSource.getCurrentUser();
      return userModel != null ? UserMapper.toEntity(userModel) : null;
    } on Exception {
      return null;
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    try {
      return await remoteDataSource.isSessionValid();
    } on Exception {
      return false;
    }
  }
}
