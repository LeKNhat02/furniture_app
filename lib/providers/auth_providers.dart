
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/models/user_model.dart';
import '../core/services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final String _tokenKey = 'auth_token';

  User? _currentUser;
  String? _token;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  String? get token => _token;
  bool get isLoggedIn => _token != null;
  bool get isLoading => _isLoading;
  bool get isAdmin => _currentUser?.role == 'admin';

  AuthProvider() {
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);

    if (_token != null) {
      _apiService.setToken(_token!);
      notifyListeners();
    }
  }

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.post('/auth/login', {
        'username': username,
        'password': password,
      });

      _token = response['access_token'];
      _currentUser = User.fromJson(response['user']);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, _token!);

      _apiService.setToken(_token!);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);

    _token = null;
    _currentUser = null;
    _apiService.removeToken();

    notifyListeners();
  }
}