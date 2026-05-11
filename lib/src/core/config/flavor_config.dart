/// App Flavor configuration
/// Memungkinkan easy switching antara dev/staging/production environment
enum AppFlavor { development, staging, production }

class FlavorConfig {
  final AppFlavor flavor;
  final String apiBaseUrl;
  final bool enableLogging;
  final bool enableMockData;

  const FlavorConfig({
    required this.flavor,
    required this.apiBaseUrl,
    this.enableLogging = true,
    this.enableMockData = false,
  });

  static FlavorConfig? _instance;

  static FlavorConfig get instance {
    assert(_instance != null, 'FlavorConfig must be initialized before use');
    return _instance!;
  }

  static bool get isInitialized => _instance != null;

  static void init({
    required AppFlavor flavor,
    required String apiBaseUrl,
    bool enableLogging = true,
    bool enableMockData = false,
  }) {
    _instance = FlavorConfig(
      flavor: flavor,
      apiBaseUrl: apiBaseUrl,
      enableLogging: enableLogging,
      enableMockData: enableMockData,
    );
  }

  bool get isDevelopment => flavor == AppFlavor.development;
  bool get isStaging => flavor == AppFlavor.staging;
  bool get isProduction => flavor == AppFlavor.production;
}

/// Development configuration
class DevelopmentFlavorConfig {
  static const String apiBaseUrl = 'http://localhost:3000/api';
  static const bool enableLogging = true;
  static const bool enableMockData = true;

  static FlavorConfig get config => FlavorConfig(
    flavor: AppFlavor.development,
    apiBaseUrl: apiBaseUrl,
    enableLogging: enableLogging,
    enableMockData: enableMockData,
  );
}

/// Staging configuration
class StagingFlavorConfig {
  static const String apiBaseUrl = 'https://staging-api.example.com/api';
  static const bool enableLogging = true;
  static const bool enableMockData = false;

  static FlavorConfig get config => FlavorConfig(
    flavor: AppFlavor.staging,
    apiBaseUrl: apiBaseUrl,
    enableLogging: enableLogging,
    enableMockData: enableMockData,
  );
}

/// Production configuration
class ProductionFlavorConfig {
  static const String apiBaseUrl = 'https://api.example.com/api';
  static const bool enableLogging = false;
  static const bool enableMockData = false;

  static FlavorConfig get config => FlavorConfig(
    flavor: AppFlavor.production,
    apiBaseUrl: apiBaseUrl,
    enableLogging: enableLogging,
    enableMockData: enableMockData,
  );
}
