import 'package:dio/dio.dart';
import 'api_service.dart';
import '../utils/logger.dart';

class AuthService {
  final ApiService _apiService;

  AuthService(this._apiService);

  /// Login with username and password
  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    try {
      Logger.log('Login attempt for user: $username');

      final response = await _apiService.post(
        '/auth/login',
        data: {
          'username': username,
          'password': password,
        },
      );

      if (response.statusCode == 200 && response.data is Map) {
        final data = response.data as Map<String, dynamic>;

        // Lưu token
        if (data.containsKey('access_token')) {
          _apiService.setToken(data['access_token']);
          Logger.log('Login successful, token set');
        }

        return data;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
        );
      }
    } on DioException catch (e) {
      Logger.log('Login error: ${e.message}');
      throw ApiService.getErrorMessage(e);
    }
  }

  /// Register new user
  Future<Map<String, dynamic>> register({
    required String username,
    required String password,
    required String email,
    String? fullName,
  }) async {
    try {
      Logger.log('Register attempt for user: $username');

      final response = await _apiService.post(
        '/auth/register',
        data: {
          'username': username,
          'password': password,
          'email': email,
          'full_name': fullName,
        },
      );

      if (response.statusCode == 201 && response.data is Map) {
        Logger.log('Registration successful');
        return response.data as Map<String, dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
        );
      }
    } on DioException catch (e) {
      Logger.log('Register error: ${e.message}');
      throw ApiService.getErrorMessage(e);
    }
  }

  /// Logout current user
  Future<void> logout() async {
    try {
      Logger.log('Logout attempt');

      await _apiService.post(
        '/auth/logout',
        data: {},
      );

      _apiService.removeToken();
      Logger.log('Logout successful');
    } on DioException catch (e) {
      Logger.log('Logout error: ${e.message}');
      // Xóa token dù có lỗi hay không
      _apiService.removeToken();
      rethrow;
    }
  }

  /// Get current user info
  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      Logger.log('Fetching current user');

      final response = await _apiService.get('/auth/me');

      if (response.statusCode == 200 && response.data is Map) {
        Logger.log('Current user fetched');
        return response.data as Map<String, dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
        );
      }
    } on DioException catch (e) {
      Logger.log('Get current user error: ${e.message}');
      throw ApiService.getErrorMessage(e);
    }
  }

  /// Refresh access token
  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    try {
      Logger.log('Refreshing token');

      final response = await _apiService.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200 && response.data is Map) {
        final data = response.data as Map<String, dynamic>;

        if (data.containsKey('access_token')) {
          _apiService.setToken(data['access_token']);
          Logger.log('Token refreshed successfully');
        }

        return data;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
        );
      }
    } on DioException catch (e) {
      Logger.log('Refresh token error: ${e.message}');
      throw ApiService.getErrorMessage(e);
    }
  }

  /// Change password
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      Logger.log('Changing password');

      final response = await _apiService.post(
        '/auth/change-password',
        data: {
          'old_password': oldPassword,
          'new_password': newPassword,
        },
      );

      if (response.statusCode == 200) {
        Logger.log('Password changed successfully');
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
        );
      }
    } on DioException catch (e) {
      Logger.log('Change password error: ${e.message}');
      throw ApiService.getErrorMessage(e);
    }
  }

  /// Request password reset
  Future<void> forgotPassword(String email) async {
    try {
      Logger.log('Forgot password request for: $email');

      final response = await _apiService.post(
        '/auth/forgot-password',
        data: {'email': email},
      );

      if (response.statusCode == 200) {
        Logger.log('Forgot password email sent');
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
        );
      }
    } on DioException catch (e) {
      Logger.log('Forgot password error: ${e.message}');
      throw ApiService.getErrorMessage(e);
    }
  }

  /// Reset password with token
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      Logger.log('Resetting password');

      final response = await _apiService.post(
        '/auth/reset-password',
        data: {
          'token': token,
          'new_password': newPassword,
        },
      );

      if (response.statusCode == 200) {
        Logger.log('Password reset successful');
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
        );
      }
    } on DioException catch (e) {
      Logger.log('Reset password error: ${e.message}');
      throw ApiService.getErrorMessage(e);
    }
  }

  /// Verify email
  Future<void> verifyEmail(String token) async {
    try {
      Logger.log('Verifying email');

      final response = await _apiService.post(
        '/auth/verify-email',
        data: {'token': token},
      );

      if (response.statusCode == 200) {
        Logger.log('Email verified successfully');
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
        );
      }
    } on DioException catch (e) {
      Logger.log('Verify email error: ${e.message}');
      throw ApiService.getErrorMessage(e);
    }
  }

  /// Resend verification email
  Future<void> resendVerificationEmail(String email) async {
    try {
      Logger.log('Resending verification email');

      final response = await _apiService.post(
        '/auth/resend-verification',
        data: {'email': email},
      );

      if (response.statusCode == 200) {
        Logger.log('Verification email sent');
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
        );
      }
    } on DioException catch (e) {
      Logger.log('Resend verification error: ${e.message}');
      throw ApiService.getErrorMessage(e);
    }
  }

  /// Update user profile
  Future<Map<String, dynamic>> updateProfile({
    String? fullName,
    String? email,
    String? phone,
    String? avatar,
  }) async {
    try {
      Logger.log('Updating user profile');

      final data = <String, dynamic>{};
      if (fullName != null) data['full_name'] = fullName;
      if (email != null) data['email'] = email;
      if (phone != null) data['phone'] = phone;
      if (avatar != null) data['avatar'] = avatar;

      final response = await _apiService.put(
        '/auth/profile',
        data: data,
      );

      if (response.statusCode == 200 && response.data is Map) {
        Logger.log('Profile updated successfully');
        return response.data as Map<String, dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
        );
      }
    } on DioException catch (e) {
      Logger.log('Update profile error: ${e.message}');
      throw ApiService.getErrorMessage(e);
    }
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    try {
      await getCurrentUser();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Logout and clear all data
  Future<void> logoutAndClear() async {
    try {
      await logout();
    } catch (e) {
      Logger.log('Error during logout: $e');
    }
    _apiService.removeToken();
  }
}