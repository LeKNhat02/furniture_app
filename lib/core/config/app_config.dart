// lib/core/config/app_config.dart

class AppConfig {
  // Thay đổi từ localhost sang MongoDB Atlas URL
  static const String baseUrl = 'https://your-api-domain.com/api';
  // Hoặc nếu deploy FastAPI: https://your-app.railway.app/api

  static const String mongodbUrl = 'mongodb+srv://username:password@cluster0.xxxxx.mongodb.net/furniture_app?retryWrites=true&w=majority';

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  static bool isProduction = true; // true nếu production, false nếu development
}