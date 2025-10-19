
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../config/app_config.dart';

class ApiService {
  static final Logger _logger = Logger();

  late Dio _dio;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: AppConfig.apiTimeout,
        receiveTimeout: AppConfig.apiTimeout,
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          _logger.d('REQUEST: ${options.method} ${options.path}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          _logger.d('RESPONSE: ${response.statusCode}');
          return handler.next(response);
        },
        onError: (error, handler) {
          _logger.e('ERROR: ${error.message}');
          return handler.next(error);
        },
      ),
    );
  }

  Future<dynamic> get(String endpoint) async {
    try {
      final response = await _dio.get(endpoint);
      return response.data;
    } on DioException catch (e) {
      _logger.e('GET Error: $e');
      rethrow;
    }
  }

  Future<dynamic> post(String endpoint, dynamic data) async {
    try {
      final response = await _dio.post(endpoint, data: data);
      return response.data;
    } on DioException catch (e) {
      _logger.e('POST Error: $e');
      rethrow;
    }
  }

  Future<dynamic> put(String endpoint, dynamic data) async {
    try {
      final response = await _dio.put(endpoint, data: data);
      return response.data;
    } on DioException catch (e) {
      _logger.e('PUT Error: $e');
      rethrow;
    }
  }

  Future<dynamic> delete(String endpoint) async {
    try {
      final response = await _dio.delete(endpoint);
      return response.data;
    } on DioException catch (e) {
      _logger.e('DELETE Error: $e');
      rethrow;
    }
  }

  void setToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void removeToken() {
    _dio.options.headers.remove('Authorization');
  }
}