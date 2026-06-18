// Network module untuk API client dan interceptors
// Berisi: Dio client, request/response interceptors, API response model
import 'package:dio/dio.dart';
import 'package:lms_mobile_app/src/core/utils/app_logger.dart';
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

/// Simple logging interceptor.
///
/// PENTING: jangan pernah mencetak seluruh body/response. Untuk respons besar
/// (mis. daftar course dengan semua lesson/konten), `print` JSON penuh sangat
/// lambat di debug dan bisa membekukan UI beberapa detik. Cukup metadata +
/// stopwatch durasi request.
class LoggingInterceptor extends Interceptor {
  static const int _maxPreview = 300;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra['__start'] = DateTime.now().millisecondsSinceEpoch;
    // ignore: avoid_print
    logDebug('>>> ${options.method} ${options.path}');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final start = response.requestOptions.extra['__start'] as int?;
    final ms = start == null
        ? '?'
        : '${DateTime.now().millisecondsSinceEpoch - start}ms';
    // Hanya cuplik ukuran/awalan data, bukan seluruhnya.
    final raw = response.data?.toString() ?? '';
    final size = raw.length;
    final preview = size > _maxPreview
        ? '${raw.substring(0, _maxPreview)}… (+${size - _maxPreview} chars)'
        : raw;
    // ignore: avoid_print
    logDebug(
      '<<< ${response.statusCode} ${response.requestOptions.path} '
      '($ms, ${size}B) $preview',
    );
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // ignore: avoid_print
    logDebug(
      '!!! ${err.requestOptions.path} '
      '${err.response?.statusCode ?? ''} ${err.message}',
    );
    super.onError(err, handler);
  }
}