import '../models/inventory_model.dart';
import 'api_service.dart';

class InventoryService {
  final ApiService _apiService = ApiService();
  static const String endpoint = '/inventory';

  Future<List<InventoryTransaction>> getTransactions({
    int page = 1,
    int limit = 20,
    String? productId,
    String? type,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
        if (productId != null) 'product_id': productId,
        if (type != null) 'type': type,
        if (startDate != null) 'start_date': startDate.toIso8601String(),
        if (endDate != null) 'end_date': endDate.toIso8601String(),
      };

      final response = await _apiService.get(
        endpoint,
        queryParameters: queryParams,
      );

      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((item) => InventoryTransaction.fromJson(item)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<InventoryTransaction> getTransactionById(String id) async {
    try {
      final response = await _apiService.get('$endpoint/$id');
      return InventoryTransaction.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  Future<InventoryTransaction> createTransaction(Map<String, dynamic> transactionData) async {
    try {
      final response = await _apiService.post(
        endpoint,
        data: transactionData,
      );
      return InventoryTransaction.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteTransaction(String id) async {
    try {
      await _apiService.delete('$endpoint/$id');
    } catch (e) {
      rethrow;
    }
  }
}

