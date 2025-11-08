import 'package:flutter/material.dart';
import '../core/models/sale_model.dart';
import '../core/services/sale_service.dart';

class SaleProvider extends ChangeNotifier {
  final SaleService _saleService = SaleService();

  List<SaleModel> _sales = [];
  List<SaleModel> _filteredSales = [];
  SaleModel? _selectedSale;

  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;
  String? _successMessage;

  String? _searchQuery;
  String? _selectedStatus;
  DateTime? _startDate;
  DateTime? _endDate;

  int _currentPage = 1;
  final int _pageSize = 20;
  int _totalSales = 0;

  // ===== GETTERS =====
  List<SaleModel> get sales => _filteredSales.isEmpty && _searchQuery == null && _selectedStatus == null
      ? _sales
      : _filteredSales;

  SaleModel? get selectedSale => _selectedSale;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  String? get selectedStatus => _selectedStatus;
  int get currentPage => _currentPage;
  int get totalSales => _totalSales;

  bool get hasSales => _sales.isNotEmpty;
  bool get hasMorePages => _currentPage * _pageSize < _totalSales;
  bool get isSearching => _searchQuery != null && _searchQuery!.isNotEmpty;
  bool get isFiltered => _selectedStatus != null || _startDate != null || _endDate != null;

  // ===== LOAD SALES =====
  Future<void> loadSales({
    int page = 1,
    int limit = 20,
    bool reset = false,
  }) async {
    if (reset) {
      _sales = [];
      _filteredSales = [];
      _currentPage = 1;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newSales = await _saleService.getSales(
        page: page,
        limit: limit,
        search: _searchQuery,
        status: _selectedStatus,
        startDate: _startDate,
        endDate: _endDate,
      );

      if (reset || page == 1) {
        _sales = newSales;
      } else {
        _sales.addAll(newSales);
      }

      _totalSales = _sales.length;
      _currentPage = page;
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

  // ===== FETCH SALES (Alias) =====
  Future<void> fetchSales({int page = 1, int limit = 20}) async {
    return loadSales(page: page, reset: page == 1);
  }

  // ===== LOAD MORE SALES =====
  Future<void> loadMoreSales() async {
    if (!hasMorePages || _isLoading) return;
    await loadSales(page: _currentPage + 1);
  }

  // ===== GET SALE DETAIL =====
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

  // ===== CREATE SALE =====
  Future<bool> createSale(Map<String, dynamic> saleData) async {
    _isSaving = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final newSale = await _saleService.createSale(saleData);
      _sales.insert(0, newSale);
      _filteredSales = List.from(_sales);
      _totalSales++;
      _successMessage = 'Tạo đơn hàng thành công';
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = _parseError(e);
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  // ===== UPDATE SALE =====
  Future<bool> updateSale(String id, Map<String, dynamic> saleData) async {
    _isSaving = true;
    _errorMessage = null;
    _successMessage = null;
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
      _successMessage = 'Cập nhật đơn hàng thành công';
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = _parseError(e);
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  // ===== DELETE SALE =====
  Future<bool> deleteSale(String id) async {
    _isSaving = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await _saleService.deleteSale(id);
      _sales.removeWhere((s) => s.id == id);
      _filteredSales = List.from(_sales);
      _totalSales--;
      _successMessage = 'Xóa đơn hàng thành công';
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = _parseError(e);
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  // ===== CANCEL SALE =====
  Future<bool> cancelSale(String id) async {
    _isSaving = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await _saleService.cancelSale(id);

      final index = _sales.indexWhere((s) => s.id == id);
      if (index != -1) {
        _sales[index] = _sales[index].copyWith(status: 'cancelled');
      }

      if (_selectedSale?.id == id) {
        _selectedSale = _selectedSale!.copyWith(status: 'cancelled');
      }

      _filteredSales = List.from(_sales);
      _successMessage = 'Hủy đơn hàng thành công';
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = _parseError(e);
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  // ===== SEARCH SALES =====
  void searchSales(String query) {
    _searchQuery = query.trim().isEmpty ? null : query.trim();
    _applyFilters();
  }

  // ===== FILTER BY STATUS =====
  void filterByStatus(String? status) {
    _selectedStatus = status;
    _applyFilters();
  }

  // ===== FILTER BY DATE =====
  void filterByDate(DateTime? startDate, DateTime? endDate) {
    _startDate = startDate;
    _endDate = endDate;
    _applyFilters();
  }

  // ===== APPLY FILTERS =====
  void _applyFilters() {
    _filteredSales = _sales.where((sale) {
      // Search filter
      if (_searchQuery != null && _searchQuery!.isNotEmpty) {
        final orderNumber = sale.orderNumber.toLowerCase();
        final customerName = sale.customerName?.toLowerCase() ?? '';
        final customerPhone = sale.customerPhone?.toLowerCase() ?? '';
        final idString = sale.id.toString();

        if (!orderNumber.contains(_searchQuery!.toLowerCase()) &&
            !customerName.contains(_searchQuery!.toLowerCase()) &&
            !customerPhone.contains(_searchQuery!.toLowerCase()) &&
            !idString.contains(_searchQuery!)) {
          return false;
        }
      }

      // Status filter
      if (_selectedStatus != null && _selectedStatus!.isNotEmpty) {
        if (sale.status != _selectedStatus) {
          return false;
        }
      }

      // Date filter
      if (_startDate != null) {
        if (sale.createdAt.isBefore(_startDate!)) {
          return false;
        }
      }

      if (_endDate != null) {
        if (sale.createdAt.isAfter(_endDate!)) {
          return false;
        }
      }

      return true;
    }).toList();

    notifyListeners();
  }

  // ===== CLEAR FILTERS =====
  void clearFilters() {
    _searchQuery = null;
    _selectedStatus = null;
    _startDate = null;
    _endDate = null;
    _filteredSales = List.from(_sales);
    notifyListeners();
  }

  // ===== GET SALES BY STATUS =====
  List<SaleModel> getSalesByStatus(String status) {
    return _sales.where((s) => s.status == status).toList();
  }

  // ===== GET UNPAID SALES =====
  List<SaleModel> getUnpaidSales() {
    return _sales.where((s) => !s.isPaid).toList();
  }

  // ===== GET TOTAL REVENUE =====
  double getTotalRevenue() {
    return _sales.fold<double>(0, (sum, s) => sum + s.total);
  }

  // ===== GET TOTAL PENDING REVENUE =====
  double getTotalPendingRevenue() {
    return _sales
        .where((s) => !s.isPaid)
        .fold<double>(0, (sum, s) => sum + s.total);
  }

  // ===== GET COMPLETED SALES =====
  int getCompletedSalesCount() {
    return _sales.where((s) => s.status == 'completed').length;
  }

  // ===== PARSE ERROR =====
  String _parseError(dynamic error) {
    debugPrint('Error: $error');
    if (error is Exception) {
      final errorString = error.toString();
      return errorString.replaceAll('Exception: ', '');
    }
    return 'Có lỗi xảy ra: ${error.toString()}';
  }

  // ===== CLEAR ERROR =====
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ===== CLEAR SUCCESS MESSAGE =====
  void clearSuccessMessage() {
    _successMessage = null;
    notifyListeners();
  }

  // ===== CLEAR SELECTED SALE =====
  void clearSelectedSale() {
    _selectedSale = null;
    notifyListeners();
  }

  // ===== REFRESH SALES =====
  Future<void> refreshSales() async {
    await loadSales(reset: true);
  }

  // ===== RESET PROVIDER =====
  void reset() {
    _sales = [];
    _filteredSales = [];
    _selectedSale = null;
    _isLoading = false;
    _isSaving = false;
    _errorMessage = null;
    _successMessage = null;
    _searchQuery = null;
    _selectedStatus = null;
    _startDate = null;
    _endDate = null;
    _currentPage = 1;
    _totalSales = 0;
    notifyListeners();
  }
}