import '../models/sale_model.dart';
import 'api_service.dart';

class SaleService {
  final ApiService _apiService = ApiService();
  static const String endpoint = '/sales';

  Future<List<SaleModel>> getSales({
    int page = 1,
    int limit = 20,
    String? search,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
        if (search != null) 'search': search,
        if (status != null) 'status': status,
        if (startDate != null) 'start_date': startDate.toIso8601String(),
        if (endDate != null) 'end_date': endDate.toIso8601String(),
      };

      final response = await _apiService.get(
        endpoint,
        queryParameters: queryParams,
      );

      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((item) => SaleModel.fromJson(item)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<SaleModel> getSaleById(String id) async {
    try {
      final response = await _apiService.get('$endpoint/$id');
      return SaleModel.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  Future<SaleModel> createSale(Map<String, dynamic> saleData) async {
    try {
      final response = await _apiService.post(
        endpoint,
        data: saleData,
      );
      return SaleModel.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  Future<SaleModel> updateSale(String id, Map<String, dynamic> saleData) async {
    try {
      final response = await _apiService.put(
        '$endpoint/$id',
        data: saleData,
      );
      return SaleModel.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteSale(String id) async {
    try {
      await _apiService.delete('$endpoint/$id');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> cancelSale(String id) async {
    try {
      await _apiService.patch(
        '$endpoint/$id/cancel',
        data: {},
      );
    } catch (e) {
      rethrow;
    }
  }
}

