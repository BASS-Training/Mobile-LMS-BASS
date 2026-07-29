// Core module untuk shared dependencies lintas fitur
// Berisi: router, storage, config, logger
import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:lms_mobile_app/src/core/config/flavor_config.dart';
import 'package:lms_mobile_app/src/core/utils/local_storage.dart';

class CoreModule {
  /// Register semua core dependencies
  static Future<void> register() async {
    // Initialize LocalStorage (Hive)
    await LocalStorage.init();

    // Fallback aman untuk FlavorConfig. Pada startup normal, main.dart SUDAH
    // meng-init FlavorConfig (kReleaseMode → production) sebelum ini berjalan,
    // jadi cabang ini tak pernah aktif. Bila toh aktif (mis. dipanggil dari
    // test / entrypoint lain), hormati mode build agar rilis TIDAK pernah
    // memakai URL dev — dulu ini hardcode ke IP LAN dev (jebakan diam-diam).
    if (!FlavorConfig.isInitialized) {
      final fallback = kReleaseMode
          ? ProductionFlavorConfig.config
          : DevelopmentFlavorConfig.config;
      FlavorConfig.init(
        flavor: fallback.flavor,
        apiBaseUrl: fallback.apiBaseUrl,
        enableLogging: fallback.enableLogging,
        enableMockData: fallback.enableMockData,
      );
    }

    // Router sudah static, tidak perlu di-register ke service locator
    // Gunakan AppRouter.router di main.dart
  }
}
