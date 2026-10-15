import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:lms_mobile_app/src/core/utils/local_storage.dart';
import 'package:lms_mobile_app/src/features/authentication/data/support_api.dart';

void main() {
  late Directory directory;
  late Dio dio;
  late int status;
  late Map<String, dynamic> payload;
  late RequestOptions? sent;

  setUpAll(() async {
    directory = await Directory.systemTemp.createTemp('support_api_');
    Hive.init(directory.path);
    await Hive.openBox('mini_lms_box');
  });

  tearDownAll(() async {
    await Hive.close();
    await directory.delete(recursive: true);
  });

  setUp(() async {
    await Hive.box('mini_lms_box').clear();
    await LocalStorage.saveAuthSession(
      token: 'token-42',
      user: {'id': 42, 'name': 'Tester'},
    );
    status = 200;
    payload = {'status': 'success', 'message': 'Akun berhasil dihapus.'};
    sent = null;
    dio = Dio(BaseOptions(baseUrl: 'https://test.invalid/api/mobile'));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          sent = options;
          if (status == 0) {
            handler.reject(
              DioException(
                requestOptions: options,
                type: DioExceptionType.connectionError,
              ),
            );
            return;
          }
          final response = Response(
            requestOptions: options,
            statusCode: status,
            data: payload,
          );
          if (status >= 400) {
            handler.reject(
              DioException(
                requestOptions: options,
                response: response,
                type: DioExceptionType.badResponse,
              ),
            );
          } else {
            handler.resolve(response);
          }
        },
      ),
    );
  });

  test('success clears only deleted account across all boxes', () async {
    await LocalStorage.saveEssayDraftAnswer(
      lessonId: 'lesson',
      questionIndex: 0,
      answer: 'draft rahasia',
    );
    for (final name in [
      'bass_calendar_box',
      'bass_games_box',
      'bass_achievements_box',
    ]) {
      final box = Hive.isBoxOpen(name)
          ? Hive.box(name)
          : await Hive.openBox(name);
      await box.put('sample__u_42', 'old');
      await box.put('sample__u_7', 'other');
    }

    await SupportApi(dio).deleteAccount('secret');

    expect(sent?.method, 'DELETE');
    expect(sent?.path, '/profile');
    expect(sent?.data, {'password': 'secret'});
    expect(sent?.headers['Authorization'], 'Bearer token-42');
    expect(LocalStorage.getAuthToken(), isNull);
    expect(
      Hive.box(
        'mini_lms_box',
      ).keys.where((key) => key.toString().endsWith('__u_42')),
      isEmpty,
    );
    for (final name in [
      'bass_calendar_box',
      'bass_games_box',
      'bass_achievements_box',
    ]) {
      expect(Hive.box(name).containsKey('sample__u_42'), isFalse);
      expect(Hive.box(name).get('sample__u_7'), 'other');
    }
  });

  test('public content uses the documented endpoints', () async {
    payload = {
      'status': 'success',
      'data': {'title': 'Bantuan'},
    };
    expect((await SupportApi(dio).customerService())['title'], 'Bantuan');
    expect(sent?.path, '/customer-service');
    payload = {
      'status': 'success',
      'data': {'language': 'id'},
    };
    expect((await SupportApi(dio).privacyPolicy())['language'], 'id');
    expect(sent?.path, '/privacy-policy');
    expect(sent?.queryParameters['lang'], 'id');
  });

  for (final code in [401, 422, 429, 500]) {
    test('$code keeps account session and drafts', () async {
      status = code;
      payload = {
        'status': 'error',
        'errors': {
          'password': ['Kata sandi salah.'],
        },
      };
      await LocalStorage.saveEssayDraftAnswer(
        lessonId: 'lesson',
        questionIndex: 0,
        answer: 'draft',
      );
      await expectLater(
        SupportApi(dio).deleteAccount('wrong'),
        throwsA(isA<DeleteAccountException>()),
      );
      expect(LocalStorage.getAuthToken(), 'token-42');
      expect(LocalStorage.getEssayDraftAnswers('lesson')[0], 'draft');
    });
  }

  test('network failure keeps session', () async {
    status = 0;
    await expectLater(
      SupportApi(dio).deleteAccount('secret'),
      throwsA(isA<DeleteAccountException>()),
    );
    expect(LocalStorage.getAuthToken(), 'token-42');
  });

  test('unconfirmed 200 response keeps session', () async {
    payload = {'status': 'error'};
    await expectLater(
      SupportApi(dio).deleteAccount('secret'),
      throwsA(isA<DeleteAccountException>()),
    );
    expect(LocalStorage.getAuthToken(), 'token-42');
  });
}
