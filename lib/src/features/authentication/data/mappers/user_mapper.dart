import '../../domain/entities/user_entity.dart';
import '../models/user.dart';

class UserMapper {
  static UserEntity toDomain(User model) {
    return UserEntity(
      id: model.id,
      name: model.name,
      email: model.email,
      role: model.role,
      roles: model.roles,
      dateOfBirth: model.dateOfBirth,
      gender: model.gender,
      institutionName: model.institutionName,
      occupation: model.occupation,
      registrationProgram: model.registrationProgram,
      avpnVerificationStatus: model.avpnVerificationStatus,
      joinedAt: model.joinedAt,
      avatarUrl: model.avatarUrl,
    );
  }

  static User fromDomain(UserEntity entity) {
    return User(
      id: entity.id,
      name: entity.name,
      email: entity.email,
      role: entity.role,
      roles: entity.roles,
      dateOfBirth: entity.dateOfBirth,
      gender: entity.gender,
      institutionName: entity.institutionName,
      occupation: entity.occupation,
      registrationProgram: entity.registrationProgram,
      avpnVerificationStatus: entity.avpnVerificationStatus,
      joinedAt: entity.joinedAt,
      avatarUrl: entity.avatarUrl,
    );
  }
}
