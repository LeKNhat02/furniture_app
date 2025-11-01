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
      // Nếu có imagePath, gửi multipart/form-data
      dynamic payload = productData;
      if (productData.containsKey('imagePath') && productData['imagePath'] != null) {
        final path = productData['imagePath'] as String;
        // Xóa trường imagePath khỏi data json trước khi gửi form
        final cleaned = Map<String, dynamic>.from(productData)..remove('imagePath');
        final formData = FormData();
        // Thêm các field còn lại
        cleaned.forEach((key, value) {
          formData.fields.add(MapEntry(key, value?.toString() ?? ''));
        });

        // Thêm file ảnh
        final multipartFile = await MultipartFile.fromFile(path, filename: path.split('/').last);
        formData.files.add(MapEntry('image', multipartFile));

        payload = formData;
      }

      final response = await _apiService.post(
        endpoint,
        data: payload,
      );
      return ProductModel.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  // Cập nhật sản phẩm
  Future<ProductModel> updateProduct(String id, Map<String, dynamic> productData) async {
    try {
      dynamic payload = productData;
      if (productData.containsKey('imagePath') && productData['imagePath'] != null) {
        final path = productData['imagePath'] as String;
        final cleaned = Map<String, dynamic>.from(productData)..remove('imagePath');
        final formData = FormData();
        cleaned.forEach((key, value) {
          formData.fields.add(MapEntry(key, value?.toString() ?? ''));
        });

        final multipartFile = await MultipartFile.fromFile(path, filename: path.split('/').last);
        formData.files.add(MapEntry('image', multipartFile));
        payload = formData;
      }

      final response = await _apiService.put(
        '$endpoint/$id',
        data: payload,
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