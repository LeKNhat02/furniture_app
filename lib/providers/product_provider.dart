import 'package:flutter/material.dart';
import '../core/models/product_model.dart';
import '../core/services/product_service.dart';

class ProductProvider extends ChangeNotifier {
  final ProductService _productService = ProductService();

  // State variables
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  Product? _selectedProduct;
  bool _isLoading = false;
  String? _errorMessage;
  String? _selectedCategory;
  String _searchQuery = '';

  // Getters
  List<Product> get products => _filteredProducts.isEmpty ? _products : _filteredProducts;
  List<Product> get allProducts => _products;
  Product? get selectedProduct => _selectedProduct;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

  int get totalProducts => _products.length;
  int get lowStockCount => _products.where((p) => p.isLowStock).length;

  // Constructor
  ProductProvider() {
    fetchProducts();
  }

  /// Lấy danh sách tất cả sản phẩm
  Future<void> fetchProducts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _products = await _productService.getAll();
      _filteredProducts = [];
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      print('Fetch products error: $e');
    }
  }

  /// Lấy chi tiết sản phẩm
  Future<void> fetchProductById(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedProduct = await _productService.getById(id);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      print('Fetch product error: $e');
    }
  }

  /// Tạo sản phẩm mới
  Future<bool> createProduct(Product product) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newProduct = await _productService.create(product);
      _products.add(newProduct);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      print('Create product error: $e');
      return false;
    }
  }

  /// Cập nhật sản phẩm
  Future<bool> updateProduct(int id, Product product) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedProduct = await _productService.update(id, product);
      final index = _products.indexWhere((p) => p.id == id);
      if (index != -1) {
        _products[index] = updatedProduct;
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      print('Update product error: $e');
      return false;
    }
  }

  /// Xóa sản phẩm
  Future<bool> deleteProduct(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _productService.delete(id);
      _products.removeWhere((p) => p.id == id);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      print('Delete product error: $e');
      return false;
    }
  }

  /// Lọc sản phẩm theo danh mục
  void filterByCategory(String? category) {
    _selectedCategory = category;
    _applyFilters();
  }

  /// Tìm kiếm sản phẩm
  void search(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  /// Áp dụng tất cả filters
  void _applyFilters() {
    _filteredProducts = _products.where((product) {
      // Lọc theo danh mục
      if (_selectedCategory != null && product.category != _selectedCategory) {
        return false;
      }

      // Tìm kiếm theo tên
      if (_searchQuery.isNotEmpty &&
          !product.name.toLowerCase().contains(_searchQuery.toLowerCase())) {
        return false;
      }

      return true;
    }).toList();

    notifyListeners();
  }

  /// Xóa tất cả filters
  void clearFilters() {
    _selectedCategory = null;
    _searchQuery = '';
    _filteredProducts = [];
    notifyListeners();
  }

  /// Lấy sản phẩm sắp hết
  Future<void> fetchLowStockProducts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _filteredProducts = await _productService.getLowStock();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      print('Fetch low stock error: $e');
    }
  }

  /// Xóa error message
  void clearErrorMessage() {
    _errorMessage = null;
    notifyListeners();
  }
}