import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

enum AuthActionStatus { initial, loading, success, failure }

/// State generik untuk aksi auth sekunder (verifikasi email, lupa/ganti
/// password). [user] terisi saat verifikasi email berhasil.
class AuthActionState extends Equatable {
  final AuthActionStatus status;
  final String? message;
  final UserEntity? user;

  const AuthActionState({
    this.status = AuthActionStatus.initial,
    this.message,
    this.user,
  });

  bool get isLoading => status == AuthActionStatus.loading;

  AuthActionState copyWith({
    AuthActionStatus? status,
    String? message,
    UserEntity? user,
  }) {
    return AuthActionState(
      status: status ?? this.status,
      message: message,
      user: user ?? this.user,
    );
  }

  @override
  List<Object?> get props => [status, message, user];
}

/// Cubit tipis di atas [AuthRepository] untuk alur verifikasi email &
/// lupa/ganti password. Dibuat fresh per layar (registerFactory).
class AuthActionCubit extends Cubit<AuthActionState> {
  final AuthRepository _repository;

  AuthActionCubit(this._repository) : super(const AuthActionState());

  String _clean(Object error) =>
      error.toString().replaceFirst('Exception: ', '').trim();

  Future<void> sendEmailOtp() async {
    emit(state.copyWith(status: AuthActionStatus.loading));
    try {
      await _repository.sendEmailOtp();
      emit(
        state.copyWith(
          status: AuthActionStatus.success,
          message: 'Kode verifikasi sudah dikirim ke email kamu.',
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: AuthActionStatus.failure, message: _clean(e)));
    }
  }

  Future<void> verifyEmailOtp(String code) async {
    emit(state.copyWith(status: AuthActionStatus.loading));
    try {
      final user = await _repository.verifyEmailOtp(code);
      emit(
        state.copyWith(
          status: AuthActionStatus.success,
          message: 'Email berhasil diverifikasi.',
          user: user,
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: AuthActionStatus.failure, message: _clean(e)));
    }
  }

  Future<void> sendPasswordOtp(String email) async {
    emit(state.copyWith(status: AuthActionStatus.loading));
    try {
      await _repository.sendPasswordOtp(email);
      emit(
        state.copyWith(
          status: AuthActionStatus.success,
          message: 'Jika email terdaftar, kode reset sudah dikirim.',
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: AuthActionStatus.failure, message: _clean(e)));
    }
  }

  Future<void> resetPassword({
    required String email,
    required String code,
    required String password,
  }) async {
    emit(state.copyWith(status: AuthActionStatus.loading));
    try {
      await _repository.resetPassword(
        email: email,
        code: code,
        password: password,
      );
      emit(
        state.copyWith(
          status: AuthActionStatus.success,
          message: 'Password berhasil diubah. Silakan login.',
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: AuthActionStatus.failure, message: _clean(e)));
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    emit(state.copyWith(status: AuthActionStatus.loading));
    try {
      await _repository.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      emit(
        state.copyWith(
          status: AuthActionStatus.success,
          message: 'Password berhasil diubah.',
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: AuthActionStatus.failure, message: _clean(e)));
    }
  }
}
