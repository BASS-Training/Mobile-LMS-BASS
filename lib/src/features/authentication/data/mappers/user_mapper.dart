import '../../domain/entities/user_entity.dart';
import '../models/user.dart';

class UserMapper {
  static UserEntity toDomain(User model) {
    return UserEntity(
      id: model.id,
      name: model.name,
      email: model.email,
    );
  }

  static User fromDomain(UserEntity entity) {
    return User(
      id: entity.id,
      name: entity.name,
      email: entity.email,
    );
  }
}
