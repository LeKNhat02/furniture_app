import 'package:flutter/material.dart';
import '../core/models/product_model.dart';
import '../core/services/product_service.dart';

class ProductProvider extends ChangeNotifier {
  final ProductService _productService = ProductService();

  // State variables
  List<ProductModel> _products = [];
  List<ProductModel> _filteredProducts = [];
  ProductModel? _selectedProduct;

  bool _isLoading = false;
  String? _errorMessage;

  // Filter variables
  String? _selectedCategory;
  String? _searchQuery;
  bool _showLowStockOnly = false;
  // Pagination
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  // Getters
  List<ProductModel> get products => _filteredProducts.isEmpty && _searchQuery == null && _selectedCategory == null && !_showLowStockOnly
      ? _products
      : _filteredProducts;

  ProductModel? get selectedProduct => _selectedProduct;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  int get currentPage => _currentPage;
  String? get errorMessage => _errorMessage;
  String? get selectedCategory => _selectedCategory;

  /// Lấy danh sách sản phẩm từ API
  Future<void> fetchProducts({int page = 1, int limit = 20}) async {
    // Prevent duplicate loads
    if (page > 1) {
      if (!_hasMore || _isLoadingMore) return;
      _isLoadingMore = true;
      notifyListeners();
    } else {
      if (_isLoading) return; // already loading page 1
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      final fetched = await _productService.getProducts(
        page: page,
        limit: limit,
        search: _searchQuery,
      );

      if (page == 1) {
        _products = fetched;
      } else {
        _products.addAll(fetched);
      }

      _filteredProducts = List.from(_products);

      // pagination state - update currentPage only on success
      _currentPage = page;
      // If server returns exactly `limit` items, we assume there may be more
      _hasMore = fetched.length == limit;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = _parseError(e);
      if (page == 1) {
        _products = [];
        _filteredProducts = [];
      }
    } finally {
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  /// Lấy chi tiết một sản phẩm theo ID
  /// Sử dụng String cho id
  Future<void> fetchProductById(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedProduct = await _productService.getProductById(id);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = _parseError(e);
      _selectedProduct = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Tạo sản phẩm mới
  Future<bool> createProduct(Map<String, dynamic> productData) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newProduct = await _productService.createProduct(productData);
      _products.add(newProduct);
      _filteredProducts = List.from(_products);
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

  /// Cập nhật sản phẩm
  /// Sử dụng String cho id
  Future<bool> updateProduct(String id, Map<String, dynamic> productData) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedProduct = await _productService.updateProduct(id, productData);

      // Cập nhật trong danh sách
      final index = _products.indexWhere((p) => p.id == id);
      if (index != -1) {
        _products[index] = updatedProduct;
      }

      // Cập nhật selected product nếu trùng
      if (_selectedProduct?.id == id) {
        _selectedProduct = updatedProduct;
      }

      _filteredProducts = List.from(_products);
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

  /// Xóa sản phẩm
  /// Sử dụng String cho id
  Future<bool> deleteProduct(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _productService.deleteProduct(id);
      _products.removeWhere((p) => p.id == id);
      _filteredProducts = List.from(_products);
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

  /// Tìm kiếm sản phẩm theo tên
  /// Perform server-side search by resetting to page 1 and fetching
  Future<void> searchProducts(String query) async {
    _searchQuery = query.trim();
    // Reset paging and fetch page 1 from server
    _currentPage = 1;
    await fetchProducts(page: 1);
  }

  /// Lọc sản phẩm theo danh mục
  void filterByCategory(String category) {
    _selectedCategory = category;
    _applyFilters();
  }

  /// Lọc sản phẩm có tồn kho thấp
  void filterLowStock() {
    _showLowStockOnly = !_showLowStockOnly;
    _applyFilters();
  }

  /// Xóa tất cả bộ lọc
  void clearFilters() {
    _searchQuery = null;
    _selectedCategory = null;
    _showLowStockOnly = false;
    _filteredProducts = List.from(_products);
    notifyListeners();
  }

  /// Áp dụng các bộ lọc
  void _applyFilters() {
    _filteredProducts = _products.where((product) {
      // Lọc theo tên
      if (_searchQuery != null && _searchQuery!.isNotEmpty) {
        final name = product.name.toLowerCase();
        final sku = product.sku.toLowerCase();
        if (!name.contains(_searchQuery!.toLowerCase()) &&
            !sku.contains(_searchQuery!.toLowerCase())) {
          return false;
        }
      }

      // Lọc theo danh mục
      if (_selectedCategory != null) {
        if (product.category != _selectedCategory) {
          return false;
        }
      }

      // Lọc hàng sắp hết
      if (_showLowStockOnly) {
        if (product.quantity >= product.quantityMin) {
          return false;
        }
      }

      return true;
    }).toList();

    notifyListeners();
  }

  /// Parse lỗi từ các exception
  String _parseError(dynamic error) {
    print('Error: $error');

    if (error is Exception) {
      final errorString = error.toString();

      // DioException
      if (errorString.contains('SocketException')) {
        return 'Lỗi kết nối. Vui lòng kiểm tra internet';
      }
      if (errorString.contains('TimeoutException')) {
        return 'Kết nối timeout. Vui lòng thử lại';
      }
      if (errorString.contains('401')) {
        return 'Không có quyền truy cập. Vui lòng đăng nhập lại';
      }
      if (errorString.contains('404')) {
        return 'Sản phẩm không tìm thấy';
      }
      if (errorString.contains('500')) {
        return 'Lỗi server. Vui lòng thử lại sau';
      }

      return errorString.replaceAll('Exception: ', '');
    }

    return 'Có lỗi xảy ra: ${error.toString()}';
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Reset provider
  void reset() {
    _products = [];
    _filteredProducts = [];
    _selectedProduct = null;
    _isLoading = false;
    _errorMessage = null;
    _selectedCategory = null;
    _searchQuery = null;
    _showLowStockOnly = false;
    notifyListeners();
  }
}