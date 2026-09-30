import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lms_mobile_app/src/core/error/app_exception.dart';
import 'package:lms_mobile_app/src/features/catalog/data/datasources/catalog_remote_data_source_impl.dart';

void main() {
  group('CatalogRemoteDataSourceImpl.createWebSession', () {
    test('POST course_id integer dan mengembalikan URL sekali pakai', () async {
      final dio = Dio(BaseOptions(baseUrl: 'https://example.com/api/mobile'));
      RequestOptions? capturedRequest;
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            capturedRequest = options;
            handler.resolve(
              Response<dynamic>(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'status': 'success',
                  'message': 'Berhasil membuat tautan website.',
                  'data': {
                    'url':
                        'https://example.com/auth/handoff/token-sekali-pakai',
                    'expires_in': 120,
                  },
                },
              ),
            );
          },
        ),
      );
      final dataSource = CatalogRemoteDataSourceImpl(dio: dio);

      final url = await dataSource.createWebSession('123');

      expect(capturedRequest?.method, 'POST');
      expect(capturedRequest?.path, '/web-session');
      expect(capturedRequest?.data, {'course_id': 123});
      expect(url, 'https://example.com/auth/handoff/token-sekali-pakai');
    });

    test('menolak course ID non-integer sebelum request dikirim', () async {
      final dio = Dio(BaseOptions(baseUrl: 'https://example.com/api/mobile'));
      var requestCount = 0;
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            requestCount++;
            handler.next(options);
          },
        ),
      );
      final dataSource = CatalogRemoteDataSourceImpl(dio: dio);

      await expectLater(
        dataSource.createWebSession('catalog-dummy'),
        throwsA(isA<ValidationException>()),
      );
      expect(requestCount, 0);
    });

    test('429 menyertakan retry_after dalam pesan error', () async {
      final dio = Dio(BaseOptions(baseUrl: 'https://example.com/api/mobile'));
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.reject(
              DioException(
                requestOptions: options,
                type: DioExceptionType.badResponse,
                response: Response<dynamic>(
                  requestOptions: options,
                  statusCode: 429,
                  data: {
                    'status': 'error',
                    'message': 'Terlalu banyak permintaan.',
                    'retry_after': 30,
                  },
                ),
              ),
            );
          },
        ),
      );
      final dataSource = CatalogRemoteDataSourceImpl(dio: dio);

      await expectLater(
        dataSource.createWebSession('123'),
        throwsA(
          isA<ServerException>()
              .having((error) => error.statusCode, 'statusCode', 429)
              .having(
                (error) => error.message,
                'message',
                contains('30 detik'),
              ),
        ),
      );
    });
  });
}
