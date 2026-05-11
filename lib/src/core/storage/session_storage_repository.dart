// Kontrak untuk penyimpanan sesi
import 'package:lms_mobile_app/src/features/authentication/domain/entities/auth_entity.dart';

abstract class SessionStorageRepository {
  Future<void> saveToken(String auth);
  Future<void> saveUser(UserEntity user);

  Future<String?> getToken();
  Future<UserEntity?> getUser();

  Future<void> clear();
}
