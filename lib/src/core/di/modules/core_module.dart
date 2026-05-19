// Core module untuk shared dependencies lintas fitur
// Berisi: router, storage, config, logger
import 'package:lms_mobile_app/src/core/config/flavor_config.dart';
import 'package:lms_mobile_app/src/core/utils/local_storage.dart';

class CoreModule {
  /// Register semua core dependencies
  static Future<void> register() async {
    // Initialize LocalStorage (Hive)
    await LocalStorage.init();

    // Initialize FlavorConfig jika belum
    if (!FlavorConfig.isInitialized) {
      FlavorConfig.init(
        flavor: AppFlavor.development,
        apiBaseUrl: DevelopmentFlavorConfig.apiBaseUrl,
        enableLogging: DevelopmentFlavorConfig.enableLogging,
        enableMockData: DevelopmentFlavorConfig.enableMockData,
      );
    }

    // Router sudah static, tidak perlu di-register ke service locator
    // Gunakan AppRouter.router di main.dart
  }
}
