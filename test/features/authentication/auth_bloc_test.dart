import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:lms_mobile_app/src/features/authentication/domain/entities/user_entity.dart';
import 'package:lms_mobile_app/src/features/authentication/domain/repositories/auth_repository.dart';
import 'package:lms_mobile_app/src/features/authentication/domain/usecases/get_current_user_usecase.dart';
import 'package:lms_mobile_app/src/features/authentication/domain/usecases/login_usecase.dart';
import 'package:lms_mobile_app/src/features/authentication/domain/usecases/logout_usecase.dart';
import 'package:lms_mobile_app/src/features/authentication/domain/usecases/register.usecase.dart';
import 'package:lms_mobile_app/src/features/authentication/presentation/bloc/auth/auth_bloc.dart';
import 'package:lms_mobile_app/src/features/authentication/presentation/bloc/auth/auth_event.dart';
import 'package:lms_mobile_app/src/features/authentication/presentation/bloc/auth/auth_state.dart';

void main() {
  test('bloc ditutup sebelum microtask tidak menambah event', () async {
    final repository = _FakeAuthRepository();
    final bloc = _bloc(repository);

    await bloc.close();
    await Future<void>.delayed(Duration.zero);

    expect(bloc.isClosed, isTrue);
    expect(repository.getCurrentUserCalls, 0);
  });

  test('restore session sukses menghasilkan AuthSuccess', () async {
    final repository = _FakeAuthRepository()..nextUser = _user();
    final bloc = _bloc(repository);
    addTearDown(bloc.close);

    await Future<void>.delayed(const Duration(milliseconds: 20));

    expect(repository.getCurrentUserCalls, greaterThanOrEqualTo(1));
    expect(bloc.state, isA<AuthSuccess>());
  });

  test('restore session gagal tetap di state awal tanpa error', () async {
    final repository = _FakeAuthRepository()..failGetCurrentUser = true;
    final bloc = _bloc(repository);
    addTearDown(bloc.close);

    await Future<void>.delayed(const Duration(milliseconds: 20));

    expect(bloc.state, isA<AuthInitial>());
  });

  test('login ganda saat berjalan hanya memanggil repository sekali', () async {
    final repository = _FakeAuthRepository();
    final gate = Completer<UserEntity?>();
    repository.loginGate = gate;
    final bloc = _bloc(repository);
    addTearDown(bloc.close);

    const event = AuthLoginEvent(email: 'siswa@mail.com', password: 'rahasia');
    bloc
      ..add(event)
      ..add(event);
    await Future<void>.delayed(const Duration(milliseconds: 20));

    expect(repository.loginCalls, 1);

    gate.complete(null);
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(bloc.state, isA<AuthFailure>());

    bloc.add(event);
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(repository.loginCalls, 2);
  });

  test('login sukses menghasilkan AuthSuccess', () async {
    final repository = _FakeAuthRepository()..nextUser = _user();
    final bloc = _bloc(repository);
    addTearDown(bloc.close);

    bloc.add(
      const AuthLoginEvent(email: 'siswa@mail.com', password: 'rahasia'),
    );
    await Future<void>.delayed(const Duration(milliseconds: 20));

    expect(repository.loginCalls, 1);
    expect(bloc.state, isA<AuthSuccess>());
  });

  test('login gagal menghasilkan AuthFailure dengan pesan', () async {
    final repository = _FakeAuthRepository()..nextUser = null;
    final bloc = _bloc(repository);
    addTearDown(bloc.close);

    bloc.add(const AuthLoginEvent(email: 'siswa@mail.com', password: 'salah'));
    await Future<void>.delayed(const Duration(milliseconds: 20));

    final state = bloc.state;
    expect(state, isA<AuthFailure>());
    expect((state as AuthFailure).message, contains('Login gagal'));
  });
}

AuthBloc _bloc(_FakeAuthRepository repository) {
  return AuthBloc(
    loginUseCase: LoginUseCase(repository),
    registerUseCase: RegisterUseCase(repository),
    logoutUseCase: LogoutUseCase(repository),
    getCurrentUserUseCase: GetCurrentUserUseCase(repository),
  );
}

UserEntity _user() => const UserEntity(
  id: '1',
  name: 'Siswa Satu',
  email: 'siswa@mail.com',
  role: 'student',
);

class _FakeAuthRepository implements AuthRepository {
  UserEntity? nextUser;
  bool failGetCurrentUser = false;

  int loginCalls = 0;
  int registerCalls = 0;
  int getCurrentUserCalls = 0;
  int logoutCalls = 0;

  /// Jika diisi, panggilan `login` berikutnya menunggu future ini.
  Completer<UserEntity?>? loginGate;

  @override
  Future<UserEntity?> login(String email, String password) {
    loginCalls++;
    final gate = loginGate;
    if (gate != null) {
      loginGate = null;
      return gate.future;
    }
    return Future.value(nextUser);
  }

  @override
  Future<UserEntity?> register(
    String name,
    String email,
    String password,
    String classInterest, {
    required String dateOfBirth,
    required String gender,
    required String institutionName,
    required String occupation,
  }) {
    registerCalls++;
    return Future.value(nextUser);
  }

  @override
  Future<UserEntity?> getCurrentUser() {
    getCurrentUserCalls++;
    if (failGetCurrentUser) {
      return Future.error(Exception('session error'));
    }
    return Future.value(nextUser);
  }

  @override
  Future<void> logout() async {
    logoutCalls++;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
