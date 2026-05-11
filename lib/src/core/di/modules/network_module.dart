/// Network module untuk API client dan interceptors
/// Berisi: Dio client, request/response interceptors, API response model
import 'package:dio/dio.dart';
import 'package:lms_mobile_app/src/core/config/flavor_config.dart';

class NetworkModule {
  /// Register network dependencies
  static Future<void> register() async {
    // TODO: Initialize Dio client dengan base URL dari FlavorConfig
    // TODO: Setup interceptors untuk logging, error handling, auth token

    // For now: Placeholder
    print('NetworkModule initialized');
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

    // Add interceptors di sini
    if (config.enableLogging) {
      dio.interceptors.add(LoggingInterceptor());
    }

    return dio;
  }
}

/// Simple logging interceptor
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print('>>> REQUEST: ${options.method} ${options.path}');
    print('>>> HEADERS: ${options.headers}');
    if (options.data != null) {
      print('>>> BODY: ${options.data}');
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print(
      '<<< RESPONSE: ${response.statusCode} ${response.requestOptions.path}',
    );
    print('<<< DATA: ${response.data}');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print('!!! ERROR: ${err.message}');
    print('!!! STATUS: ${err.response?.statusCode}');
    super.onError(err, handler);
  }
}
