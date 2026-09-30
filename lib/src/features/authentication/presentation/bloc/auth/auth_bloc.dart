import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms_mobile_app/src/features/authentication/domain/usecases/get_current_user_usecase.dart';
import 'package:lms_mobile_app/src/features/authentication/domain/usecases/login_usecase.dart';
import 'package:lms_mobile_app/src/features/authentication/domain/usecases/logout_usecase.dart';
import 'package:lms_mobile_app/src/features/authentication/domain/usecases/register.usecase.dart';

import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  static const Duration _credentialTimeout = Duration(seconds: 16);

  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;

  /// Satu operasi kredensial (login ATAU register) dalam satu waktu.
  /// Dipakai alih-alih `state is AuthLoading`, karena state bisa berubah oleh
  /// event lain — mis. restore session yang selesai — di tengah operasi,
  /// sehingga guard berbasis state dapat dilewati oleh tap kedua.
  bool _credentialOpInFlight = false;

  /// Nomor urut transisi auth. Hasil async hanya boleh mengubah state bila
  /// operasinya masih merupakan transisi terbaru.
  int _authGeneration = 0;
  bool _logoutInFlight = false;

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
    on<AuthUserUpdatedEvent>(_onUserUpdated);

    Future.microtask(() {
      if (isClosed) return;
      try {
        add(const AuthSessionRequestedEvent());
      } on StateError {
        // Bloc.close() menutup event controller lebih dulu dari state
        // controller, sehingga guard di atas bisa terlambat. Event awal
        // aplikasi ini aman dilepas.
      }
    });
  }

  Future<void> _onLogin(AuthLoginEvent event, Emitter<AuthState> emit) async {
    // Droppable: abaikan tap kedua selama login masih berjalan.
    if (_credentialOpInFlight) return;
    _credentialOpInFlight = true;
    final generation = ++_authGeneration;
    try {
      emit(const AuthLoading());

      try {
        final user = await loginUseCase(
          event.email,
          event.password,
        ).timeout(_credentialTimeout);

        if (isClosed || generation != _authGeneration) return;
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
        if (isClosed || generation != _authGeneration) return;
        emit(
          const AuthFailure(
            message:
                'Login terlalu lama. Periksa koneksi dan pastikan API Laravel aktif.',
          ),
        );
      } catch (error) {
        if (isClosed || generation != _authGeneration) return;
        emit(
          AuthFailure(
            message: _readableError(error, 'Login gagal. Coba lagi.'),
          ),
        );
      }
    } finally {
      _credentialOpInFlight = false;
    }
  }

  Future<void> _onRegister(
    AuthRegisterEvent event,
    Emitter<AuthState> emit,
  ) async {
    // Sama dengan login: satu operasi kredensial dalam satu waktu.
    if (_credentialOpInFlight) return;
    _credentialOpInFlight = true;
    final generation = ++_authGeneration;
    try {
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
        ).timeout(_credentialTimeout);

        if (isClosed || generation != _authGeneration) return;
        if (user != null) {
          // Tetap login setelah daftar → router otomatis mengarahkan ke layar
          // verifikasi OTP (karena akun baru must_verify_email = true).
          emit(AuthSuccess(user: user));
        } else {
          emit(
            const AuthFailure(
              message: 'Register gagal. Periksa input Anda dan coba lagi.',
            ),
          );
        }
      } on TimeoutException {
        if (isClosed || generation != _authGeneration) return;
        emit(
          const AuthFailure(
            message: 'Register terlalu lama. Periksa koneksi dan API Laravel.',
          ),
        );
      } catch (error) {
        if (isClosed || generation != _authGeneration) return;
        emit(
          AuthFailure(
            message: _readableError(error, 'Register gagal. Coba lagi.'),
          ),
        );
      }
    } finally {
      _credentialOpInFlight = false;
    }
  }

  Future<void> _onSessionRequested(
    AuthSessionRequestedEvent event,
    Emitter<AuthState> emit,
  ) async {
    if (_credentialOpInFlight || _logoutInFlight) return;
    final generation = _authGeneration;
    try {
      final user = await getCurrentUserUseCase().timeout(
        const Duration(seconds: 10),
      );
      // Buang hasil restore sesi yang datang setelah logout: sesi lama tidak
      // boleh menghidupkan kembali status AuthSuccess.
      if (isClosed || generation != _authGeneration) return;
      if (user != null) {
        emit(AuthSuccess(user: user));
      }
    } catch (_) {
      // Keep app on auth screen if session restoration fails.
    }
  }

  Future<void> _onLogout(AuthLogoutEvent event, Emitter<AuthState> emit) async {
    if (_logoutInFlight) return;
    final generation = ++_authGeneration;
    _logoutInFlight = true;
    try {
      await logoutUseCase();
      if (isClosed || generation != _authGeneration) return;
      emit(const AuthLoggedOut());
    } catch (error) {
      if (isClosed || generation != _authGeneration) return;
      emit(AuthFailure(message: 'Logout error: $error'));
    } finally {
      _logoutInFlight = false;
    }
  }

  void _onUserUpdated(AuthUserUpdatedEvent event, Emitter<AuthState> emit) {
    if (_logoutInFlight || state is! AuthSuccess) return;
    _authGeneration++;
    emit(AuthSuccess(user: event.user));
  }

  Future<void> _onClearError(
    AuthClearErrorEvent event,
    Emitter<AuthState> emit,
  ) async {
    if (state is AuthFailure) {
      emit(const AuthInitial());
    }
  }

  /// The data layer wraps failures as `Exception('<friendly message>')`
  /// (server-500/connection errors already mapped to user-facing text). Strip
  /// the `Exception:` prefix so the message reaches the UI cleanly.
  String _readableError(Object error, String fallback) {
    final text = error.toString().replaceFirst('Exception: ', '').trim();
    return text.isEmpty ? fallback : text;
  }
}
