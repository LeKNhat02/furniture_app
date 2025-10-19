
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/models/user_model.dart';
import '../core/services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  // Private variables
  final ApiService _apiService = ApiService();
  final String _tokenKey = 'auth_token';

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
        _apiService.setToken(_token!);
        notifyListeners();
      }
    } catch (e) {
      print('Error loading credentials: $e');
    }
  }

  /// Đăng nhập
  /// Returns: true nếu thành công, false nếu thất bại
  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Gọi API đăng nhập
      final response = await _apiService.post('/auth/login', {
        'username': username,
        'password': password,
      });

      // Lấy token từ response
      _token = response['access_token'] ?? response['token'];

      // Lấy thông tin user từ response
      _currentUser = User.fromJson(response['user']);

      // Lưu token vào local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, _token!);

      // Set token vào header API
      _apiService.setToken(_token!);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Đăng nhập thất bại: $e';
      notifyListeners();
      print('Login error: $e');
      return false;
    }
  }

  /// Đăng xuất
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);

      _token = null;
      _currentUser = null;
      _errorMessage = null;
      _apiService.removeToken();

      notifyListeners();
    } catch (e) {
      print('Logout error: $e');
    }
  }

  /// Xóa error message
  void clearErrorMessage() {
    _errorMessage = null;
    notifyListeners();
  }
}