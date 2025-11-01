// lib/core/services/customer_service.dart

import '../models/customer_model.dart';
import 'api_service.dart';

class CustomerService {
  final ApiService _apiService = ApiService();
  static const String endpoint = '/customers';

  Future<List<CustomerModel>> getCustomers({int page = 1, int limit = 20, String? search}) async {
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
      return data.map((item) => CustomerModel.fromJson(item)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<CustomerModel> getCustomerById(String id) async {
    try {
      final response = await _apiService.get('$endpoint/$id');
      return CustomerModel.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  Future<CustomerModel> createCustomer(Map<String, dynamic> customerData) async {
    try {
      final response = await _apiService.post(
        endpoint,
        data: customerData,
      );
      return CustomerModel.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  Future<CustomerModel> updateCustomer(String id, Map<String, dynamic> customerData) async {
    try {
      final response = await _apiService.put(
        '$endpoint/$id',
        data: customerData,
      );
      return CustomerModel.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteCustomer(String id) async {
    try {
      await _apiService.delete('$endpoint/$id');
    } catch (e) {
      rethrow;
    }
  }
}
