import 'package:flutter/material.dart';
import '../core/models/payment_model.dart';
import '../core/services/api_service.dart';
import '../core/services/payment_service.dart';

class PaymentProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  late PaymentService _paymentService;

  List<PaymentModel> _payments = [];
  List<PaymentModel> _filteredPayments = [];
  PaymentModel? _selectedPayment;
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;
  String? _successMessage;
  int _currentPage = 1;
  final int _pageSize = 20;
  int _totalPayments = 0;
  String _searchQuery = '';
  String? _selectedStatus;
  String? _selectedPaymentMethod;

  PaymentProvider() {
    _paymentService = PaymentService(_apiService);
  }

  // ===== GETTERS =====
  List<PaymentModel> get payments =>
      _filteredPayments.isEmpty ? _payments : _filteredPayments;
  PaymentModel? get selectedPayment => _selectedPayment;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  int get currentPage => _currentPage;
  int get totalPayments => _totalPayments;
  String get searchQuery => _searchQuery;
  String? get selectedStatus => _selectedStatus;
  String? get selectedPaymentMethod => _selectedPaymentMethod;

  bool get hasMorePages => _currentPage * _pageSize < _totalPayments;
  bool get hasPayments => _payments.isNotEmpty;
  bool get isSearching => _searchQuery.isNotEmpty;

  // ===== LOAD PAYMENTS =====
  Future<void> loadPayments({
    int page = 1,
    String? status,
    String? paymentMethod,
    bool reset = false,
  }) async {
    if (reset) {
      _payments = [];
      _filteredPayments = [];
      _currentPage = 1;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newPayments = await _paymentService.getPayments(
        page: page,
        limit: _pageSize,
        status: status,
        paymentMethod: paymentMethod,
      );

      if (reset || page == 1) {
        _payments = newPayments;
      } else {
        _payments.addAll(newPayments);
      }

      _totalPayments = _payments.length;
      _currentPage = page;
      _filteredPayments = [];
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Lỗi tải thanh toán: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchPaymentById(String paymentId) async {
    await getPaymentDetail(paymentId);
  }

  Future<bool> refundPayment(String paymentId, {String? notes}) async {
    _isSaving = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final refundData = {
        'status': 'refunded',
      };

      if (notes != null && notes.isNotEmpty) {
        refundData['notes'] = notes;
      }

      final updatedPayment = await _paymentService.updatePayment(
        paymentId,
        refundData,
      );

      // Cập nhật trong danh sách payments
      final index = _payments.indexWhere((p) => p.id == paymentId);
      if (index != -1) {
        _payments[index] = updatedPayment;
      }

      // Cập nhật selected payment nếu đang xem
      if (_selectedPayment?.id == paymentId) {
        _selectedPayment = updatedPayment;
      }

      _successMessage = 'Hoàn tiền thành công';
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Lỗi hoàn tiền: ${e.toString()}';
      notifyListeners();
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  // ===== FETCH PAYMENTS (Alias) =====
  Future<void> fetchPayments({int page = 1}) async {
    return loadPayments(page: page, reset: page == 1);
  }

  // ===== LOAD MORE PAYMENTS =====
  Future<void> loadMorePayments() async {
    if (!hasMorePages || _isLoading) return;
    await loadPayments(page: _currentPage + 1);
  }

  // ===== GET PAYMENT DETAIL =====
  Future<bool> getPaymentDetail(String paymentId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedPayment = await _paymentService.getPaymentById(paymentId);
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Lỗi: ${e.toString()}';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ===== CREATE PAYMENT =====
  Future<bool> createPayment(Map<String, dynamic> paymentData) async {
    _isSaving = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final newPayment = await _paymentService.createPayment(paymentData);
      _payments.insert(0, newPayment);
      _totalPayments++;
      _successMessage = 'Tạo thanh toán thành công';
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Lỗi tạo thanh toán: ${e.toString()}';
      notifyListeners();
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  // ===== UPDATE PAYMENT =====
  Future<bool> updatePayment(
      String paymentId,
      Map<String, dynamic> paymentData,
      ) async {
    _isSaving = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final updatedPayment = await _paymentService.updatePayment(
        paymentId,
        paymentData,
      );

      final index = _payments.indexWhere((p) => p.id == paymentId);
      if (index != -1) {
        _payments[index] = updatedPayment;
      }

      if (_selectedPayment?.id == paymentId) {
        _selectedPayment = updatedPayment;
      }

      _successMessage = 'Cập nhật thanh toán thành công';
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Lỗi cập nhật thanh toán: ${e.toString()}';
      notifyListeners();
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  // ===== DELETE PAYMENT =====
  Future<bool> deletePayment(String paymentId) async {
    _isSaving = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await _paymentService.deletePayment(paymentId);
      _payments.removeWhere((p) => p.id == paymentId);
      _totalPayments--;
      _successMessage = 'Xóa thanh toán thành công';
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Lỗi xóa thanh toán: ${e.toString()}';
      notifyListeners();
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  // ===== GET PAYMENTS BY STATUS =====
  List<PaymentModel> getPaymentsByStatus(String status) {
    return _payments.where((p) => p.status == status).toList();
  }

  // ===== GET PAYMENTS BY METHOD =====
  List<PaymentModel> getPaymentsByMethod(String method) {
    return _payments.where((p) => p.paymentMethod == method).toList();
  }

  // ===== GET CASH PAYMENTS =====
  List<PaymentModel> getCashPayments() {
    return _payments.where((p) => p.isCash).toList();
  }

  // ===== GET TRANSFER PAYMENTS =====
  List<PaymentModel> getTransferPayments() {
    return _payments.where((p) => p.isTransfer).toList();
  }

  // ===== GET TOTAL REVENUE =====
  double getTotalRevenue() {
    return _payments.fold<double>(
      0,
          (sum, p) => p.isCompleted ? sum + p.amount : sum,
    );
  }

  // ===== GET TOTAL PENDING =====
  double getTotalPending() {
    return _payments.fold<double>(
      0,
          (sum, p) => p.isPending ? sum + p.amount : sum,
    );
  }

  // ===== GET CASH REVENUE =====
  double getCashRevenue() {
    return _payments.fold<double>(
      0,
          (sum, p) => p.isCash && p.isCompleted ? sum + p.amount : sum,
    );
  }

  // ===== GET TRANSFER REVENUE =====
  double getTransferRevenue() {
    return _payments.fold<double>(
      0,
          (sum, p) => p.isTransfer && p.isCompleted ? sum + p.amount : sum,
    );
  }

  // ===== GET PAYMENTS BY SALE ID =====
  List<PaymentModel> getPaymentsBySaleId(String saleId) {
    return _payments.where((p) => p.saleId == saleId).toList();
  }

  // ===== GET PAYMENTS BY CUSTOMER ID =====
  List<PaymentModel> getPaymentsByCustomerId(String customerId) {
    return _payments.where((p) => p.customerId == customerId).toList();
  }

  // ===== SEARCH PAYMENTS =====
  void searchPayments(String query) {
    if (query.isEmpty) {
      _filteredPayments = [];
      _searchQuery = '';
      notifyListeners();
      return;
    }

    _searchQuery = query.toLowerCase();
    _filteredPayments = _payments
        .where((p) =>
    p.id.toLowerCase().contains(_searchQuery) ||
        (p.transactionId?.toLowerCase().contains(_searchQuery) ?? false) ||
        (p.saleName?.toLowerCase().contains(_searchQuery) ?? false) ||
        (p.customerName?.toLowerCase().contains(_searchQuery) ?? false))
        .toList();
    notifyListeners();
  }

  // ===== FILTER BY STATUS =====
  void filterByStatus(String? status) {
    _selectedStatus = status;
    _applyFilters();
  }

  // ===== FILTER BY PAYMENT METHOD =====
  void filterByPaymentMethod(String? method) {
    _selectedPaymentMethod = method;
    _applyFilters();
  }

  // ===== APPLY FILTERS =====
  void _applyFilters() {
    _filteredPayments = _payments.where((p) {
      // Status filter
      if (_selectedStatus != null && _selectedStatus!.isNotEmpty) {
        if (p.status != _selectedStatus) {
          return false;
        }
      }

      // Payment method filter
      if (_selectedPaymentMethod != null && _selectedPaymentMethod!.isNotEmpty) {
        if (p.paymentMethod != _selectedPaymentMethod) {
          return false;
        }
      }

      return true;
    }).toList();

    notifyListeners();
  }

  // ===== CLEAR FILTERS =====
  void clearFilters() {
    _searchQuery = '';
    _selectedStatus = null;
    _selectedPaymentMethod = null;
    _filteredPayments = [];
    notifyListeners();
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

  // ===== CLEAR SELECTED PAYMENT =====
  void clearSelectedPayment() {
    _selectedPayment = null;
    notifyListeners();
  }

  // ===== REFRESH PAYMENTS =====
  Future<void> refreshPayments() async {
    await loadPayments(reset: true);
  }

  // ===== RESET PROVIDER =====
  void reset() {
    _payments = [];
    _filteredPayments = [];
    _selectedPayment = null;
    _isLoading = false;
    _isSaving = false;
    _errorMessage = null;
    _successMessage = null;
    _searchQuery = '';
    _selectedStatus = null;
    _selectedPaymentMethod = null;
    _currentPage = 1;
    _totalPayments = 0;
    notifyListeners();
  }
}