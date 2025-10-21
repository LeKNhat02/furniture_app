/// Logger utility cho debug và monitoring
class Logger {
  static const String _prefix = '[FURNITURE_APP]';
  static bool _enableLogging = true; // Có thể disable logs trong production

  /// Log thông tin thường
  static void log(String message, {String tag = 'INFO'}) {
    if (!_enableLogging) return;

    final timestamp = DateTime.now().toString();
    print('$_prefix [$tag] $timestamp - $message');
  }

  /// Log thông tin chi tiết (debug)
  static void debug(String message, {String tag = 'DEBUG'}) {
    if (!_enableLogging) return;

    final timestamp = DateTime.now().toString();
    print('$_prefix [$tag] $timestamp - $message');
  }

  /// Log warning
  static void warning(String message, {String tag = 'WARNING'}) {
    if (!_enableLogging) return;

    final timestamp = DateTime.now().toString();
    print('$_prefix [$tag] $timestamp - ⚠️ $message');
  }

  /// Log error
  static void error(
      String message, {
        String tag = 'ERROR',
        dynamic error,
        StackTrace? stackTrace,
      }) {
    if (!_enableLogging) return;

    final timestamp = DateTime.now().toString();
    print('$_prefix [$tag] $timestamp - ❌ $message');

    if (error != null) {
      print('$_prefix [$tag] Error: $error');
    }

    if (stackTrace != null) {
      print('$_prefix [$tag] StackTrace:\n$stackTrace');
    }
  }

  /// Log API request
  static void logApiRequest(
      String method,
      String url, {
        dynamic data,
        Map<String, dynamic>? headers,
      }) {
    if (!_enableLogging) return;

    print('$_prefix [API_REQUEST] 🔵 $method $url');

    if (headers != null && headers.isNotEmpty) {
      print('$_prefix [API_REQUEST] Headers: $headers');
    }

    if (data != null) {
      print('$_prefix [API_REQUEST] Body: $data');
    }
  }

  /// Log API response
  static void logApiResponse(
      String method,
      String url,
      int statusCode, {
        dynamic data,
      }) {
    if (!_enableLogging) return;

    final icon = statusCode >= 200 && statusCode < 300 ? '✅' : '⚠️';
    print('$_prefix [API_RESPONSE] $icon $method $url - Status: $statusCode');

    if (data != null) {
      print('$_prefix [API_RESPONSE] Response: $data');
    }
  }

  /// Log API error
  static void logApiError(
      String method,
      String url,
      dynamic error, {
        int? statusCode,
      }) {
    if (!_enableLogging) return;

    print('$_prefix [API_ERROR] ❌ $method $url');

    if (statusCode != null) {
      print('$_prefix [API_ERROR] Status: $statusCode');
    }

    print('$_prefix [API_ERROR] Error: $error');
  }

  /// Enable/Disable logging
  static void setLoggingEnabled(bool enabled) {
    _enableLogging = enabled;
    if (enabled) {
      print('$_prefix Logging ENABLED');
    } else {
      print('$_prefix Logging DISABLED');
    }
  }

  /// Clear logs (không thực sự xóa được, chỉ log một dấu)
  static void separator({String char = '='}) {
    if (!_enableLogging) return;

    print('$_prefix ${char * 50}');
  }
}