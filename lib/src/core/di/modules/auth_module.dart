// Auth module - dependency injection untuk authentication feature
// Berisi: AuthRepository, DataSources, UseCases, BLoC
import 'package:get_it/get_it.dart';
import 'package:lms_mobile_app/src/features/authentication/data/repositories/auth_repository_impl.dart';
import 'package:lms_mobile_app/src/features/authentication/domain/repositories/auth_repository.dart';
import 'package:lms_mobile_app/src/features/authentication/domain/usecases/auth_usecase.dart';
import 'package:lms_mobile_app/src/features/authentication/presentation/bloc/auth/auth_bloc.dart';

class AuthModule {
  /// Register semua auth dependencies
  static void register(GetIt getIt) {
    if (getIt.isRegistered<AuthBloc>()) {
      return;
    }

    // Data Layer
    final AuthRepository authRepository = AuthRepositoryImpl();

    // Use Cases
    final loginUseCase = LoginUseCase(authRepository);
    final registerUseCase = RegisterUseCase(authRepository);
    final logoutUseCase = LogoutUseCase(authRepository);
    final getCurrentUserUseCase = GetCurrentUserUseCase(authRepository);

    // Presentation Layer
    getIt.registerLazySingleton<AuthBloc>(
      () => AuthBloc(
        loginUseCase: loginUseCase,
        registerUseCase: registerUseCase,
        logoutUseCase: logoutUseCase,
        getCurrentUserUseCase: getCurrentUserUseCase,
      ),
    );
  }
}
