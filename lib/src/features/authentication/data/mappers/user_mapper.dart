import 'package:lms_mobile_app/src/features/authentication/domain/entities/user_session_entity.dart';
import 'user_model.dart';

/// Mapper untuk mengkonversi antara UserModel (data) dan UserSessionEntity (domain)
class UserMapper {
  /// Convert UserModel ke UserSessionEntity
  static UserSessionEntity toEntity(UserModel model) {
    return UserSessionEntity(
      id: model.id,
      name: model.name,
      email: model.email,
    );
  }

  /// Convert UserSessionEntity ke UserModel
  static UserModel toModel(UserSessionEntity entity) {
    return UserModel(id: entity.id, name: entity.name, email: entity.email);
  }
}
