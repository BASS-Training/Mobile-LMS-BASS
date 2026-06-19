// Auth module - dependency injection untuk authentication feature
// Berisi: AuthRepository, DataSources, UseCases, BLoC
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:lms_mobile_app/src/features/authentication/data/repositories/auth_repository_impl.dart';
import 'package:lms_mobile_app/src/features/authentication/domain/repositories/auth_repository.dart';
import 'package:lms_mobile_app/src/features/authentication/domain/usecases/get_current_user_usecase.dart';
import 'package:lms_mobile_app/src/features/authentication/domain/usecases/login_usecase.dart';
import 'package:lms_mobile_app/src/features/authentication/domain/usecases/logout_usecase.dart';
import 'package:lms_mobile_app/src/features/authentication/domain/usecases/register.usecase.dart';
import 'package:lms_mobile_app/src/features/authentication/domain/usecases/update_profile_usecase.dart';
import 'package:lms_mobile_app/src/features/authentication/presentation/bloc/auth/auth_bloc.dart';
import 'package:lms_mobile_app/src/features/authentication/presentation/edit_profile/edit_profile_cubit.dart';

class AuthModule {
  /// Register semua auth dependencies
  static void register(GetIt getIt) {
    if (getIt.isRegistered<AuthBloc>()) {
      return;
    }

    // Data Layer
    final AuthRepository authRepository = AuthRepositoryImpl(dio: getIt<Dio>());

    // Use Cases
    final loginUseCase = LoginUseCase(authRepository);
    final registerUseCase = RegisterUseCase(authRepository);
    final logoutUseCase = LogoutUseCase(authRepository);
    final getCurrentUserUseCase = GetCurrentUserUseCase(authRepository);
    final updateProfileUseCase = UpdateProfileUseCase(authRepository);

    getIt.registerLazySingleton<GetCurrentUserUseCase>(
      () => getCurrentUserUseCase,
    );

    // A fresh cubit per edit-profile screen.
    getIt.registerFactory<EditProfileCubit>(
      () => EditProfileCubit(updateProfileUseCase),
    );

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
