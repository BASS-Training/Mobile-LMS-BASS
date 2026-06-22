import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Update the current user's profile (data dasar + optional avatar photo).
class UpdateProfileUseCase {
  final AuthRepository _repository;

  UpdateProfileUseCase(this._repository);

  Future<UserEntity?> call({
    required String name,
    required String dateOfBirth,
    required String gender,
    required String institutionName,
    required String occupation,
    String? avatarFilePath,
  }) {
    return _repository.updateProfile(
      name: name,
      dateOfBirth: dateOfBirth,
      gender: gender,
      institutionName: institutionName,
      occupation: occupation,
      avatarFilePath: avatarFilePath,
    );
  }
}
