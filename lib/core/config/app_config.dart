
import 'constants.dart';

class AppConfig {
  static const String apiBaseUrl = AppConstants.apiBaseUrl;
  static const Duration apiTimeout = AppConstants.apiTimeoutDuration;

  static bool get isDevelopment => true;

  static String get baseUrl => apiBaseUrl;

  static bool get enableLogging => isDevelopment;
}