import 'package:lms_mobile_app/src/core/storage/session_storage_repository.dart';
import 'package:lms_mobile_app/src/features/authentication/domain/entities/auth_entity.dart';

class CheckSessionUseCase {
  final SessionStorageRepository _sessionStorageRepository;

  CheckSessionUseCase(this._sessionStorageRepository);

  Future<UserEntity?> call() async {
    final authFuture = _sessionStorageRepository.getToken();
    final userFuture = _sessionStorageRepository.getUser();

    final auth = await authFuture;
    final user = await userFuture;

    if (auth != null && user != null) {
      return user;
    } else {
      return null;
    }
  }
}
