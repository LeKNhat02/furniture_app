import 'package:flutter/material.dart';
import '../core/models/customer_model.dart';
import '../core/services/customer_service.dart';

class CustomerProvider extends ChangeNotifier {
  final CustomerService _customerService = CustomerService();

  List<CustomerModel> _customers = [];
  List<CustomerModel> _filteredCustomers = [];
  CustomerModel? _selectedCustomer;

  bool _isLoading = false;
  String? _errorMessage;

  String? _searchQuery;

  // Getters
  List<CustomerModel> get customers => _filteredCustomers.isEmpty && _searchQuery == null
      ? _customers
      : _filteredCustomers;

  CustomerModel? get selectedCustomer => _selectedCustomer;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Lấy danh sách khách hàng
  Future<void> fetchCustomers({int page = 1, int limit = 20}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _customers = await _customerService.getCustomers(
        page: page,
        limit: limit,
      );
      _filteredCustomers = List.from(_customers);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = _parseError(e);
      _customers = [];
      _filteredCustomers = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Lấy chi tiết khách hàng
  Future<void> fetchCustomerById(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedCustomer = await _customerService.getCustomerById(id);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = _parseError(e);
      _selectedCustomer = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Tạo khách hàng mới
  Future<bool> createCustomer(Map<String, dynamic> customerData) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newCustomer = await _customerService.createCustomer(customerData);
      _customers.add(newCustomer);
      _filteredCustomers = List.from(_customers);
      _errorMessage = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _parseError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Cập nhật khách hàng
  Future<bool> updateCustomer(String id, Map<String, dynamic> customerData) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedCustomer = await _customerService.updateCustomer(id, customerData);

      final index = _customers.indexWhere((c) => c.id == id);
      if (index != -1) {
        _customers[index] = updatedCustomer;
      }

      if (_selectedCustomer?.id == id) {
        _selectedCustomer = updatedCustomer;
      }

      _filteredCustomers = List.from(_customers);
      _errorMessage = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _parseError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Xóa khách hàng
  Future<bool> deleteCustomer(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _customerService.deleteCustomer(id);
      _customers.removeWhere((c) => c.id == id);
      _filteredCustomers = List.from(_customers);
      _errorMessage = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _parseError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Tìm kiếm khách hàng
  void searchCustomers(String query) {
    _searchQuery = query.trim();
    _applyFilters();
  }

  /// Áp dụng bộ lọc
  void _applyFilters() {
    _filteredCustomers = _customers.where((customer) {
      if (_searchQuery != null && _searchQuery!.isNotEmpty) {
        final name = customer.name.toLowerCase();
        final phone = customer.phone;
        final email = customer.email?.toLowerCase() ?? '';
        if (!name.contains(_searchQuery!.toLowerCase()) &&
            !phone.contains(_searchQuery!) &&
            !email.contains(_searchQuery!.toLowerCase())) {
          return false;
        }
      }
      return true;
    }).toList();

    notifyListeners();
  }

  /// Xóa bộ lọc
  void clearFilters() {
    _searchQuery = null;
    _filteredCustomers = List.from(_customers);
    notifyListeners();
  }

  /// Parse lỗi
  String _parseError(dynamic error) {
    print('Error: $error');
    if (error is Exception) {
      final errorString = error.toString();
      return errorString.replaceAll('Exception: ', '');
    }
    return 'Có lỗi xảy ra: ${error.toString()}';
  }

  /// Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Reset provider
  void reset() {
    _customers = [];
    _filteredCustomers = [];
    _selectedCustomer = null;
    _isLoading = false;
    _errorMessage = null;
    _searchQuery = null;
    notifyListeners();
  }
}