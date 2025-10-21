import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../utils/logger.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  late Dio _dio;

  // Expose _dio để AuthProvider có thể truy cập
  Dio get dio => _dio;

  factory ApiService() {
    return _instance;
  }

  ApiService._internal() {
    _initializeDio();
  }

  void _initializeDio() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: AppConfig.connectTimeout,
        receiveTimeout: AppConfig.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Thêm LogInterceptor
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
        request: true,
        requestHeader: true,
        responseHeader: true,
      ),
    );

    // Thêm custom interceptor cho retry logic
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          Logger.log('API Request: ${options.method} ${options.path}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          Logger.log('API Response: ${response.statusCode} ${response.requestOptions.path}');
          return handler.next(response);
        },
        onError: (error, handler) {
          Logger.log('API Error: ${error.message}');

          // Nếu 401, có thể refresh token (nếu cần)
          if (error.response?.statusCode == 401) {
            Logger.log('Token expired - 401 Unauthorized');
          }

          return handler.next(error);
        },
      ),
    );
  }

  /// GET request
  Future<Response> get(
      String path, {
        Map<String, dynamic>? queryParameters,
        Options? options,
      }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } catch (e) {
      Logger.log('GET Error: $e');
      rethrow;
    }
  }

  /// POST request
  Future<Response> post(
      String path, {
        required dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
      }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } catch (e) {
      Logger.log('POST Error: $e');
      rethrow;
    }
  }

  /// PUT request
  Future<Response> put(
      String path, {
        required dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
      }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } catch (e) {
      Logger.log('PUT Error: $e');
      rethrow;
    }
  }

  /// PATCH request
  Future<Response> patch(
      String path, {
        required dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
      }) async {
    try {
      final response = await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } catch (e) {
      Logger.log('PATCH Error: $e');
      rethrow;
    }
  }

  /// DELETE request
  Future<Response> delete(
      String path, {
        Map<String, dynamic>? queryParameters,
        Options? options,
      }) async {
    try {
      final response = await _dio.delete(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } catch (e) {
      Logger.log('DELETE Error: $e');
      rethrow;
    }
  }

  /// Set authorization token
  void setToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  /// Remove authorization token
  void removeToken() {
    _dio.options.headers.remove('Authorization');
  }

  /// Get current headers
  Map<String, dynamic> getHeaders() {
    return Map.from(_dio.options.headers);
  }
}