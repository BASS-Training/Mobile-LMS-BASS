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

/// Flush semua microtask dan timer zero-delay sampai sistem stabil, pengganti
/// delay tetap (mis. 20 ms) yang membuat test bergantung kecepatan mesin.
Future<void> _settle() async {
  for (var i = 0; i < 10; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

void main() {
  test('bloc ditutup sebelum microtask tidak menambah event', () async {
    final repository = _FakeAuthRepository();
    final bloc = _bloc(repository);

    await bloc.close();
    await _settle();

    expect(bloc.isClosed, isTrue);
    expect(repository.getCurrentUserCalls, 0);
  });

  test('restore session sukses menghasilkan AuthSuccess', () async {
    final repository = _FakeAuthRepository()..nextUser = _user();
    final bloc = _bloc(repository);
    addTearDown(bloc.close);

    await _settle();

    expect(repository.getCurrentUserCalls, greaterThanOrEqualTo(1));
    expect(bloc.state, isA<AuthSuccess>());
  });

  test('restore session gagal tetap di state awal tanpa error', () async {
    final repository = _FakeAuthRepository()..failGetCurrentUser = true;
    final bloc = _bloc(repository);
    addTearDown(bloc.close);

    await _settle();

    expect(bloc.state, isA<AuthInitial>());
  });

  test('update user tanpa sesi aktif diabaikan', () async {
    final repository = _FakeAuthRepository();
    final bloc = _bloc(repository);
    addTearDown(bloc.close);
    await _settle();

    bloc.add(AuthUserUpdatedEvent(_user()));
    await _settle();

    expect(bloc.state, isA<AuthInitial>());
  });

  test('login ganda saat berjalan hanya memanggil repository sekali', () async {
    final repository = _FakeAuthRepository();
    final gate = Completer<UserEntity?>();
    repository.loginGate = gate;
    final bloc = _bloc(repository);
    addTearDown(bloc.close);

    const event = AuthLoginEvent(email: 'siswa@mail.com', password: 'rahasia');
    bloc.add(event);
    await _settle();

    expect(repository.loginCalls, 1);
    expect(bloc.state, isA<AuthLoading>());

    bloc.add(event);
    await _settle();
    expect(repository.loginCalls, 1);

    gate.complete(null);
    await _settle();
    expect(bloc.state, isA<AuthFailure>());

    bloc.add(event);
    await _settle();
    expect(repository.loginCalls, 2);
  });

  test(
    'restore session lama tidak menimpa login atau membuka tap kedua',
    () async {
      final repository = _FakeAuthRepository();
      final sessionGate = Completer<UserEntity?>();
      repository.sessionGate = sessionGate;
      final bloc = _bloc(repository);
      addTearDown(bloc.close);

      // Restore session bawaan konstruktor mulai lebih dulu dan tertahan.
      await _settle();
      expect(repository.getCurrentUserCalls, 1);

      final loginGate = Completer<UserEntity?>();
      repository.loginGate = loginGate;
      const event = AuthLoginEvent(
        email: 'siswa@mail.com',
        password: 'rahasia',
      );
      bloc.add(event);
      await _settle();
      expect(repository.loginCalls, 1);
      expect(bloc.state, isA<AuthLoading>());

      // Hasil restore lama dibuang karena login adalah transisi yang lebih baru.
      sessionGate.complete(_user());
      await _settle();
      expect(bloc.state, isA<AuthLoading>());

      bloc.add(event);
      await _settle();
      expect(repository.loginCalls, 1);

      loginGate.complete(null);
      await _settle();
      expect(bloc.state, isA<AuthFailure>());
    },
  );

  test('login sukses menghasilkan AuthSuccess', () async {
    final repository = _FakeAuthRepository()..nextUser = _user();
    final bloc = _bloc(repository);
    addTearDown(bloc.close);

    bloc.add(
      const AuthLoginEvent(email: 'siswa@mail.com', password: 'rahasia'),
    );
    await _settle();

    expect(repository.loginCalls, 1);
    expect(bloc.state, isA<AuthSuccess>());
  });

  test('login gagal menghasilkan AuthFailure dengan pesan', () async {
    final repository = _FakeAuthRepository()..nextUser = null;
    final bloc = _bloc(repository);
    addTearDown(bloc.close);

    bloc.add(const AuthLoginEvent(email: 'siswa@mail.com', password: 'salah'));
    await _settle();

    final state = bloc.state;
    expect(state, isA<AuthFailure>());
    expect((state as AuthFailure).message, contains('Login gagal'));
  });

  test('login yang melempar timeout menghasilkan AuthFailure khusus', () async {
    final repository = _FakeAuthRepository()
      ..loginError = TimeoutException('Future not completed');
    final bloc = _bloc(repository);
    addTearDown(bloc.close);

    bloc.add(
      const AuthLoginEvent(email: 'siswa@mail.com', password: 'rahasia'),
    );
    await _settle();

    final state = bloc.state;
    expect(state, isA<AuthFailure>());
    expect((state as AuthFailure).message, contains('Login terlalu lama'));
    expect(repository.loginCalls, 1);
  });

  test(
    'register ganda saat berjalan hanya memanggil repository sekali',
    () async {
      final registerStarted = Completer<void>();
      final registerGate = Completer<UserEntity?>();
      final repository = _FakeAuthRepository()
        ..registerStarted = registerStarted
        ..registerGate = registerGate;
      final bloc = _bloc(repository);
      addTearDown(bloc.close);

      const event = AuthRegisterEvent(
        name: 'Siswa Baru',
        email: 'baru@mail.com',
        password: 'rahasia',
        classInterest: 'IT',
        dateOfBirth: '2000-01-01',
        gender: 'Laki-laki',
        institutionName: 'SMK',
        occupation: 'Pelajar',
      );
      bloc
        ..add(event)
        ..add(event);
      await registerStarted.future;
      await _settle();

      expect(repository.registerCalls, 1);

      registerGate.complete(null);
      await _settle();
      expect(bloc.state, isA<AuthFailure>());
    },
  );

  test('register yang masuk selama login berjalan ikut dibatalkan', () async {
    final repository = _FakeAuthRepository();
    repository.loginGate = Completer<UserEntity?>();
    final bloc = _bloc(repository);
    addTearDown(bloc.close);

    bloc.add(
      const AuthLoginEvent(email: 'siswa@mail.com', password: 'rahasia'),
    );
    await _settle();
    expect(repository.loginCalls, 1);

    bloc.add(
      const AuthRegisterEvent(
        name: 'Siswa Baru',
        email: 'baru@mail.com',
        password: 'rahasia',
        classInterest: 'IT',
        dateOfBirth: '2000-01-01',
        gender: 'Laki-laki',
        institutionName: 'SMK',
        occupation: 'Pelajar',
      ),
    );
    await _settle();

    expect(repository.registerCalls, 0);
  });

  test(
    'restore session yang selesai setelah logout tidak menghidupkan sesi',
    () async {
      final repository = _FakeAuthRepository();
      final sessionGate = Completer<UserEntity?>();
      repository.sessionGate = sessionGate;
      final bloc = _bloc(repository);
      addTearDown(bloc.close);

      // Restore session bawaan konstruktor masih menunggu response.
      await _settle();
      expect(repository.getCurrentUserCalls, 1);

      bloc.add(const AuthLogoutEvent());
      await _settle();
      expect(repository.logoutCalls, 1);
      expect(bloc.state, isA<AuthLoggedOut>());

      // Response lama datang belakangan dan tidak boleh menimpa logout.
      sessionGate.complete(_user());
      await _settle();
      expect(bloc.state, isA<AuthLoggedOut>());
    },
  );

  test('login yang selesai setelah logout tidak menghidupkan sesi', () async {
    final loginGate = Completer<UserEntity?>();
    final repository = _FakeAuthRepository()..loginGate = loginGate;
    final bloc = _bloc(repository);
    addTearDown(bloc.close);

    bloc.add(
      const AuthLoginEvent(email: 'siswa@mail.com', password: 'rahasia'),
    );
    await _settle();
    expect(bloc.state, isA<AuthLoading>());

    bloc.add(const AuthLogoutEvent());
    await _settle();
    expect(bloc.state, isA<AuthLoggedOut>());

    loginGate.complete(_user());
    await _settle();
    expect(bloc.state, isA<AuthLoggedOut>());
  });

  test('bloc ditutup saat login masih berjalan tidak melempar error', () async {
    final loginGate = Completer<UserEntity?>();
    final repository = _FakeAuthRepository()..loginGate = loginGate;
    final bloc = _bloc(repository);

    bloc.add(
      const AuthLoginEvent(email: 'siswa@mail.com', password: 'rahasia'),
    );
    await _settle();
    expect(repository.loginCalls, 1);

    await bloc.close();
    loginGate.complete(_user());
    await _settle();

    expect(bloc.isClosed, isTrue);
    expect(bloc.state, isA<AuthLoading>());
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

  /// Jika diisi, panggilan `login` pertama menunggu future ini.
  Completer<UserEntity?>? loginGate;

  /// Jika diisi, panggilan `register` pertama menunggu future ini.
  Completer<UserEntity?>? registerGate;
  Completer<void>? registerStarted;

  /// Jika diisi, panggilan `getCurrentUser` pertama menunggu future ini.
  Completer<UserEntity?>? sessionGate;

  /// Error yang dilemparkan `login` (mis. timeout) tanpa menunggu.
  Object? loginError;

  @override
  Future<UserEntity?> login(String email, String password) {
    loginCalls++;
    final error = loginError;
    if (error != null) {
      return Future<UserEntity?>.error(error);
    }
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
    final started = registerStarted;
    if (started != null && !started.isCompleted) {
      started.complete();
    }
    final gate = registerGate;
    if (gate != null) {
      registerGate = null;
      return gate.future;
    }
    return Future.value(nextUser);
  }

  @override
  Future<UserEntity?> getCurrentUser() {
    getCurrentUserCalls++;
    final gate = sessionGate;
    if (gate != null) {
      sessionGate = null;
      return gate.future;
    }
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
