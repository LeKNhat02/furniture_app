import '../models/supplier_model.dart';
import 'api_service.dart';

class SupplierService {
  final ApiService _apiService = ApiService();
  static const String endpoint = '/suppliers';

  Future<List<SupplierModel>> getSuppliers({
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

      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((item) => SupplierModel.fromJson(item)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<SupplierModel> getSupplierById(String id) async {
    try {
      final response = await _apiService.get('$endpoint/$id');
      return SupplierModel.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  Future<SupplierModel> createSupplier(Map<String, dynamic> supplierData) async {
    try {
      final response = await _apiService.post(
        endpoint,
        data: supplierData,
      );
      return SupplierModel.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  Future<SupplierModel> updateSupplier(String id, Map<String, dynamic> supplierData) async {
    try {
      final response = await _apiService.put(
        '$endpoint/$id',
        data: supplierData,
      );
      return SupplierModel.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteSupplier(String id) async {
    try {
      await _apiService.delete('$endpoint/$id');
    } catch (e) {
      rethrow;
    }
  }
}

