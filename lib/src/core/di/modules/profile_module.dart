import 'package:get_it/get_it.dart';
import 'package:lms_mobile_app/src/features/profile/domain/repositories/profile_repository.dart';
import 'package:lms_mobile_app/src/features/profile/data/repositories/profile_repository_impl.dart';

final getIt = GetIt.instance;

/// Register profile feature dependencies
void registerProfileModule() {
  // ============ DATA SOURCES ============
  // TODO: Add profile datasources

  // ============ REPOSITORIES ============

  getIt.registerSingleton<ProfileRepository>(ProfileRepositoryImpl());

  // ============ USE CASES ============
  // TODO: Add profile usecases

  // ============ BLoCs ============
  // TODO: Add profile blocs
}
