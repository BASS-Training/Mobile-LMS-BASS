import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:lms_mobile_app/src/core/di/modules/network_module.dart';
import 'package:lms_mobile_app/src/core/utils/local_storage.dart';
import 'package:lms_mobile_app/src/features/authentication/data/repositories/auth_repository_impl.dart';

const _userJson = <String, dynamic>{
  'id': '1',
  'name': 'Siswa Satu',
  'email': 'siswa@mail.com',
  'role': 'student',
};

void main() {
  late Directory hiveDirectory;

  setUpAll(() async {
    hiveDirectory = await Directory.systemTemp.createTemp('auth_repository_');
    Hive.init(hiveDirectory.path);
    await Hive.openBox('mini_lms_box');
  });

  tearDownAll(() async {
    await Hive.close();
    await hiveDirectory.delete(recursive: true);
  });

  setUp(() async {
    await LocalStorage.clearAuthSession();
  });

  Future<void> expectStaleMutationRejected(
    Future<Object?> Function(AuthRepositoryImpl repository) mutate,
  ) async {
    final gate = Completer<void>();
    final adapter = _FakeAdapter(
      statusCode: 200,
      body: <String, dynamic>{
        'data': <String, dynamic>{'user': _userJson},
      },
      gate: gate,
    );
    final repository = AuthRepositoryImpl(
      dio: Dio(BaseOptions(baseUrl: 'http://localhost'))
        ..httpClientAdapter = adapter,
    );
    await LocalStorage.saveAuthSession(token: 'token-lama', user: _userJson);

    final rejected = expectLater(mutate(repository), throwsA(isA<Exception>()));
    await adapter.started.future;
    await LocalStorage.clearAuthSession();
    gate.complete();
    await rejected;

    expect(LocalStorage.getAuthToken(), isNull);
    expect(LocalStorage.getAuthUser(), isNull);
  }

  test(
    'response /auth/me yang datang setelah logout tidak menyimpan token',
    () async {
      final gate = Completer<void>();
      final adapter = _FakeAdapter(
        statusCode: 200,
        body: <String, dynamic>{'data': _userJson},
        gate: gate,
      );
      final repository = AuthRepositoryImpl(
        dio: Dio(BaseOptions(baseUrl: 'http://localhost'))
          ..httpClientAdapter = adapter,
      );

      await LocalStorage.saveAuthSession(token: 'token-1', user: _userJson);

      final pending = repository.getCurrentUser();
      await adapter.started.future;
      expect(LocalStorage.getAuthToken(), 'token-1');

      // Logout terjadi selagi response /auth/me masih di jalan.
      await LocalStorage.clearAuthSession();
      gate.complete();
      final result = await pending;

      expect(result, isNull);
      expect(LocalStorage.getAuthToken(), isNull);
      expect(LocalStorage.getAuthUser(), isNull);
    },
  );

  test(
    'error /auth/me setelah sesi berganti tidak menghapus sesi baru',
    () async {
      final gate = Completer<void>();
      final adapter = _FakeAdapter(statusCode: 500, gate: gate);
      final repository = AuthRepositoryImpl(
        dio: Dio(BaseOptions(baseUrl: 'http://localhost'))
          ..httpClientAdapter = adapter,
      );

      await LocalStorage.saveAuthSession(token: 'token-1', user: _userJson);
      final pending = repository.getCurrentUser();
      await adapter.started.future;

      // Keluar lalu masuk lagi dengan sesi berbeda sebelum error datang.
      await LocalStorage.clearAuthSession();
      await LocalStorage.saveAuthSession(token: 'token-2', user: _userJson);
      gate.complete();
      final result = await pending;

      expect(result, isNull);
      expect(LocalStorage.getAuthToken(), 'token-2');
      expect(LocalStorage.getAuthUser(), isNotNull);
    },
  );

  test(
    'response login yang datang setelah logout tidak menyimpan sesi',
    () async {
      final loginGate = Completer<void>();
      final adapter = _AuthFlowAdapter(loginGate: loginGate);
      final repository = AuthRepositoryImpl(
        dio: Dio(BaseOptions(baseUrl: 'http://localhost'))
          ..httpClientAdapter = adapter,
      );

      final pendingLogin = repository.login('siswa@mail.com', 'rahasia');
      final cancelledLogin = expectLater(
        pendingLogin,
        throwsA(isA<Exception>()),
      );
      await adapter.loginStarted.future;

      await repository.logout();
      loginGate.complete();
      await cancelledLogin;

      expect(LocalStorage.getAuthToken(), isNull);
      expect(LocalStorage.getAuthUser(), isNull);
    },
  );

  test('timeout membatalkan request login dan tidak menyimpan sesi', () async {
    final adapter = _AuthFlowAdapter(
      loginGate: Completer<void>(),
      reactToCancel: true,
    );
    final repository = AuthRepositoryImpl(
      dio: Dio(BaseOptions(baseUrl: 'http://localhost'))
        ..httpClientAdapter = adapter,
      credentialRequestTimeout: const Duration(milliseconds: 10),
    );

    await expectLater(
      repository.login('siswa@mail.com', 'rahasia'),
      throwsA(isA<TimeoutException>()),
    );
    await adapter.cancelObserved.future;

    expect(LocalStorage.getAuthToken(), isNull);
    expect(LocalStorage.getAuthUser(), isNull);
  });

  test('logout lama tidak menghapus login baru', () async {
    final logoutGate = Completer<void>();
    final adapter = _AuthFlowAdapter(logoutGate: logoutGate);
    final repository = AuthRepositoryImpl(
      dio: Dio(BaseOptions(baseUrl: 'http://localhost'))
        ..httpClientAdapter = adapter,
    );
    await LocalStorage.saveAuthSession(token: 'token-lama', user: _userJson);

    await repository.logout();
    await adapter.logoutStarted.future;
    expect(LocalStorage.getAuthToken(), isNull);
    expect(logoutGate.isCompleted, isFalse);

    final user = await repository.login('siswa@mail.com', 'rahasia');
    expect(user, isNotNull);
    expect(LocalStorage.getAuthToken(), 'token-baru');

    logoutGate.complete();
    await adapter.logoutCompleted.future;
    expect(LocalStorage.getAuthToken(), 'token-baru');
  });

  test('interceptor mempertahankan Authorization eksplisit', () async {
    final adapter = _FakeAdapter(statusCode: 200, body: const {});
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost'))
      ..interceptors.add(AuthInterceptor())
      ..httpClientAdapter = adapter;
    await LocalStorage.saveAuthSession(token: 'token-baru', user: _userJson);

    await dio.post(
      '/auth/logout',
      options: Options(headers: const {'Authorization': 'Bearer token-lama'}),
    );

    expect(adapter.lastRequest?.headers['Authorization'], 'Bearer token-lama');
  });

  test(
    'storage membaca sesi legacy lalu memigrasikannya secara atomik',
    () async {
      final box = Hive.box('mini_lms_box');
      await box.delete('auth_session');
      await box.put('auth_token', 'token-legacy');
      await box.put('auth_user', jsonEncode(_userJson));

      expect(LocalStorage.getAuthToken(), 'token-legacy');
      expect(LocalStorage.getAuthUser()?['id'], '1');

      await LocalStorage.saveAuthSession(token: 'token-baru', user: _userJson);
      expect(box.containsKey('auth_session'), isTrue);
      expect(box.containsKey('auth_token'), isFalse);
      expect(box.containsKey('auth_user'), isFalse);
    },
  );

  test('tombstone mengalahkan key legacy yang tertinggal', () async {
    final box = Hive.box('mini_lms_box');
    await LocalStorage.clearAuthSession();
    await box.put('auth_token', 'token-legacy');
    await box.put('auth_user', jsonEncode(_userJson));

    expect(LocalStorage.getAuthToken(), isNull);
    expect(LocalStorage.getAuthUser(), isNull);
  });

  test(
    'revision lama tidak dapat menyimpan atau menghapus sesi baru',
    () async {
      final oldRevision = LocalStorage.authSessionRevision;
      await LocalStorage.saveAuthSession(token: 'token-baru', user: _userJson);

      expect(
        await LocalStorage.saveAuthSessionIfUnchanged(
          expectedRevision: oldRevision,
          token: 'token-basi',
          user: _userJson,
        ),
        isFalse,
      );
      expect(
        await LocalStorage.clearAuthSessionIfUnchanged(
          expectedRevision: oldRevision,
        ),
        isFalse,
      );
      expect(LocalStorage.getAuthToken(), 'token-baru');
    },
  );

  test('response update profil lama ditolak setelah logout', () async {
    await expectStaleMutationRejected(
      (repository) => repository.updateProfile(
        name: 'Nama Baru',
        dateOfBirth: '2000-01-01',
        gender: 'male',
        institutionName: 'SMK',
        occupation: 'Pelajar',
      ),
    );
  });

  test('response verifikasi email lama ditolak setelah logout', () async {
    await expectStaleMutationRejected(
      (repository) => repository.verifyEmailOtp('123456'),
    );
  });

  test('response ubah email lama ditolak setelah logout', () async {
    await expectStaleMutationRejected(
      (repository) =>
          repository.changeEmail(newEmail: 'baru@mail.com', code: '123456'),
    );
  });

  test('response /auth/me yang sah memperbarui sesi yang sama', () async {
    final adapter = _FakeAdapter(
      statusCode: 200,
      body: <String, dynamic>{
        'data': {..._userJson, 'name': 'Nama Baru'},
      },
    );
    final repository = AuthRepositoryImpl(
      dio: Dio(BaseOptions(baseUrl: 'http://localhost'))
        ..httpClientAdapter = adapter,
    );

    await LocalStorage.saveAuthSession(token: 'token-1', user: _userJson);
    final result = await repository.getCurrentUser();

    expect(result, isNotNull);
    expect(result!.name, 'Nama Baru');
    expect(LocalStorage.getAuthToken(), 'token-1');
    expect(LocalStorage.getAuthUser()?['name'], 'Nama Baru');
  });
}

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter({required this.statusCode, this.body, this.gate});

  final int statusCode;
  final Map<String, dynamic>? body;

  /// Jika diisi, response baru dilepas setelah future ini selesai; dipakai
  /// untuk mensimulasikan response yang datang belakangan.
  final Completer<void>? gate;
  RequestOptions? lastRequest;
  final started = Completer<void>();

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastRequest = options;
    if (!started.isCompleted) started.complete();
    final gate = this.gate;
    if (gate != null) {
      await gate.future;
    }
    return ResponseBody.fromString(
      jsonEncode(body),
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class _AuthFlowAdapter implements HttpClientAdapter {
  _AuthFlowAdapter({
    this.loginGate,
    this.logoutGate,
    this.reactToCancel = false,
  });

  final Completer<void>? loginGate;
  final Completer<void>? logoutGate;
  final bool reactToCancel;

  final loginStarted = Completer<void>();
  final logoutStarted = Completer<void>();
  final logoutCompleted = Completer<void>();
  final cancelObserved = Completer<void>();

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (options.path.endsWith('/auth/login')) {
      if (!loginStarted.isCompleted) loginStarted.complete();
      await _wait(loginGate, cancelFuture, options);
      return _jsonResponse(200, <String, dynamic>{
        'data': <String, dynamic>{'token': 'token-baru', 'user': _userJson},
      });
    }

    if (options.path.endsWith('/auth/logout')) {
      if (!logoutStarted.isCompleted) logoutStarted.complete();
      await _wait(logoutGate, cancelFuture, options);
      if (!logoutCompleted.isCompleted) logoutCompleted.complete();
      return _jsonResponse(200, const <String, dynamic>{});
    }

    throw StateError('Endpoint tidak didukung: ${options.path}');
  }

  Future<void> _wait(
    Completer<void>? gate,
    Future<void>? cancelFuture,
    RequestOptions options,
  ) async {
    if (gate == null) return;
    if (!reactToCancel || cancelFuture == null) {
      await gate.future;
      return;
    }

    await Future.any<void>([
      gate.future,
      cancelFuture.then((_) {
        if (!cancelObserved.isCompleted) cancelObserved.complete();
        throw DioException(
          requestOptions: options,
          type: DioExceptionType.cancel,
        );
      }),
    ]);
  }

  ResponseBody _jsonResponse(int statusCode, Map<String, dynamic> body) {
    return ResponseBody.fromString(
      jsonEncode(body),
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
