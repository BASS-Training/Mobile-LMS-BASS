import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../mappers/user_mapper.dart';
import '../models/user.dart';

class AuthRepositoryImpl implements AuthRepository {
  @override
  Future<UserEntity?> login(String email, String password) async {
    // Basic validation
    if (email.isEmpty || password.isEmpty) {
      return null;
    }

    if (!_isValidEmail(email)) {
      return null;
    }

    if (password.length < 6) {
      return null;
    }

    // Simulate successful login
    final user = User(
      id: '${DateTime.now().millisecondsSinceEpoch}',
      name: email.split('@')[0].replaceAll('.', ' ').toUpperCase(),
      email: email,
    );

    return UserMapper.toDomain(user);
  }

  @override
  Future<void> logout() async {
    // Implement logout logic if needed
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    // Implement get current user logic if needed
    return null;
  }

  bool _isValidEmail(String email) {
    final pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    final regex = RegExp(pattern);
    return regex.hasMatch(email);
  }
}
