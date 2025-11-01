import 'package:flutter/material.dart';
import '../core/models/inventory_model.dart';
import '../core/services/inventory_service.dart';

class InventoryProvider extends ChangeNotifier {
  final InventoryService _inventoryService = InventoryService();

  List<InventoryTransaction> _transactions = [];
  InventoryTransaction? _selectedTransaction;

  bool _isLoading = false;
  String? _errorMessage;

  String? _selectedProductId;
  String? _selectedType;
  DateTime? _startDate;
  DateTime? _endDate;

  // Getters
  List<InventoryTransaction> get transactions => _transactions;
  InventoryTransaction? get selectedTransaction => _selectedTransaction;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get selectedProductId => _selectedProductId;
  String? get selectedType => _selectedType;

  // Lấy danh sách giao dịch
  Future<void> fetchTransactions({int page = 1, int limit = 20}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _transactions = await _inventoryService.getTransactions(
        page: page,
        limit: limit,
        productId: _selectedProductId,
        type: _selectedType,
        startDate: _startDate,
        endDate: _endDate,
      );
      _errorMessage = null;
    } catch (e) {
      _errorMessage = _parseError(e);
      _transactions = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Lấy chi tiết giao dịch
  Future<void> fetchTransactionById(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedTransaction = await _inventoryService.getTransactionById(id);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = _parseError(e);
      _selectedTransaction = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Tạo giao dịch mới
  Future<bool> createTransaction(Map<String, dynamic> transactionData) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newTransaction = await _inventoryService.createTransaction(transactionData);
      _transactions.insert(0, newTransaction);
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

  // Xóa giao dịch
  Future<bool> deleteTransaction(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _inventoryService.deleteTransaction(id);
      _transactions.removeWhere((t) => t.id == id);
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

  // Lọc theo sản phẩm
  void filterByProduct(String? productId) {
    _selectedProductId = productId;
    fetchTransactions();
  }

  // Lọc theo loại
  void filterByType(String? type) {
    _selectedType = type;
    fetchTransactions();
  }

  // Lọc theo ngày
  void filterByDate(DateTime? startDate, DateTime? endDate) {
    _startDate = startDate;
    _endDate = endDate;
    fetchTransactions();
  }

  // Xóa bộ lọc
  void clearFilters() {
    _selectedProductId = null;
    _selectedType = null;
    _startDate = null;
    _endDate = null;
    fetchTransactions();
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
    _transactions = [];
    _selectedTransaction = null;
    _isLoading = false;
    _errorMessage = null;
    _selectedProductId = null;
    _selectedType = null;
    _startDate = null;
    _endDate = null;
    notifyListeners();
  }
}

