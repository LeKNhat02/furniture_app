// lib/core/config/app_config.dart

class AppConfig {
  // URL API cho các môi trường
  // Dev: khi chạy Android emulator, dùng 10.0.2.2 để trỏ về localhost của máy host
  static const String _devBaseUrl = 'http://10.0.2.2:8000/api';
  static const String _prodBaseUrl = 'https://your-api-domain.com/api';

  // Nếu muốn ghi đè baseUrl ở runtime (ví dụ từ settings), set _overrideBaseUrl
  static String? _overrideBaseUrl;

  // Mặc định để development để bạn phát triển frontend trước khi backend sẵn sàng.
  // Đổi thành true khi deploy production.
  static bool isProduction = false;

  // Lấy baseUrl hiện tại (ưu tiên override nếu có)
  static String get baseUrl => _overrideBaseUrl ?? (isProduction ? _prodBaseUrl : _devBaseUrl);

  // Thay đổi baseUrl tạm thời (ví dụ dùng để test với một server khác)
  static void setOverrideBaseUrl(String? url) {
    _overrideBaseUrl = url;
  }

  // MongoDB connection string (giữ nguyên làm ví dụ). Thông thường backend sẽ dùng biến môi trường
  // để lưu connection string; frontend không cần dùng trực tiếp.
  static const String mongodbUrl = 'mongodb+srv://username:password@cluster0.xxxxx.mongodb.net/furniture_app?retryWrites=true&w=majority';

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}