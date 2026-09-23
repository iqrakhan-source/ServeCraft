enum AppEnvironment {
  development,
  staging,
  production,
}

class AppConfig {
  final AppEnvironment environment;
  final String appName;
  final String appVersion;
  final String apiBaseUrl;
  final Duration connectTimeout;
  final Duration receiveTimeout;
  final bool enableLogging;

  // Future feature flags
  final bool enablePromoOffers;
  final bool enableLiveChatSupport;
  final bool enableBiometrics;

  const AppConfig({
    required this.environment,
    required this.appName,
    required this.appVersion,
    required this.apiBaseUrl,
    this.connectTimeout = const Duration(seconds: 30),
    this.receiveTimeout = const Duration(seconds: 30),
    this.enableLogging = true,
    this.enablePromoOffers = true,
    this.enableLiveChatSupport = false,
    this.enableBiometrics = false,
  });

  static late AppConfig _instance;

  static AppConfig get instance => _instance;

  static void initialize({required AppConfig config}) {
    _instance = config;
  }

  bool get isDevelopment => environment == AppEnvironment.development;
  bool get isStaging => environment == AppEnvironment.staging;
  bool get isProduction => environment == AppEnvironment.production;
}
