import '../models/payment_model.dart';
import 'api_service.dart';

class PaymentService {
  final ApiService _apiService;
  static const String endpoint = '/payments';

  // ✅ Constructor nhận ApiService
  PaymentService(this._apiService);

  // ===== GET ALL PAYMENTS =====
  Future<List<PaymentModel>> getPayments({
    int page = 1,
    int limit = 20,
    String? search,
    String? status,
    String? paymentMethod,
    String? saleId,
    String? customerId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
        if (search != null && search.isNotEmpty) 'search': search,
        if (status != null && status.isNotEmpty) 'status': status,
        if (paymentMethod != null && paymentMethod.isNotEmpty) 'payment_method': paymentMethod,
        if (saleId != null && saleId.isNotEmpty) 'sale_id': saleId,
        if (customerId != null && customerId.isNotEmpty) 'customer_id': customerId,
        if (startDate != null) 'start_date': startDate.toIso8601String(),
        if (endDate != null) 'end_date': endDate.toIso8601String(),
      };

      final response = await _apiService.get(
        endpoint,
        queryParameters: queryParams,
      );

      final List<dynamic> data = response.data['data'] as List<dynamic>? ?? [];
      return data.map((item) => PaymentModel.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      rethrow;
    }
  }

  // ===== GET PAYMENT BY ID =====
  Future<PaymentModel> getPaymentById(String id) async {
    try {
      if (id.isEmpty) {
        throw ArgumentError('Payment ID cannot be empty');
      }

      final response = await _apiService.get('$endpoint/$id');

      final data = response.data['data'];
      if (data == null) {
        throw Exception('Payment not found');
      }

      return PaymentModel.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  // ===== CREATE PAYMENT =====
  Future<PaymentModel> createPayment(Map<String, dynamic> paymentData) async {
    try {
      if (paymentData.isEmpty) {
        throw ArgumentError('Payment data cannot be empty');
      }

      final response = await _apiService.post(
        endpoint,
        data: paymentData,
      );

      final data = response.data['data'];
      if (data == null) {
        throw Exception('Failed to create payment');
      }

      return PaymentModel.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  // ===== UPDATE PAYMENT =====
  Future<PaymentModel> updatePayment(String id, Map<String, dynamic> paymentData) async {
    try {
      if (id.isEmpty) {
        throw ArgumentError('Payment ID cannot be empty');
      }

      if (paymentData.isEmpty) {
        throw ArgumentError('Payment data cannot be empty');
      }

      final response = await _apiService.put(
        '$endpoint/$id',
        data: paymentData,
      );

      final data = response.data['data'];
      if (data == null) {
        throw Exception('Failed to update payment');
      }

      return PaymentModel.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  // ===== DELETE PAYMENT =====
  Future<void> deletePayment(String id) async {
    try {
      if (id.isEmpty) {
        throw ArgumentError('Payment ID cannot be empty');
      }

      await _apiService.delete('$endpoint/$id');
    } catch (e) {
      rethrow;
    }
  }

  // ===== REFUND PAYMENT =====
  Future<PaymentModel> refundPayment(String id, {String? notes}) async {
    try {
      if (id.isEmpty) {
        throw ArgumentError('Payment ID cannot be empty');
      }

      final data = {
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      };

      final response = await _apiService.post(
        '$endpoint/$id/refund',
        data: data,
      );

      final responseData = response.data['data'];
      if (responseData == null) {
        throw Exception('Failed to refund payment');
      }

      return PaymentModel.fromJson(responseData as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }
}