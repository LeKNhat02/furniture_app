import 'package:flutter/material.dart';
import '../core/models/sale_model.dart';
import '../core/services/sale_service.dart';

class SaleProvider extends ChangeNotifier {
  final SaleService _saleService = SaleService();

  List<SaleModel> _sales = [];
  List<SaleModel> _filteredSales = [];
  SaleModel? _selectedSale;

  bool _isLoading = false;
  String? _errorMessage;

  String? _searchQuery;
  String? _selectedStatus;
  DateTime? _startDate;
  DateTime? _endDate;

  // Getters
  List<SaleModel> get sales => _filteredSales.isEmpty && _searchQuery == null && _selectedStatus == null
      ? _sales
      : _filteredSales;

  SaleModel? get selectedSale => _selectedSale;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get selectedStatus => _selectedStatus;

  // Lấy danh sách bán hàng
  Future<void> fetchSales({int page = 1, int limit = 20}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _sales = await _saleService.getSales(
        page: page,
        limit: limit,
        search: _searchQuery,
        status: _selectedStatus,
        startDate: _startDate,
        endDate: _endDate,
      );
      _filteredSales = List.from(_sales);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = _parseError(e);
      _sales = [];
      _filteredSales = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Lấy chi tiết bán hàng
  Future<void> fetchSaleById(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedSale = await _saleService.getSaleById(id);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = _parseError(e);
      _selectedSale = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Tạo bán hàng mới
  Future<bool> createSale(Map<String, dynamic> saleData) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newSale = await _saleService.createSale(saleData);
      _sales.insert(0, newSale);
      _filteredSales = List.from(_sales);
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

  // Cập nhật bán hàng
  Future<bool> updateSale(String id, Map<String, dynamic> saleData) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedSale = await _saleService.updateSale(id, saleData);

      final index = _sales.indexWhere((s) => s.id == id);
      if (index != -1) {
        _sales[index] = updatedSale;
      }

      if (_selectedSale?.id == id) {
        _selectedSale = updatedSale;
      }

      _filteredSales = List.from(_sales);
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

  // Xóa bán hàng
  Future<bool> deleteSale(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _saleService.deleteSale(id);
      _sales.removeWhere((s) => s.id == id);
      _filteredSales = List.from(_sales);
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

  // Hủy đơn hàng
  Future<bool> cancelSale(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _saleService.cancelSale(id);
      await fetchSales();
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
  void searchSales(String query) {
    _searchQuery = query.trim();
    _applyFilters();
  }

  // Lọc theo trạng thái
  void filterByStatus(String? status) {
    _selectedStatus = status;
    _applyFilters();
  }

  // Lọc theo ngày
  void filterByDate(DateTime? startDate, DateTime? endDate) {
    _startDate = startDate;
    _endDate = endDate;
    fetchSales();
  }

  // Áp dụng bộ lọc
  void _applyFilters() {
    _filteredSales = _sales.where((sale) {
      if (_searchQuery != null && _searchQuery!.isNotEmpty) {
        final orderNumber = sale.orderNumber.toLowerCase();
        final customerName = sale.customerName?.toLowerCase() ?? '';
        if (!orderNumber.contains(_searchQuery!.toLowerCase()) &&
            !customerName.contains(_searchQuery!.toLowerCase())) {
          return false;
        }
      }

      if (_selectedStatus != null) {
        if (sale.status != _selectedStatus) {
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
    _selectedStatus = null;
    _startDate = null;
    _endDate = null;
    _filteredSales = List.from(_sales);
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
    _sales = [];
    _filteredSales = [];
    _selectedSale = null;
    _isLoading = false;
    _errorMessage = null;
    _searchQuery = null;
    _selectedStatus = null;
    _startDate = null;
    _endDate = null;
    notifyListeners();
  }
}

