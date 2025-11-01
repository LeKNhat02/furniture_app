import 'package:flutter/material.dart';
import '../core/models/promotion_model.dart';
import '../core/services/promotion_service.dart';

class PromotionProvider extends ChangeNotifier {
  final PromotionService _promotionService = PromotionService();

  List<PromotionModel> _promotions = [];
  List<PromotionModel> _filteredPromotions = [];
  PromotionModel? _selectedPromotion;

  bool _isLoading = false;
  String? _errorMessage;

  String? _searchQuery;
  bool? _isActiveFilter;

  // Getters
  List<PromotionModel> get promotions => _filteredPromotions.isEmpty && _searchQuery == null && _isActiveFilter == null
      ? _promotions
      : _filteredPromotions;

  PromotionModel? get selectedPromotion => _selectedPromotion;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Lấy danh sách khuyến mãi
  Future<void> fetchPromotions({int page = 1, int limit = 20}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _promotions = await _promotionService.getPromotions(
        page: page,
        limit: limit,
        search: _searchQuery,
        isActive: _isActiveFilter,
      );
      _filteredPromotions = List.from(_promotions);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = _parseError(e);
      _promotions = [];
      _filteredPromotions = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Lấy chi tiết khuyến mãi
  Future<void> fetchPromotionById(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedPromotion = await _promotionService.getPromotionById(id);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = _parseError(e);
      _selectedPromotion = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Tạo khuyến mãi mới
  Future<bool> createPromotion(Map<String, dynamic> promotionData) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newPromotion = await _promotionService.createPromotion(promotionData);
      _promotions.add(newPromotion);
      _filteredPromotions = List.from(_promotions);
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

  // Cập nhật khuyến mãi
  Future<bool> updatePromotion(String id, Map<String, dynamic> promotionData) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedPromotion = await _promotionService.updatePromotion(id, promotionData);

      final index = _promotions.indexWhere((p) => p.id == id);
      if (index != -1) {
        _promotions[index] = updatedPromotion;
      }

      if (_selectedPromotion?.id == id) {
        _selectedPromotion = updatedPromotion;
      }

      _filteredPromotions = List.from(_promotions);
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

  // Xóa khuyến mãi
  Future<bool> deletePromotion(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _promotionService.deletePromotion(id);
      _promotions.removeWhere((p) => p.id == id);
      _filteredPromotions = List.from(_promotions);
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
  void searchPromotions(String query) {
    _searchQuery = query.trim();
    _applyFilters();
  }

  // Lọc theo trạng thái
  void filterByActive(bool? isActive) {
    _isActiveFilter = isActive;
    _applyFilters();
  }

  // Áp dụng bộ lọc
  void _applyFilters() {
    _filteredPromotions = _promotions.where((promotion) {
      if (_searchQuery != null && _searchQuery!.isNotEmpty) {
        final name = promotion.name.toLowerCase();
        final description = promotion.description?.toLowerCase() ?? '';
        if (!name.contains(_searchQuery!.toLowerCase()) &&
            !description.contains(_searchQuery!.toLowerCase())) {
          return false;
        }
      }

      if (_isActiveFilter != null) {
        if (promotion.isActive != _isActiveFilter) {
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
    _isActiveFilter = null;
    _filteredPromotions = List.from(_promotions);
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
    _promotions = [];
    _filteredPromotions = [];
    _selectedPromotion = null;
    _isLoading = false;
    _errorMessage = null;
    _searchQuery = null;
    _isActiveFilter = null;
    notifyListeners();
  }
}

