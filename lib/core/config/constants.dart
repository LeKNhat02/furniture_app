// lib/core/config/constants.dart

import 'package:flutter/material.dart';

class AppConstants {
  // API Configuration
  static const String apiBaseUrl = 'http://10.0.2.2:8000/api';
  static const Duration apiTimeoutDuration = Duration(seconds: 30);

  // App Strings
  static const String appName = 'Furniture Management';
  static const String appVersion = '1.0.0';

  // Product Categories
  static const List<String> productCategories = [
    'Bàn',
    'Ghế',
    'Tủ',
    'Kệ',
    'Giường',
    'Trang Trí',
    'Khác'
  ];

  // Customer Types
  static const List<String> customerTypes = ['Bán lẻ', 'Bán buôn'];

  // Payment Methods
  static const List<String> paymentMethods = [
    'Tiền mặt',
    'Chuyển khoản',
    'Thẻ tín dụng'
  ];

  // Role Types
  static const String roleAdmin = 'admin';
  static const String roleStaff = 'staff';

  // Discount Types
  static const String discountPercentage = 'percentage';
  static const String discountFixedAmount = 'fixed_amount';

  // Date Format
  static const String dateFormat = 'dd/MM/yyyy';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';

  // Currency - ✅ THÊM CÁC DÒNG NÀY
  static const String currencySymbol = '₫';
  static const String currencyCode = 'VND';
}

// Màu sắc
class AppColors {
  static const primary = Color(0xFF1976D2);
  static const secondary = Color(0xFF424242);
  static const success = Color(0xFF4CAF50);
  static const warning = Color(0xFFFFC107);
  static const error = Color(0xFFF44336);
  static const info = Color(0xFF2196F3);
  static const background = Color(0xFFFAFAFA);
  static const surface = Color(0xFFFFFFFF);
}

// Text Styles
class AppTextStyles {
  static const headingLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
  );

  static const headingMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  static const bodyLarge = TextStyle(
    fontSize: 16,
  );

  static const bodyMedium = TextStyle(
    fontSize: 14,
  );
}