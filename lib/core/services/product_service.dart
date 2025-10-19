import '../models/product_model.dart';
import 'api_service.dart';

class ProductService {
  final ApiService _apiService = ApiService();

  /// Lấy danh sách tất cả sản phẩm
  Future<List<Product>> getAll({int page = 1, int limit = 50}) async {
    try {
      final response = await _apiService.get(
        '/products?page=$page&limit=$limit',
      );

      // Nếu response là list trực tiếp
      if (response is List) {
        return (response as List)
            .map((json) => Product.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      // Nếu response có key 'data' hoặc 'items'
      final items = response['items'] ?? response['data'] ?? response;
      if (items is List) {
        return (items as List)
            .map((json) => Product.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      print('Error getting products: $e');
      throw Exception('Lỗi lấy danh sách sản phẩm: $e');
    }
  }

  /// Lấy chi tiết 1 sản phẩm
  Future<Product> getById(int id) async {
    try {
      final response = await _apiService.get('/products/$id');
      return Product.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      print('Error getting product: $e');
      throw Exception('Lỗi lấy chi tiết sản phẩm: $e');
    }
  }

  /// Tạo sản phẩm mới
  Future<Product> create(Product product) async {
    try {
      final response = await _apiService.post(
        '/products',
        product.toJson(),
      );
      return Product.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      print('Error creating product: $e');
      throw Exception('Lỗi tạo sản phẩm: $e');
    }
  }

  /// Cập nhật sản phẩm
  Future<Product> update(int id, Product product) async {
    try {
      final response = await _apiService.put(
        '/products/$id',
        product.toJson(),
      );
      return Product.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      print('Error updating product: $e');
      throw Exception('Lỗi cập nhật sản phẩm: $e');
    }
  }

  /// Xóa sản phẩm
  Future<void> delete(int id) async {
    try {
      await _apiService.delete('/products/$id');
    } catch (e) {
      print('Error deleting product: $e');
      throw Exception('Lỗi xóa sản phẩm: $e');
    }
  }

  /// Lấy sản phẩm theo danh mục
  Future<List<Product>> getByCategory(String category) async {
    try {
      final response = await _apiService.get(
        '/products?category=$category',
      );

      final items = response['items'] ?? response['data'] ?? response;
      if (items is List) {
        return (items as List)
            .map((json) => Product.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      print('Error getting products by category: $e');
      throw Exception('Lỗi lấy sản phẩm theo danh mục: $e');
    }
  }

  /// Lấy sản phẩm sắp hết (low stock)
  Future<List<Product>> getLowStock() async {
    try {
      final response = await _apiService.get('/inventory/low-stock');

      final items = response['items'] ?? response['data'] ?? response;
      if (items is List) {
        return (items as List)
            .map((json) => Product.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      print('Error getting low stock products: $e');
      throw Exception('Lỗi lấy sản phẩm sắp hết: $e');
    }
  }
}