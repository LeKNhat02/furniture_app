// lib/core/services/product_service.dart

import 'package:dio/dio.dart';
import '../models/product_model.dart';
import 'api_service.dart';

class ProductService {
  final ApiService _apiService = ApiService();
  static const String endpoint = '/products';

  // Lấy danh sách sản phẩm
  Future<List<ProductModel>> getProducts({
    int page = 1,
    int limit = 20,
    String? search,
  }) async {
    try {
      final response = await _apiService.get(
        endpoint,
        queryParameters: {
          'page': page,
          'limit': limit,
          if (search != null) 'search': search,
        },
      );

      final List<dynamic> data = response.data['data'];
      return data.map((item) => ProductModel.fromJson(item)).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Lấy chi tiết sản phẩm
  Future<ProductModel> getProductById(String id) async {
    try {
      final response = await _apiService.get('$endpoint/$id');
      return ProductModel.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  // Tạo sản phẩm mới
  Future<ProductModel> createProduct(Map<String, dynamic> productData) async {
    try {
      final response = await _apiService.post(
        endpoint,
        data: productData,
      );
      return ProductModel.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  // Cập nhật sản phẩm
  Future<ProductModel> updateProduct(String id, Map<String, dynamic> productData) async {
    try {
      final response = await _apiService.put(
        '$endpoint/$id',
        data: productData,
      );
      return ProductModel.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  // Xóa sản phẩm
  Future<void> deleteProduct(String id) async {
    try {
      await _apiService.delete('$endpoint/$id');
    } catch (e) {
      rethrow;
    }
  }
}