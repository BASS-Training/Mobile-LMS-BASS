import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<UserEntity?> call(String email, String password) async {
    return await repository.login(email, password);
  }
}

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<UserEntity?> call(
    String name,
    String email,
    String password,
    String role,
  ) async {
    return await repository.register(name, email, password, role);
  }
}

class LogoutUseCase {
  final AuthRepository repository;

  LogoutUseCase(this.repository);

  Future<void> call() async {
    return await repository.logout();
  }
}

class GetCurrentUserUseCase {
  final AuthRepository repository;

  GetCurrentUserUseCase(this.repository);

  Future<UserEntity?> call() async {
    return await repository.getCurrentUser();
  }
}
