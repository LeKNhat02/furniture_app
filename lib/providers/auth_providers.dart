import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import '../core/models/user_model.dart';
import '../core/services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  // Private variables
  final ApiService _apiService = ApiService();
  final String _tokenKey = 'auth_token';
  final String _userKey = 'user_data';

  User? _currentUser;
  String? _token;
  bool _isLoading = false;
  String? _errorMessage;

  // Public getters
  User? get currentUser => _currentUser;
  String? get token => _token;
  bool get isLoggedIn => _token != null;
  bool get isLoading => _isLoading;
  bool get isAdmin => _currentUser?.role == 'admin';
  String? get errorMessage => _errorMessage;

  // Constructor
  AuthProvider() {
    _loadSavedCredentials();
  }

  /// Tải thông tin đã lưu từ local storage
  Future<void> _loadSavedCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString(_tokenKey);

      if (_token != null) {
        // Set token vào header của API
        _setAuthToken(_token!);
        notifyListeners();
      }
    } catch (e) {
      print('Error loading credentials: $e');
    }
  }

  /// Set token vào header API
  void _setAuthToken(String token) {
    _apiService.dio.options.headers['Authorization'] = 'Bearer $token';
  }

  /// Xóa token khỏi header API
  void _removeAuthToken() {
    _apiService.dio.options.headers.remove('Authorization');
  }

  /// Đăng nhập
  /// Returns: true nếu thành công, false nếu thất bại
  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Gọi API đăng nhập
      final response = await _apiService.post('/auth/login', data: {
        'username': username,
        'password': password,
      });

      // Kiểm tra status code
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Đăng nhập thất bại');
      }

      // Lấy dữ liệu từ response
      final responseData = response.data;

      // Xử lý response từ API
      if (responseData is Map<String, dynamic>) {
        // Lấy token từ response
        _token = responseData['access_token'] ??
            responseData['token'] ??
            responseData['data']['access_token'];

        if (_token == null) {
          throw Exception('Token không được trả về từ server');
        }

        // Lấy thông tin user
        final userData = responseData['user'] ?? responseData['data']['user'];

        if (userData != null) {
          _currentUser = User.fromJson(userData);
        }

        // Lưu token vào local storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_tokenKey, _token!);

        // Set token vào header API
        _setAuthToken(_token!);

        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
        return true;
      } else {
        throw Exception('Response không hợp lệ');
      }
    } on DioException catch (e) {
      _isLoading = false;
      _errorMessage = _handleDioError(e);
      notifyListeners();
      print('Login DioException: $_errorMessage');
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Đăng nhập thất bại: ${e.toString()}';
      notifyListeners();
      print('Login error: $e');
      return false;
    }
  }

  /// Đăng xuất
  Future<void> logout() async {
    try {
      // Gọi API logout (tùy chọn)
      try {
        await _apiService.post('/auth/logout', data: {});
      } catch (e) {
        print('Logout API error: $e');
      }

      // Xóa token từ local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_userKey);

      // Reset state
      _token = null;
      _currentUser = null;
      _errorMessage = null;

      // Xóa token khỏi header API
      _removeAuthToken();

      notifyListeners();
    } catch (e) {
      print('Logout error: $e');
      _errorMessage = 'Logout thất bại';
      notifyListeners();
    }
  }

  /// Đăng ký user mới
  Future<bool> register(String username, String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.post('/auth/register', data: {
        'username': username,
        'email': email,
        'password': password,
      });

      if (response.statusCode == 201 || response.statusCode == 200) {
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
        return true;
      } else {
        throw Exception('Đăng ký thất bại');
      }
    } on DioException catch (e) {
      _isLoading = false;
      _errorMessage = _handleDioError(e);
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Đăng ký thất bại: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// Refresh token
  Future<bool> refreshToken() async {
    try {
      final response = await _apiService.post('/auth/refresh', data: {});

      if (response.statusCode == 200) {
        _token = response.data['access_token'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_tokenKey, _token!);

        _setAuthToken(_token!);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Refresh token error: $e');
      return false;
    }
  }

  /// Xóa error message
  void clearErrorMessage() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Xử lý lỗi Dio
  String _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'Kết nối timeout. Vui lòng kiểm tra internet';
      case DioExceptionType.receiveTimeout:
        return 'Server không phản hồi. Vui lòng thử lại';
      case DioExceptionType.sendTimeout:
        return 'Gửi dữ liệu timeout';
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 401) {
          return 'Thông tin đăng nhập không chính xác';
        } else if (statusCode == 400) {
          return e.response?.data['message'] ?? 'Yêu cầu không hợp lệ';
        } else if (statusCode == 500) {
          return 'Lỗi server. Vui lòng thử lại sau';
        }
        return 'Lỗi: $statusCode';
      case DioExceptionType.cancel:
        return 'Yêu cầu bị hủy';
      case DioExceptionType.unknown:
        return 'Lỗi không xác định. Vui lòng kiểm tra kết nối internet';
      default:
        return 'Có lỗi xảy ra: ${e.message}';
    }
  }
}