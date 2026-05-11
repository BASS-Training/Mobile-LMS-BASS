import 'package:lms_mobile_app/src/features/authentication/data/models/user_model.dart';

/// Contract untuk remote authentication data source
abstract class AuthRemoteDataSource {
  /// Login dan return user data dari remote
  Future<UserModel> login(String email, String password);

  /// Logout dari remote
  Future<void> logout();

  /// Get current user dari remote
  Future<UserModel?> getCurrentUser();

  /// Check session validity di remote
  Future<bool> isSessionValid();
}

/// Implementation menggunakan dummy data (untuk testing)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  @override
  Future<UserModel> login(String email, String password) async {
    // TODO: Implement actual API call
    // For now, return dummy data
    if (email == 'test@example.com' && password == 'password123') {
      return UserModel(id: '1', name: 'Test User', email: email);
    }
    throw Exception('Invalid credentials');
  }

  @override
  Future<void> logout() async {
    // TODO: Implement actual API call
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    // TODO: Implement actual API call
    return null;
  }

  @override
  Future<bool> isSessionValid() async {
    // TODO: Implement actual API call
    return false;
  }
}
