import 'package:get_it/get_it.dart';
import 'package:lms_mobile_app/src/features/authentication/data/datasources/auth_remote_data_source.dart';
import 'package:lms_mobile_app/src/features/authentication/data/repositories/auth_repository_impl.dart';
import 'package:lms_mobile_app/src/features/authentication/domain/repositories/auth_repository.dart';
import 'package:lms_mobile_app/src/features/authentication/domain/usecases/auth_usecases.dart';
import 'package:lms_mobile_app/src/features/authentication/presentation/bloc/auth_bloc.dart';

final getIt = GetIt.instance;

/// Register authentication feature dependencies
///
/// Call dari injector.dart configureDependencies()

/// Register authentication module dependencies
void registerAuthModule() {
  // DataSources
  getIt.registerSingleton<AuthRemoteDataSource>(AuthRemoteDataSourceImpl());

  // Repositories
  getIt.registerSingleton<AuthRepository>(
    AuthRepositoryImpl(remoteDataSource: getIt<AuthRemoteDataSource>()),
  );

  // UseCases
  getIt.registerSingleton(LoginUseCase(getIt<AuthRepository>()));

  getIt.registerSingleton(LogoutUseCase(getIt<AuthRepository>()));

  getIt.registerSingleton(GetCurrentUserUseCase(getIt<AuthRepository>()));

  getIt.registerSingleton(IsLoggedInUseCase(getIt<AuthRepository>()));

  // BLoCs
  getIt.registerSingleton(
    AuthBloc(
      loginUseCase: getIt(),
      logoutUseCase: getIt(),
      getCurrentUserUseCase: getIt(),
      isLoggedInUseCase: getIt(),
    ),
  );
}
