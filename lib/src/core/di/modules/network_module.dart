// Network module untuk API client dan interceptors
// Berisi: Dio client, request/response interceptors, API response model
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:lms_mobile_app/src/core/config/flavor_config.dart';
import 'package:lms_mobile_app/src/core/utils/local_storage.dart';

class NetworkModule {
  /// Register network dependencies
  static Future<void> register(GetIt getIt) async {
    if (getIt.isRegistered<Dio>()) {
      return;
    }

    getIt.registerLazySingleton<Dio>(createDioClient);
  }

  /// Get Dio instance (untuk future implementation)
  static Dio createDioClient() {
    final config = FlavorConfig.instance;

    final baseOptions = BaseOptions(
      baseUrl: config.apiBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      contentType: 'application/json',
    );

    final dio = Dio(baseOptions);

    dio.interceptors.add(AuthInterceptor());

    if (config.enableLogging) {
      dio.interceptors.add(LoggingInterceptor());
    }

    return dio;
  }
}

class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = LocalStorage.getAuthToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    super.onRequest(options, handler);
  }
}

/// Simple logging interceptor
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // ignore: avoid_print
    print('>>> REQUEST: ${options.method} ${options.path}');
    // ignore: avoid_print
    print('>>> HEADERS: ${options.headers}');
    if (options.data != null) {
      // ignore: avoid_print
      print('>>> BODY: ${options.data}');
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // ignore: avoid_print
    print(
      '<<< RESPONSE: ${response.statusCode} ${response.requestOptions.path}',
    );
    // ignore: avoid_print
    print('<<< DATA: ${response.data}');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // ignore: avoid_print
    print('!!! ERROR: ${err.message}');
    // ignore: avoid_print
    print('!!! STATUS: ${err.response?.statusCode}');
    super.onError(err, handler);
  }
}
