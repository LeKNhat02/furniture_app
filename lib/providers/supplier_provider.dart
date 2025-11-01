import 'package:flutter/material.dart';
import '../core/models/supplier_model.dart';
import '../core/services/supplier_service.dart';

class SupplierProvider extends ChangeNotifier {
  final SupplierService _supplierService = SupplierService();

  List<SupplierModel> _suppliers = [];
  List<SupplierModel> _filteredSuppliers = [];
  SupplierModel? _selectedSupplier;

  bool _isLoading = false;
  String? _errorMessage;

  String? _searchQuery;

  // Getters
  List<SupplierModel> get suppliers => _filteredSuppliers.isEmpty && _searchQuery == null
      ? _suppliers
      : _filteredSuppliers;

  SupplierModel? get selectedSupplier => _selectedSupplier;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Lấy danh sách nhà cung cấp
  Future<void> fetchSuppliers({int page = 1, int limit = 20}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _suppliers = await _supplierService.getSuppliers(
        page: page,
        limit: limit,
        search: _searchQuery,
      );
      _filteredSuppliers = List.from(_suppliers);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = _parseError(e);
      _suppliers = [];
      _filteredSuppliers = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Lấy chi tiết nhà cung cấp
  Future<void> fetchSupplierById(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedSupplier = await _supplierService.getSupplierById(id);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = _parseError(e);
      _selectedSupplier = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Tạo nhà cung cấp mới
  Future<bool> createSupplier(Map<String, dynamic> supplierData) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newSupplier = await _supplierService.createSupplier(supplierData);
      _suppliers.add(newSupplier);
      _filteredSuppliers = List.from(_suppliers);
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

  // Cập nhật nhà cung cấp
  Future<bool> updateSupplier(String id, Map<String, dynamic> supplierData) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedSupplier = await _supplierService.updateSupplier(id, supplierData);

      final index = _suppliers.indexWhere((s) => s.id == id);
      if (index != -1) {
        _suppliers[index] = updatedSupplier;
      }

      if (_selectedSupplier?.id == id) {
        _selectedSupplier = updatedSupplier;
      }

      _filteredSuppliers = List.from(_suppliers);
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

  // Xóa nhà cung cấp
  Future<bool> deleteSupplier(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _supplierService.deleteSupplier(id);
      _suppliers.removeWhere((s) => s.id == id);
      _filteredSuppliers = List.from(_suppliers);
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

  // Tìm kiếm
  void searchSuppliers(String query) {
    _searchQuery = query.trim();
    _applyFilters();
  }

  // Áp dụng bộ lọc
  void _applyFilters() {
    _filteredSuppliers = _suppliers.where((supplier) {
      if (_searchQuery != null && _searchQuery!.isNotEmpty) {
        final name = supplier.name.toLowerCase();
        final phone = supplier.phone;
        final email = supplier.email?.toLowerCase() ?? '';
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

  // Xóa bộ lọc
  void clearFilters() {
    _searchQuery = null;
    _filteredSuppliers = List.from(_suppliers);
    notifyListeners();
  }

  // Parse lỗi
  String _parseError(dynamic error) {
    print('Error: $error');
    if (error is Exception) {
      final errorString = error.toString();
      return errorString.replaceAll('Exception: ', '');
    }
    return 'Có lỗi xảy ra: ${error.toString()}';
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Reset provider
  void reset() {
    _suppliers = [];
    _filteredSuppliers = [];
    _selectedSupplier = null;
    _isLoading = false;
    _errorMessage = null;
    _searchQuery = null;
    notifyListeners();
  }
}

