/// Auth module - dependency injection untuk authentication feature
/// Berisi: AuthRepository, DataSources, UseCases, BLoC
import 'package:lms_mobile_app/src/features/authentication/data/repositories/auth_repository_impl.dart';
import 'package:lms_mobile_app/src/features/authentication/domain/repositories/auth_repository.dart';
import 'package:lms_mobile_app/src/features/authentication/domain/usecases/auth_usecase.dart';
import 'package:lms_mobile_app/src/features/authentication/presentation/bloc/auth/auth_bloc.dart';

class AuthModule {
  static late AuthBloc _authBloc;

  /// Register semua auth dependencies
  static void register() {
    // Data Layer
    AuthRepository authRepository = AuthRepositoryImpl();

    // Use Cases
    LoginUseCase loginUseCase = LoginUseCase(authRepository);
    LogoutUseCase logoutUseCase = LogoutUseCase(authRepository);

    // Presentation Layer
    _authBloc = AuthBloc(
      loginUseCase: loginUseCase,
      logoutUseCase: logoutUseCase,
    );
  }

  /// Get AuthBloc instance
  static AuthBloc get authBloc => _authBloc;
}
