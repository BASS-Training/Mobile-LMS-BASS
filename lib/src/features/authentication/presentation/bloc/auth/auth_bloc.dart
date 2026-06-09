import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms_mobile_app/src/features/authentication/domain/usecases/get_current_user_usecase.dart';
import 'package:lms_mobile_app/src/features/authentication/domain/usecases/login_usecase.dart';
import 'package:lms_mobile_app/src/features/authentication/domain/usecases/logout_usecase.dart';
import 'package:lms_mobile_app/src/features/authentication/domain/usecases/register.usecase.dart';

import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;

  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.getCurrentUserUseCase,
  }) : super(const AuthInitial()) {
    on<AuthLoginEvent>(_onLogin);
    on<AuthRegisterEvent>(_onRegister);
    on<AuthSessionRequestedEvent>(_onSessionRequested);
    on<AuthLogoutEvent>(_onLogout);
    on<AuthClearErrorEvent>(_onClearError);

    Future.microtask(() => add(const AuthSessionRequestedEvent()));
  }

  Future<void> _onLogin(AuthLoginEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());

    try {
      final user = await loginUseCase(
        event.email,
        event.password,
      ).timeout(const Duration(seconds: 15));

      if (user != null) {
        emit(AuthSuccess(user: user));
      } else {
        emit(
          const AuthFailure(
            message: 'Login gagal. Periksa email dan password Laravel Anda.',
          ),
        );
      }
    } on TimeoutException {
      emit(
        const AuthFailure(
          message:
              'Login terlalu lama. Periksa koneksi dan pastikan API Laravel aktif.',
        ),
      );
    } catch (error) {
      emit(AuthFailure(message: 'Login error: $error'));
    }
  }

  Future<void> _onRegister(
    AuthRegisterEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final user = await registerUseCase(
        event.name,
        event.email,
        event.password,
        event.classInterest,
        dateOfBirth: event.dateOfBirth,
        gender: event.gender,
        institutionName: event.institutionName,
        occupation: event.occupation,
      ).timeout(const Duration(seconds: 15));

      if (user != null) {
        await logoutUseCase();
        emit(AuthRegisterSuccess(user: user));
      } else {
        emit(
          const AuthFailure(
            message: 'Register gagal. Periksa input Anda dan coba lagi.',
          ),
        );
      }
    } on TimeoutException {
      emit(
        const AuthFailure(
          message: 'Register terlalu lama. Periksa koneksi dan API Laravel.',
        ),
      );
    } catch (error) {
      emit(AuthFailure(message: 'Register error: $error'));
    }
  }

  Future<void> _onSessionRequested(
    AuthSessionRequestedEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final user = await getCurrentUserUseCase().timeout(
        const Duration(seconds: 10),
      );
      if (user != null) {
        emit(AuthSuccess(user: user));
      }
    } catch (_) {
      // Keep app on auth screen if session restoration fails.
    }
  }

  Future<void> _onLogout(AuthLogoutEvent event, Emitter<AuthState> emit) async {
    try {
      await logoutUseCase();
      emit(const AuthLoggedOut());
    } catch (error) {
      emit(AuthFailure(message: 'Logout error: $error'));
    }
  }

  Future<void> _onClearError(
    AuthClearErrorEvent event,
    Emitter<AuthState> emit,
  ) async {
    if (state is AuthFailure) {
      emit(const AuthInitial());
    }
  }
}
