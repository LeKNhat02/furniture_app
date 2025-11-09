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

    // Thêm custom interceptor cho retry logic & token refresh
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
    } on DioException catch (e) {
      Logger.log('GET Error: $e');
      _handleError(e);
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
    } on DioException catch (e) {
      Logger.log('POST Error: $e');
      _handleError(e);
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
    } on DioException catch (e) {
      Logger.log('PUT Error: $e');
      _handleError(e);
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
    } on DioException catch (e) {
      Logger.log('PATCH Error: $e');
      _handleError(e);
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
    } on DioException catch (e) {
      Logger.log('DELETE Error: $e');
      _handleError(e);
      rethrow;
    }
  }

  /// Upload file
  Future<Response> uploadFile(
      String path, {
        required String filePath,
        String? fileName,
        Map<String, dynamic>? additionalData,
      }) async {
    try {
      final file = await MultipartFile.fromFile(
        filePath,
        filename: fileName ?? filePath.split('/').last,
      );

      final formData = FormData.fromMap({
        'file': file,
        if (additionalData != null) ...additionalData,
      });

      final response = await _dio.post(
        path,
        data: formData,
      );
      return response;
    } on DioException catch (e) {
      Logger.log('Upload Error: $e');
      _handleError(e);
      rethrow;
    }
  }

  /// Handle error
  void _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        Logger.log('Connection Timeout');
        break;
      case DioExceptionType.sendTimeout:
        Logger.log('Send Timeout');
        break;
      case DioExceptionType.receiveTimeout:
        Logger.log('Receive Timeout');
        break;
      case DioExceptionType.badResponse:
        _handleBadResponse(error.response);
        break;
      case DioExceptionType.cancel:
        Logger.log('Request Cancelled');
        break;
      case DioExceptionType.unknown:
        Logger.log('Unknown Error: ${error.message}');
        break;
      default:
        Logger.log('Error: ${error.message}');
    }
  }

  /// Handle bad response
  void _handleBadResponse(Response? response) {
    if (response == null) return;

    Logger.log('Bad Response: ${response.statusCode}');

    final data = response.data;
    if (data is Map<String, dynamic>) {
      if (data.containsKey('detail')) {
        Logger.log('Error Detail: ${data['detail']}');
      } else if (data.containsKey('message')) {
        Logger.log('Error Message: ${data['message']}');
      }
    }
  }

  /// Get error message
  static String getErrorMessage(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'Timeout - Vui lòng kiểm tra kết nối internet';
        case DioExceptionType.badResponse:
          if (error.response?.statusCode == 401) {
            return 'Phiên làm việc hết hạn - Vui lòng đăng nhập lại';
          } else if (error.response?.statusCode == 403) {
            return 'Bạn không có quyền truy cập';
          } else if (error.response?.statusCode == 404) {
            return 'Dữ liệu không tìm thấy';
          } else if (error.response?.statusCode == 500) {
            return 'Lỗi server - Vui lòng thử lại sau';
          }
          // Kiểm tra response body có message không
          final data = error.response?.data;
          if (data is Map<String, dynamic>) {
            if (data.containsKey('detail')) {
              return data['detail'];
            } else if (data.containsKey('message')) {
              return data['message'];
            }
          }
          return 'Lỗi: ${error.response?.statusCode}';
        case DioExceptionType.cancel:
          return 'Yêu cầu bị hủy';
        case DioExceptionType.unknown:
          return 'Lỗi mạng - ${error.message}';
        default:
          return 'Đã xảy ra lỗi';
      }
    }
    return error.toString();
  }

  /// Set authorization token
  void setToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
    Logger.log('Token set');
  }

  /// Remove authorization token
  void removeToken() {
    _dio.options.headers.remove('Authorization');
    Logger.log('Token removed');
  }

  /// Get current headers
  Map<String, dynamic> getHeaders() {
    return Map.from(_dio.options.headers);
  }

  /// Update base URL (runtime)
  void updateBaseUrl(String newUrl) {
    _dio.options.baseUrl = newUrl;
    Logger.log('Base URL updated to: $newUrl');
  }

  /// Get current base URL
  String getBaseUrl() {
    return _dio.options.baseUrl;
  }
}