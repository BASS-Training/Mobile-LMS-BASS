/// Application configuration untuk different flavors (dev, staging, production)
class AppConfig {
  final String appName;
  final String apiBaseUrl;
  final bool isDevelopment;
  final bool enableLogging;

  AppConfig({
    required this.appName,
    required this.apiBaseUrl,
    required this.isDevelopment,
    required this.enableLogging,
  });

  /// Development configuration
  static AppConfig development() {
    return AppConfig(
      appName: 'LMS Mobile (Dev)',
      apiBaseUrl: 'https://api-dev.example.com/api',
      isDevelopment: true,
      enableLogging: true,
    );
  }

  /// Staging configuration
  static AppConfig staging() {
    return AppConfig(
      appName: 'LMS Mobile (Staging)',
      apiBaseUrl: 'https://api-staging.example.com/api',
      isDevelopment: false,
      enableLogging: true,
    );
  }

  /// Production configuration
  static AppConfig production() {
    return AppConfig(
      appName: 'LMS Mobile',
      apiBaseUrl: 'https://api.example.com/api',
      isDevelopment: false,
      enableLogging: false,
    );
  }
}
