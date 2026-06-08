import 'package:lms_mobile_app/src/features/authentication/domain/entities/user_entity.dart';
import 'package:lms_mobile_app/src/features/authentication/domain/repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<UserEntity?> call(
    String name,
    String email,
    String password,
    String classInterest, {
      required String dateOfBirth,
      required String gender,
      required String institutionName,
      required String occupation,
    }
  ) async {
    return await repository.register (
      name,
      email,
      password,
      classInterest,
      dateOfBirth: dateOfBirth,
      gender: gender,
      institutionName: institutionName,
      occupation: occupation,
    );
  }
}